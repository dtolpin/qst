; $Id: cnc-lesy.lisp,v 1.20 2005/09/07 10:10:57 dvd Exp $

(defpackage "CNC-LESY"
	(:documentation "CNC legacy syntax parser")
	(:use "COMMON-LISP" "UTIL" "LL-PARSING")
	(:export "READ-CNC" "CNC-PARSE-ERROR"))
(in-package "CNC-LESY")

(eval-when (:compile-toplevel :execute)
	(setf *readtable* (copy-readtable))
	(set-dispatch-macro-character #\# #\\ #'name-parentheses))

(defvar *lineno* nil "current line number, used for error reporting")

(define-condition CNC-PARSE-ERROR (error)
	((message :initarg :message) 
		(lineno :initarg :lineno) (args :initarg :args))
	(:report 
		(lambda (condition stream)
			(with-slots (message lineno args) condition
				(apply #'format stream (concatenate 'string "line ~S: " message) 
					lineno args)))))

(defmacro ENSURE (test-form message &rest args)
	"reports CNC error by calling cerror"
	`(unless ,test-form
		(cerror "JavaScript will hang your browser~*" 'cnc-parse-error
			:message ,message
			:lineno *lineno*
			:args `(,,@args))))

(defmacro SCAN-1ST-NCHAR ()
	'(parse-or (p-alpha-char) (p-other-char)))

(defmacro SCAN-NCHAR ()
	'(parse-or (scan-1st-nchar) (p-digit-char) (p-char-class '(#\_ #\/))))

(defmacro SCAN-NAME ()
	'(transform-result
		#'(lambda (l) `(name ,(qst:intern-name (coerce l 'string)) ,*lineno*))
		(parse-group (scan-1st-nchar) 
			(parse-some (scan-nchar)))))

(defmacro SCAN-STRING ()
	'(transform-result
		#'(lambda (l)
				`(string
					,(coerce (butlast
						(cond
							(*newlines* (cons #\Newline (cdr l)))
							((char= (car l) #\+) (cons #\Newline (cddr l)))
							(t (cdr l))))
						'string)
					,*lineno*))
		(parse-group 
			(parse-maybe (p-char #\+))
			(p-char #\Lpar)
			(parse-some
				(parse-or 
					(p-char-nclas '(#\Rpar #\\))
					(transform-result #'(lambda (l) (cdr l))
						(parse-group (p-char #\\) (p-any)))))
			(p-char #\Rpar))))

(defmacro SCAN-NUMBER ()
	'(transform-result
		#'(lambda (l) `(,(parse-fixnum (coerce l 'string))))
		(parse-group 
			(parse-maybe (p-char-class '(#\+ #\-)))
			(parse-many (p-digit-char))
			(parse-maybe
				(parse-group
					(p-char #\.)
					(parse-some (p-digit-char)))))))

(defmacro SCAN-SPACE ()
	'(transform-result #'(lambda (l) (declare (ignore l)) ())
		(parse-or
			(parse-group
				(p-char #\|)
				(p-all))
			(parse-many
				(p-char-class '(#\Space #\Tab #\Return #\Newline))))))
	
(defmacro SCAN-CALL-BODY ()
	'(parse-some (parse-or
		(scan-name)
		(scan-number)
		(p-char-class '(#\Lpar #\Rpar #\Lsqr #\Rsqr #\,))
		(scan-space))))

(defmacro SCAN-CALL ()
	'(transform-result 
		#'(lambda (l) (result (funcall (scan-call-body) l)))
		(parse-group 
			(parse-maybe (p-char #\+))
			(p-char #\Lsqr)
			(parse-some
				(p-notch #\Rsqr))
			(p-char #\Rsqr))))

(defmacro SCAN-LINE ()
	'(parse-some
		(parse-or
			(scan-space)		
			(scan-string)
			(scan-number)
			(scan-name)
			(p-char-class '(#\* #\Lcur #\Rcur #\+))
			(scan-call))))

(defvar *cnc* nil "CNC byte code")
(defvar *btab* nil "back-jump table")
(defvar *jtab* nil "jump table")
(defvar *label* nil "current label")
(defvar *newlines* nil "whether each print start with newline")

(defmacro DBG (x)
	`(transform-result #'(lambda (l) (print l) l) ,x))

(defmacro PROCESS-BOUNDARY (inf)
	`(parse-or
		(transform-result #'(lambda (l) (declare (ignore l)) `(,,inf))
			(p-eql #\*))
		(p-if #'numberp)))

(defmacro PROCESS-RANGE ()
	'(parse-group (process-boundary cnc:+inf) (process-boundary cnc:-inf)))

(defmacro PROCESS-MAYBE-RANGE ()
	'(transform-result #'(lambda (l) (or l `(,cnc:-inf ,cnc:+inf)))
			 (parse-maybe (process-range))))

(defmacro PROCESS-NAME ()
	'(transform-result 
		#'(lambda (l)
			(setf *lineno* (caddr l))
			(list (qst:intern-name (cadr l))))
		(parse-group (p-eql 'name) (p-any) (p-any))))

(defmacro PROCESS-STRING ()
	'(transform-result
		#'(lambda (l)
			(setf *lineno* (caddr l))
			(list (cadr l)))
		(parse-group (p-eql 'string) (p-any) (p-any))))

(defmacro PROCESS-LABEL ()
	'(transform-result
		#'(lambda (l)
			(setf *newlines* (eql (car l) #\+))
			(setf	*label* (cadr l))
			(let ((addr (length *cnc*)))
				(setf	(gethash *label* *btab*) addr)
				(dolist (cmd (gethash *label* *jtab*))
					(setf (cnc:cmd-target cmd) addr))
				(remhash *label* *jtab*))
			())
		(parse-group
			(transform-result #'(lambda (l) (or l '(#\-)))
				(parse-maybe
					(p-eql #\+)))
			(process-name))))

(defmacro PROCESS-SYMPTOM ()
	'(transform-result
		#'(lambda (l)
			(vector-push-extend 
				(cnc:make-cmd :opcode :INC :target *label*
					:var (caddr l) :low (car l) :high (cadr l)
					:op1 1) ; always 1 in lesy
				*cnc*)
			())
		(parse-group (process-range) (process-name))))

(defmacro PROCESS-SYNDROME ()
	'(parse-group
		(process-label)
		(transform-result
			#'(lambda (l)
				(declare (ignore l))
				(vector-push-extend
					(cnc:make-cmd :opcode :CLR :target *label*)
					*cnc*)
				())
			(p-eql #\Lcur))
		(parse-some (process-symptom))
		(p-eql #\Rcur)))

(defmacro PROCESS-PRINT ()
	'(transform-result
		#'(lambda (l)
			(vector-push-extend
				(cnc:make-cmd :opcode :PRN :target (caddr l)
					:var *label* :low (car l) :high (cadr l))
				*cnc*)
			())
		(parse-group (process-maybe-range) (process-string))))

(defmacro PROCESS-JUMP ()
	'(transform-result
		#'(lambda (l)
			(let ((func (nth 3 l)))
				(ensure (member  func '("back" "jump") :test #'string=)
					"expected 'jump', got ~S" func)
				(let* ((target (nth 5 l))
						(cmd (cnc:make-cmd :opcode :JMP :target target
							:var *label* :low (car l) :high (cadr l))))
					(cond
						((string= func "jump")
							(push cmd (gethash target *jtab*)))
						((string= func "back")
							(setf (cnc:cmd-target cmd) (gethash target *btab*))))
					(vector-push-extend cmd	*cnc*)))
				())
		(parse-group
			(process-maybe-range) 
			(p-eql #\Lsqr) (process-name)
			(p-eql #\Lpar) (process-name) (p-eql #\Rpar)
			(p-eql #\Rsqr))))

(defmacro PROCESS-OP ()
	'(transform-result #'cdr
		(parse-group
			(p-eql #\,)
			(parse-or
				(process-name)
				(p-if #'numberp)))))

(defmacro PROCESS-BINOP ()
	'(transform-result
		#'(lambda (l)
			(let ((func (nth 3 l)))
				(ensure (member func '("add" "sub" "mul" "div") :test #'string=)
					"expected 'add, sub, mul or div', got ~S" func)
				(vector-push-extend
					(cnc:make-cmd :opcode (intern (string-upcase func) (find-package "KEYWORD"))
						:target (nth 5 l)
						:var *label* :low (car l) :high (cadr l)
						:op1 (nth 6 l) :op2 (nth 7 l))
					*cnc*)
				()))
		(parse-group
			(process-maybe-range) 
			(p-eql #\Lsqr) (process-name)
			(p-eql #\Lpar) (process-name) 
			(process-op) (process-op) (p-eql #\Rpar)
			(p-eql #\Rsqr))))

(defmacro PROCESS-CNC ()
	'(parse-some
		(parse-or
			(process-print)
			(process-syndrome)
			(process-label)
			(process-jump)
			(process-binop))))

(defun READ-CNC (inp)
	(let ((*cnc* (make-array '(0) :adjustable t :fill-pointer 0))
			(*jtab* (make-hash-table)) (*btab* (make-hash-table)) (*label* nil)
			(*newlines* nil))
		(let* ((r (funcall (process-cnc)
						(do ((line "" (read-line inp nil nil))
								(*lineno* 0 (1+ *lineno*))
								(tokens () 
									(nconc tokens
										(let ((r (funcall (scan-line) (coerce line 'list))))
											(ensure (null (rest r)) 
												"unexpected symbol '~A'" (car (rest r)))
											(copy-list (result r))))))
							((null line) tokens)))))
			(ensure (null (rest r)) "syntax error near ~A" (car (rest r))))
		*cnc*))

(defmacro TEST-CNC (test-name src bytecode)
	`(with-input-from-string (inp ,src)
		(let (
				(cnc (read-cnc inp))
				(samp ,bytecode))
			(assert (equalp cnc samp) nil (format nil "~S failed" ',test-name)))))

(eval-when (:execute :load-toplevel) 
	(test-cnc "BASIC" "X 1 2 +(hello) Y 2 2 (world)"
		(coerce
			`(,(cnc:make-cmd :opcode :PRN :target (format nil "~%hello")
					:var "X" :low 1 :high 2)
				,(cnc:make-cmd :opcode :PRN :target "world"
					:var "Y" :low 2 :high 2))
			'vector))
	(test-cnc "BOUNCE" "X 0 0 [jump(Y)] Y 0 0 [back(X)]"
		(coerce
			`(,(cnc:make-cmd :opcode :JMP :target 1 :var "X" :low 0 :high 0)
				,(cnc:make-cmd :opcode :JMP :target 0 :var "Y" :low 0 :high 0))
			'vector))
	(test-cnc "JUMPS" "X 0 0 [jump(X)] X 0 0 [jump(X)] X"
		(coerce
			`(,(cnc:make-cmd :opcode :JMP :target 1 :var "X" :low 0 :high 0)
				,(cnc:make-cmd :opcode :JMP :target 2 :var "X" :low 0 :high 0))
			'vector))
	(test-cnc "IFDEF" "X (xyz)"
		(coerce
			`(,(cnc:make-cmd :opcode :PRN :target "xyz"
					:var "X" :low cnc:-inf :high cnc:+inf))
			'vector))
	(test-cnc "NA" "X * * (xyz)"
		(coerce
			`(,(cnc:make-cmd :opcode :PRN :target "xyz"
					:var "X" :low cnc:+inf :high cnc:-inf))
			'vector))
	(test-cnc "SYNDROME" "X {1 2 A 2 2 B}"
		(coerce
			`(,(cnc:make-cmd :opcode :CLR :target "X")
				,(cnc:make-cmd :opcode :INC :target "X" :var "A" :low 1 :high 2 :op1 1)
				,(cnc:make-cmd :opcode :INC :target "X" :var "B" :low 2 :high 2 :op1 1))
			'vector))
	t)
