; $Id: qst-cgi.lisp,v 1.7 2005/09/23 09:47:47 dvd Exp $

(defpackage "QST-CGI"
	(:documentation "CGI interface to the QST compiler")
	(:use "COMMON-LISP")
	(:export "TRANSLATE"))
(in-package "QST-CGI")

(let (
		(rfc2388:*make-tmp-file-name* 
			(let ((counter 0))
				(lambda () (format nil "/tmp/qst-cgi-~S.tmp" (incf counter))))))
	(defun translate ()
		"accepts a CGI query and generates
			* upload page, if the query is empty
			* a compiled questionnaire, from the supplied qst and cnc sources
			* list of error messages, in case of query parser or questionnaire 
			  translation errors."
		(format t "Content-Type: text/html~%~%")
		(let (
				(query
					(handler-case
							(cgi:query)
						(error (cond) cond))))
			(cond
				((typep query 'error)
					(html-writer:serialize *standard-output*
						`("html"
							("head"
								("title" "QST: Invalid Query"))
							("body"
								("h1" "Error parsing request")
								("p" ,(format nil "~A: ~A" (type-of query) query))))))
				((cgi:query-parameters query)
					(let (
							(qst (car (cgi:get-values "qst" query)))
							(cnc (car (cgi:get-values "cnc" query)))
							(cnd (car (cgi:get-values "cnd" query)))
							(errors ()))
						(block compile
							(princ
								(with-output-to-string (outp)
									(catch 'fatal
										(handler-bind (
												(qst-lesy:qst-parse-error
													#'(lambda (cond)
															(push (format nil "QST: ~A" cond) errors)
															(invoke-restart (car (compute-restarts)))))
												((or cnc-lesy:cnc-parse-error cnc-nova:cnc-parse-error)
													#'(lambda (cond)
														(push (format nil "CNC: ~A" cond) errors)
														(invoke-restart (car (compute-restarts)))))
												(error
													#'(lambda (cond)
															(push (format nil "compilation aborted (~A)" cond) errors)
															(throw 'fatal nil))))
											(qst-html:serialize outp
												(cgi:with-input-from-mime (inp qst)
													(qst-lesy:read-qst inp))
												(multiple-value-bind (cnc read-cnc)
														(if (plusp (length (cgi:mime-filename cnd)))
															(values cnd #'cnc-nova:read-cnc)
															(values cnc #'cnc-lesy:read-cnc))
													(cgi:with-input-from-mime (inp cnc)
														(funcall read-cnc inp)))
												(let ((submit (first (cgi:get-values "submit" query))))
													(when (plusp (length submit)) submit)))))
									(when errors
										(html-writer:serialize *standard-output*
											`("html"
												("head"
													("title" "QST: Errors"))
												("body"
													("h1" "Errors translating questionnaire")
													("ul"
														,@(mapcar
															#'(lambda (s) `("li" ,s))
															(nreverse errors))))))
										(return-from compile)))))))
				(t
					(html-writer:serialize *standard-output*
						`("html"
							("head" ("title" "QST: Translator"))
							("body"
								("h1" "QST+CNC -> HTML")
								("form method='POST' enctype='multipart/form-data'"
									("table border='0'"
										("tr" ("th" "QST:")
											("td" ("input type='file' name='qst'"))
											    ("th" "Submit URL:")
											("td" ("input type='text' name='submit'")))
										("tr" ("th" "CNC (old syntax):")
											("td" ("input type='file' name='cnc'")))
										("tr"	("th" "CNC (new syntax):")
											("td" ("input type='file' name='cnd'"))))
									("p"
										("input type='submit' name='Translate'")))))))))))
