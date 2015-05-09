; $Id: qst-lesy.lisp,v 1.53 2005/04/03 17:56:17 dvd Exp $

; A parser for the legacy QST format, kept since PS0;
; [the authors claim that] it is convenient for non-programmers.

(in-package "QST-LESY")

(defstruct LINE "single parsed line"
	mark question)

(defstruct (PATTERN (:constructor make-new-pattern))
	"question entry pattern"
	pattern)

(let ((pattab (make-hash-table :test #'equal)))
	(defun MAKE-PATTERN (&key pattern)
		"intern a question pattern"
		(let ((p (gethash pattern pattab)))
			(or p
				(setf (gethash pattern pattab)
					(make-new-pattern :pattern pattern))))))

(defstruct ATTRIBUTE "question attribute")
(defstruct (OPTION (:include attribute))
	value label)
(defstruct (RANGE (:include attribute))
	min max)

(defvar *lineno* nil "current line number for error reporting")

(define-condition QST-PARSE-ERROR (error)
	((message :initarg :message) 
		(lineno :initarg :lineno) (args :initarg :args))
	(:report 
		(lambda (condition stream)
			(with-slots (message lineno args) condition
				(apply #'format stream (concatenate 'string "line ~S: " message) 
					lineno args)))))

(defmacro ENSURE (test-form message &rest args)
	"(ensure test-form message &rest args)
	reports QST error by calling error"
	`(unless ,test-form
		(cerror "weird things will happen~*" 'qst-parse-error
			:message ,message
			:lineno *lineno*
			:args `(,,@args))))

(defun SPACE-CHAR-P (cc)
	"(space-char-p cc)
	whether the character is a space character in the legacy syntax of QST"
	(member cc '(#\Tab #\Space #\Return)))

(eval-when (:compile-toplevel :execute)
	(setf *readtable* (copy-readtable))
	(set-dispatch-macro-character #\# #\\ #'name-parentheses))

(defun PARSE-PARTS (l &key mstart qstart)
	"makes line"
	(let* (
			(question

				(labels (
						(ADD-PATTERN (q i0 i end)
							(let* (
									(lastspace
										(and (= end (length l))
											(position-if #'space-char-p l
												:start i :end end :from-end t)))
									(bodyend
										(when (and lastspace 
												(not 
													(find-if (lambda (x) (member x '(#\. #\*)))
														(subseq l lastspace))))
											lastspace)))
								(scan-question
									(cons
										(cons
											(make-pattern :pattern (subseq l i0 i))
											i0) ; cdr is the offset, useful for catching tables
										q)
									i i
									(or bodyend end)))) 

						(SCAN-QUESTION (q i0 i end)
							(flet (
									(SCAN-OPTION (j)
										(if (and (< j end) (digit-char-p (char l j)))
											(multiple-value-bind (n j)
													(parse-fixnum l :start j :end end)
												(scan-question
													(cons
														(make-option :value n
															:label (string-trim '(#\Space #\Tab) 
																	(subseq l i0 i)))
														q)
													j j end))
											(scan-question q i0 j end)))

									(SCAN-RANGE (j)
										(when (and (< j end) (digit-char-p (char l j)))
											(multiple-value-bind (n j)
													(parse-fixnum l :start j :end end)
											 	(when (and
													 	(< (+ j 1) end)
														(char= (char l j) #\-)
														(digit-char-p (char l (+ j 1))))
													(multiple-value-bind (m j)
															(parse-fixnum l :start (+ j 1) :end end)
														(return-from scan-range
															(scan-question
																(list* (make-range :min n :max m)
																	(subseq l i0 j) ; keep in the text
																	q)
																j j end))))))
										(scan-question q i0 j end))

									(SCAN-REF (j)
										(add-pattern (cons (subseq l i0 i) q) i j end))

									(SCAN-FIXNUM (j)
										(labels (
												(END-OF-*.* (k &optional dot)
													"returns the end of fixnum pattern"
													(cond
														((= k end) k)
														((char= (char l k) #\*)
															(end-of-*.* (1+ k) dot))
														((and (not dot) (char= (char l k) #\.)
																(/= (1+ k) end) (char= (char l (1+ k)) #\*))
															(end-of-*.* (+ 2 k) t))
														(t k))))
											(add-pattern (cons (subseq l i0 i) q) i 
												(end-of-*.* j) end)))

									(SCAN-FREEFORM (j)
										(let ((k (+ 3 i)))
											(if	(and (>= end k)
														(string= l "..." :start1 i :end1 k))
												(add-pattern (cons (subseq l i0 i) q) i k end)
												(scan-question q i0 j end)))))

								(if (= i end)
									(values (reverse-joining (cons (subseq l i0 i) q)) end)
									(let ((j (1+ i)))
										(case (char l i)
											(#\- 
												(if (space-char-p (char l (1- i)))
													(scan-option j)
													(scan-question q i0 j end)))
											(#\Lpar (scan-range j))
											(#\& (scan-ref j))
											(#\* (scan-fixnum j))
											(#\. (scan-freeform j))
											(t (scan-question q i0 j end))))))))

					(multiple-value-bind (sentence nstart)
							(scan-question
								(list (make-string qstart :initial-element #\Space))
								qstart qstart (length l))
						(cons
							sentence
							(mapcar #'qst:intern-name
								(tokenize-on '(#\, #\; #\Space #\Tab) l :start nstart))))))

			(mark
				(cond
					((not mstart) '(cont))
					((let ((lpar (position #\Lpar l :start mstart :end qstart)))
						(when lpar
							(let ((rpar 
									(position #\Rpar l :start lpar :end qstart :from-end t)))
								(ensure rpar "missing right parenthesis")
								(cons 'begin
									(lambda (questions)
										(make-section
											:name (qst:intern-name (subseq l mstart lpar))
											:guard ; qst-lesy-guard.lisp
												(guard (subseq l (1+ lpar) rpar)) 
											:title
											  (unless (char= (char l (1- qstart)) #\#)
											  	(let (
											  			(title
																(string-trim '(#\Space #\Tab)
																	(apply #'concatenate 'string
																		(remove-if (complement #'stringp) 
																			(car question))))))
														(and (plusp (length title)) title)))
											:questions questions)))))))
					(t
						(cons 'end
							(mapcar #'qst:intern-name
								(tokenize-on '(#\, #\; #\Space #\Tab) l
									:start mstart :end qstart)))))))
		(make-line :mark mark :question question)))

(defun PARSE-VERBATIM (l)
	"parses line verbatim -- everything is treated as text, patterns are ignored"
	(make-line :mark '(cont) :question `((,l))))


(defun MAKE-SECTION (&key name guard title questions)
	"creates section"
	(qst:make-section
		:name name
		:guard guard
		:title title
		:questions (pack name guard questions))) ; qst-lesy-pack.lisp

(defun READ-QST (inp)
	"reads legacy syntax"
	(flet ((read-line-rtrim () 
			(handler-case 
				(string-right-trim '(#\Return #\Space #\Tab) (read-line inp)) 
				(end-of-file (cond) (declare (ignore cond)) nil))))
		(let ((*lineno* 0)
				(verbatim nil)
				(lnext (read-line-rtrim)))
			(labels (
					(READ-LINE-JOINING (inp l) ; one-line look-ahead
						"read line, possibly joining with subsequent lines starting with \\,
						opposite to all other margin marks, backslash is removed from the
						line, not replaced with space"
						(when l
							(incf *lineno*)
							(setf lnext (read-line-rtrim))
							(if (and lnext (/= (length lnext) 0) (char= (char lnext 0) #\\))
								(read-line-joining inp 
									(concatenate 'string l (subseq lnext 1)))
								l)))
	
					(NEXTLINE ()
						"read line, split into parts"
						(let ((l (read-line-joining inp lnext)))
							(cond
								((not l) nil)
								((or (= (length l) 0) (space-char-p (char l 0)))
									(if verbatim
										(parse-verbatim l)
										(parse-parts l :mstart nil :qstart 0)))
								(t
									(if verbatim
										(progn
											(when (char= (char l 0) #\Rsqr)
												(setf verbatim nil)
												(setf (char l 0) #\Space))
											(parse-verbatim l))
										(case (char l 0)
											(#\| (nextline)) ; comment
											(#\Lcur (nextline)) ; parameters
											(#\Lang (nextline)) ; CNC here
											(#\Lsqr (setf verbatim t) ; verbatim section
												(setf (char l 0) #\Space)
												(parse-verbatim l))
											(t
												(parse-parts l :mstart 0
													:qstart (or
														(position-if #'space-char-p l)
														(length l))))))))))
	
					(READ-SECTION (make-section line questions)
						"read section, recursively"
						(if line
							(let ((mark (line-mark line)))
								(ecase (car mark)
									(begin
										(multiple-value-bind (subsect line)
												(read-section (cdr mark)
													(make-line :mark '(cont) 
														:question (line-question line))
													'())
											(read-section make-section
												line (cons subsect questions))))
									(cont
										(read-section make-section
											(nextline) (cons (line-question line) questions)))
									(end
										(ensure (functionp make-section)
											"orphaned end of section ~S" (cadr mark))
										(let (
												(section
													(funcall make-section ; fold questions here
														(cons (line-question line) questions))))
											(let (
													(got (cadr mark)) 
													(expected (qst:section-name section)))
												(ensure (eq got expected)
													"got ~S, expected ~S" got expected))
											(values section
												(if (cddr mark)
													(make-line :mark (cons (car mark) (cddr mark)))
													(nextline)))))))
	
							(progn ; end of input
								(ensure (null make-section)
									"unbalanced section ~A at the end of file" 
									(qst:section-name (funcall make-section nil)))
								(reverse (remove-if (complement #'qst:section-p) questions))))))
	
					(read-section nil (nextline) '())))))
