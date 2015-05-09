; $Id: cnc-nova.lisp,v 1.18 2006/05/25 22:03:05 dvd Exp $

(defpackage "CNC-NOVA"
	(:documentation "CNC new syntax parser")
	(:use "COMMON-LISP" "UTIL" "LL-PARSING")
	(:export "READ-CNC" "CNC-PARSE-ERROR"))
(in-package "CNC-NOVA")

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

; to make this module run an order of decimal magnitude faster, 
; rewrite the scanner without combinators, in the old character-at-a-time
; way. Most of the time is spent in scan-(number|string|name)

(defmacro SCAN-1ST-NCHAR ()
	'(parse-or (p-alpha-char) (p-other-char)))

(defmacro SCAN-NCHAR ()
	'(parse-or (scan-1st-nchar) (p-digit-char) 
		(p-char-class '(#\_ #\/))))

(defmacro SCAN-NAME ()
	'(transform-result
		#'(lambda (l) `(name ,(qst:intern-name (coerce l 'string)) ,*lineno*))
		(parse-group (scan-1st-nchar) 
			(parse-some (scan-nchar)))))

(defmacro SCAN-STRING ()
	'(transform-result
		#'(lambda (l)
				`(string
					,(coerce (butlast (cdr l)) 'string)
					,*lineno*))
		(parse-group 
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
			(parse-group (p-char #\|) (p-all))
			(parse-many (p-char-class '(#\Space #\Tab #\Return #\Newline))))))

(defmacro SCAN-JUMP ()
	'(transform-result #'(lambda (l) (declare (ignore l)) '(jump))
		(parse-group (p-char #\-) (p-char #\>))))

(defmacro SCAN-LINE ()
	'(parse-some (parse-or
		(scan-space)
		(scan-string)
		(scan-number)
		(scan-name)
		(scan-jump)
		(p-char-class '(#\* #\? #\! #\_ #\+ #\- #\: #\Lcur #\Rcur)))))

(defvar *cnc* nil "CNC byte code")
(defvar *blocks* nil "block stack")
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
	'(parse-or
		(parse-group (process-boundary cnc:-inf) (process-boundary cnc:+inf))
		(transform-result #'(lambda (l) (cons (car l) l))
			(p-if #'numberp))
		(transform-result #'(lambda (l) (declare (ignore l)) `(,cnc:+inf ,cnc:-inf))
			(p-eql #\?))
		(transform-result #'(lambda (l) (declare (ignore l)) `(,cnc:-inf ,cnc:+inf))
			(p-eql #\*))))
		

(defmacro PROCESS-MAYBE-RANGE ()
	'(parse-or (process-range)
		(transform-result
			#'(lambda (l) (declare (ignore l)) `(,cnc:-inf ,cnc:-inf))
			 (parse-empty))))

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
				(parse-maybe (parse-or (p-eql #\-) (p-eql #\+))))			
			(parse-or
				(process-name)
				(transform-result #'(lambda (l) (declare (ignore l)) ())
					(p-eql #\_))))))

; I tried using destructuring-bind instead of nth,
; but didn't like the way the code looked
(defmacro PROCESS-SYMPTOM ()
	'(transform-result
		#'(lambda (l)
			(vector-push-extend 
				(cnc:make-cmd :opcode :INC :target *label*
					:var (nth 2 l) :low (nth 0 l) :high (nth 1 l)
					:op1 (nth 3 l))
				*cnc*)
			())
		(parse-group (process-maybe-range) (process-name)
			(transform-result #'(lambda (l) (if l (cdr l) '(1)))
				(parse-maybe
					(parse-group (p-eql #\:)
						(parse-or (process-name) (p-if #'numberp))))))))

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
				(cnc:make-cmd :opcode :PRN 
					:target 
						(ecase 
								(let ((nl (nth 2 l)))
									(if (char= nl #\.) 
										(if *newlines* #\+ #\-)
										nl))
							(#\+ (concatenate 'string (string #\Newline) (nth 3 l)))
							(#\- (nth 3 l)))
					:var *label* :low (nth 0 l) :high (nth 1 l))
				*cnc*)
			())
		(parse-group (process-maybe-range)
			(transform-result #'(lambda (l) (or l '(#\.)))
				(parse-maybe (parse-or (p-eql #\-) (p-eql #\+))))
			(process-string))))

(defmacro PROCESS-JUMP ()
	'(transform-result
		#'(lambda (l)
				(let* ((dir (nth 3 l)) (target (nth 4 l)) 
						(cmd (cnc:make-cmd :opcode :JMP :target target
							:var *label* :low (nth 0 l) :high (nth 1 l))))
					(ecase dir
						(#\+
							(push cmd (gethash target *jtab*)))
						(#\-
							(setf (cnc:cmd-target cmd) (gethash target *btab*))))
					(vector-push-extend cmd	*cnc*))
				())
		(parse-group
			(process-maybe-range) 
			(p-eql 'jump)
			(transform-result #'(lambda (l) (or l '(#\+)))
				(parse-maybe (p-char-class '(#\+ #\-))))
			(process-name))))

(defmacro PROCESS-STOP ()
	'(transform-result
		#'(lambda (l) 
			(vector-push-extend
				(cnc:make-cmd :opcode :JMP :target cnc:+inf
					:var *label* :low (nth 0 l) :high (nth 1 l))
				*cnc*)
			())
		(parse-group
			(process-maybe-range)
			(p-eql #\!))))

(defmacro PROCESS-BLOCK ()
	'(transform-result 
		#'(lambda (l) (declare (ignore l))
			(destructuring-bind (jmp label newlines) (pop *blocks*)
				(setf (cnc:cmd-target jmp) (length *cnc*)
					*label* label *newlines* newlines))
			())
		(parse-group
			(transform-result
				#'(lambda (l)
					(vector-push-extend
						(cnc:make-cmd :opcode :JMP :target (+ 2 (length *cnc*))
							:var *label* :low (nth 0 l) :high (nth 1 l))
						*cnc*)
					(let ((jmp (cnc:make-cmd :opcode :JMP)))
						(vector-push-extend jmp *cnc*)
						(push (list jmp *label* *newlines*) *blocks*))
					())
				(parse-group (process-range) (p-eql #\Lcur)))
			#'process-sequence
			(p-eql #\Rcur))))

(defun PROCESS-SEQUENCE (l) ; recursive
	(funcall
		(parse-some
			(parse-or
				(process-block)
				(process-print)
				(process-syndrome)
				(process-label)
				(process-jump)
				(process-stop))) l))

(defmacro PROCESS-CNC () '#'process-sequence)

(defun READ-CNC (inp)
	(let ((*cnc* (make-array '(0) :adjustable t :fill-pointer 0))
			(*blocks* nil) (*jtab* (make-hash-table)) (*btab* (make-hash-table))
			(*label* nil) (*newlines* nil))
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
	(test-cnc "BASIC" "X 1 2 +(hello) Y 2 (world)"
		(coerce
			`(,(cnc:make-cmd :opcode :PRN :target (format nil "~%hello")
					:var "X" :low 1 :high 2)
				,(cnc:make-cmd :opcode :PRN :target "world"
					:var "Y" :low 2 :high 2))
			'vector))
	(test-cnc "BOUNCE" "X -> +Y Y ->- X"
		(coerce
			`(,(cnc:make-cmd :opcode :JMP :target 1 :var "X" :low cnc:-inf :high cnc:-inf)
				,(cnc:make-cmd :opcode :JMP :target 0 :var "Y" :low cnc:-inf :high cnc:-inf))
			'vector))
	(test-cnc "JUMPS" "X -> +X X ->+ X X"
		(coerce
			`(,(cnc:make-cmd :opcode :JMP :target 1 :var "X" :low cnc:-inf :high cnc:-inf)
				,(cnc:make-cmd :opcode :JMP :target 2 :var "X" :low cnc:-inf :high cnc:-inf))
			'vector))
	(test-cnc "IFDEF" "X * (xyz)"
		(coerce
			`(,(cnc:make-cmd :opcode :PRN :target "xyz"
					:var "X" :low cnc:-inf :high cnc:+inf))
			'vector))
	(test-cnc "NA" "X ? (xyz)"
		(coerce
			`(,(cnc:make-cmd :opcode :PRN :target "xyz"
					:var "X" :low cnc:+inf :high cnc:-inf))
			'vector))
	(test-cnc "BLOCK" "X 1 2 {(xyz)}"
		(coerce
			`(,(cnc:make-cmd :opcode :JMP :var "X" :target 2 :low 1 :high 2)
				,(cnc:make-cmd :opcode :JMP :target 3)
				,(cnc:make-cmd :opcode :PRN :target "xyz"
					:var "X" :low cnc:-inf :high cnc:-inf))
			'vector))
	(test-cnc "SYNDROME" "X {1 2 A 2 2 B: A C: 3}"
		(coerce
			`(,(cnc:make-cmd :opcode :CLR :target "X")
				,(cnc:make-cmd :opcode :INC :target "X" :var "A" :low 1 :high 2 :op1 1)
				,(cnc:make-cmd :opcode :INC :target "X" :var "B" :low 2 :high 2 :op1 "A")
				,(cnc:make-cmd :opcode :INC :target "X"
					:var "C" :low cnc:-inf :high cnc:-inf :op1 3))
			'vector))
	t)
