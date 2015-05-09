; $Id: qst-lesy-pack.lisp,v 1.26 2005/11/03 23:05:43 dvd Exp $

(in-package "QST-LESY")

(defparameter newline-string "
")

(defun PACK (name guard questions)
	"transforms qst-lesy to qst"
	(labels (
			(MAKE-QUESTIONS (questions &optional (question nil) (grouped nil))
				"turns patterns into qst questions"
				(labels (
						(FOLD (question)
							"folds lines comprising a single question into
							a pair with list of text and patterns in car,
							and pattern offsets in cdr"
							(let* (
									(lastline (car (last question)))
									(patterns (remove-if (complement #'consp) (car lastline)))
									(pattern-count (length patterns))
									(offsets
										(cons
											(and (> pattern-count 1) (> (length question) 1))
											(mapcar #'cdr patterns))))
								(do* ((items
											(mapcan
													(lambda (line) (cons newline-string (car line)))
												question)
											(cdr items))
										(item (car items) (car items))
										(names
											(let ((names (cdr lastline)))
												(if (or (null names) (<= pattern-count (length names)))
													names
													(let ((name (car names))) ; variable groups
														(do ((names ()) (i pattern-count (1- i)))
															((= i 0) names)
															(push 
																(qst:intern-name (format nil "~A/~A" name i))
																names))))))
										(question nil) (range nil) (options nil))
									((null items)
										(when (consp (cdr question)) ; ignore empty questions
											(setf (car (last question)) "") ; wipe last newline
											(cons (reverse-joining question) offsets)))
									(etypecase item
										(option (push item options))
										(range (setf range item))
										(cons
											(let ((pattern (pattern-pattern (car item))) (name (pop names)))
												(push
													(cond
														((string= "..." pattern) (qst:make-freeform :name name))
														((string= "&" pattern) (qst:make-ref :name name))
														((find #\. pattern)
															(qst:make-numeric :name name
																:prec (1- (- (length pattern) (position #\. pattern)))
																:min (if range (range-min range)
																	(- (expt 10 (position #\. pattern))))
																:max (if range (range-max range)
																	(expt 10 (position #\. pattern)))))
														(options
															(qst:make-choice :name name
																:options
																	(mapcar
																		(lambda (o)
																			(cons (option-value o) (option-label o)))
																		(nreverse options))))
														((or range (string/= pattern "*"))
															(qst:make-numeric :name name :prec 0
																:min (if range (range-min range) 0)
																:max (if range (range-max range)
																		(1- (expt 10 (length pattern))))))
														(t (qst:make-check :name name)))
													question))
											(setf range nil options nil))
										(string (push item question))))))
						(FLUSH (question grouped)
							"add a question to the list"
							(let ((question (fold question)))
								(if question (cons question grouped) grouped))))
					(if (consp questions)
						(let ((line (car questions)))
							(etypecase line
								(qst:section
									(make-questions (cdr questions) '()
										(cons line (flush question grouped))))
								(list
									(if (and question
											(member-if
												#'(lambda (x)
													(and (consp x) (typep (car x) 'pattern)))
												(car line)))
										(make-questions (cdr questions) (list line)
											(flush question grouped))
										(make-questions (cdr questions) (cons line question)
											grouped)))))
						(flush question grouped))))
						
				(BIND-IMPLICIT (questions)
					"binds questions with implicit names to variables"
					(do* ((i 0) (question (car questions) (car questions))
							(questions (cdr questions) (cdr questions)))
						((null question))
						(when (consp question)
							(let ((fields (remove-if (complement #'qst:field-p) (car question))))
								(when fields
									(when (null (qst:field-name (car fields)))
										(incf i) ; only nameless questions are numbered contiguously
										(if (= (length fields) 1)
											(setf (qst:field-name (car fields)) 
												(qst:intern-name (format nil "~A_~A" name i)))
											(do ((j 1 (1+ j)) (field (car fields) (car fields))
													(fields (cdr fields) (cdr fields)))
													((null field))
												(setf (qst:field-name field)
													(qst:intern-name (format nil "~A_~A/~A" name i j))))))
									(if (and guard (null (qst:guard-name guard)))
										(setf (qst:guard-name guard) (qst:field-name (car fields))))))))
					questions)
							
				(MAKE-GRIDS (questions)
					"recognizes and builds grids"
					; a line of dashes is frequent between the header and the data

					(labels (
							(FIND-GRID (questions with-grids)
								"go through the list of questions looking for a grid"
								(if (null questions) (nreverse with-grids)
									(let ((q (car questions)))
										(if (consp q)
											(if (cadr q)
												(maybe-start-grid questions with-grids)
												(find-grid (cdr questions) (cons (car q) with-grids)))
											(find-grid (cdr questions) (cons q with-grids))))))

							(MAYBE-START-GRID (questions with-grids)
								"start a grid"
; this is a nightmare:
; find two last lines in the text, 
; then the last line is either the header 
; or a rule drawn in ASCII art, and the header is the line before it
; if the line is long enough to be the header, start a grid
								(let* ((q (car questions))
										(header (caar q))
										(offsets (cddr q))
										(p0 (1+ (position #\Newline header :from-end t)))
										(p1 (1+ 
											(or (position #\Newline header :from-end t :end (1- p0)) -1)))
										(p2 (and (/= p1 0) (1+ 
											(or (position #\Newline header :from-end t :end (1- p1)) -1))))
								  	(with-rule
								  		(and p2 (not 
								  			(find-if (lambda (x) (member x '(#\Space #\Tab)))
								  				(string-trim '(#\Space #\Tab) (subseq header p1 (1- p0))))))))
								  (multiple-value-bind 
								  		(ps pe) (if with-rule (values p2 p1) (values p1 p0))
								  	(if (> (- pe ps) (car (last offsets))) 
											(cont-grid (cdr questions) offsets  
												(list 
													(cons (subseq header p0) (cdar q))
													(subseq header ps pe)) 
												(if (> ps 0) ; preceding content -- table caption?
													(cons
														(list (subseq header 0 ps))
														with-grids)
													with-grids))
											(find-grid (cdr questions) (cons (car q) with-grids))))))

							(CONT-GRID (questions offsets grid-rows with-grids)
								"add a row to the grid"
								(if (null questions) (end-grid questions offsets grid-rows with-grids)
									(let ((q (car questions)))
										(if (and (consp q) (equal (cddr q) offsets))
											(cont-grid (cdr questions) offsets (cons (car q) grid-rows)
												 with-grids)
											(end-grid questions offsets grid-rows with-grids)))))
												
							(END-GRID (questions offsets grid-rows with-grids)
								"add the grid to the output"
								(let ((rows (length grid-rows)) (cols (1+ (length offsets))))
									(let ((grid (make-array (list rows cols))))
										(do ((i (1- rows) (1- i)) 
												(row (car grid-rows) (car grid-rows))
												(grid-rows (cdr grid-rows) (cdr grid-rows)))
											((zerop i)
												(do ((j 0 (1+ j)) 	
														(iprev 0 i) (i (car offsets) (car offsets))
														(offsets (cdr offsets) (cdr offsets)))
													((= j (- cols 1))
														(setf (aref grid 0 j) (subseq row iprev))
														(find-grid questions (cons grid with-grids)))
													(loop 
														(when (= i iprev) (return))
														(when (space-char-p (char row i))
															(incf i)
															(return))
														(decf i))
													(setf (aref grid 0 j) (subseq row iprev i))))
											(do ((j 0 (1+ j)) (cell (car row) (car patterns))
													(patterns
														(remove-if (complement #'qst:field-p) row) (cdr patterns)))
												((= j cols))
												(setf (aref grid i j) cell)))))))
						(find-grid questions '()))))
		(make-grids (bind-implicit (make-questions questions)))))

