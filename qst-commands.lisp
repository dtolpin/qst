(in-package "CL-USER")

(defun QST-TO-HTML (qname cname oname)
	(with-open-file (out oname :direction :output
			:if-exists :supersede :if-does-not-exist :create)
		(qst-html:serialize out
			(with-open-file (inp qname :direction :input)
				(qst-lesy:read-qst inp))
			(with-open-file (inp cname :direction :input)
				(let ((file-type (pathname-type (pathname cname))))
					(cond
						((string-equal file-type "cnd")
							(cnc-nova:read-cnc inp))
						((string-equal file-type "cnc")
							(cnc-lesy:read-cnc inp))
						(t (error "file type of 'cnc' or 'cnd' is required")))))))
	t)

(defun CNC-TO-DOT (cname oname)
	(with-open-file (out oname :direction :output
			:if-exists :supersede :if-does-not-exist :create)
		(cnc-dot:serialize out
			(with-open-file (inp cname :direction :input)
				(let ((file-type (pathname-type (pathname cname))))
					(cond
						((string-equal file-type "cnd")
							(cnc-nova:read-cnc inp))
						((string-equal file-type "cnc")
							(cnc-lesy:read-cnc inp))
						(t (error "file type of 'cnc' or 'cnd' is required")))))))
	t)

(defun main (args)
	(unless args
		(error "usage: ~A dialogue.qst [dialogue.cnc [dialogue.html]]" 
			(pathname-name *load-pathname*)))
	(let ((cntyp "cnc") (quiet nil))
		(loop (when (or (null args) (not (eql (position #\- (car args)) 0))) (return))
			(cond
				((string= (car args) "-n") (pop args) (setf cntyp "cnd"))
				((string= (car args) "-l") (pop args) (setf cntyp "cnc"))
				((string= (car args) "-q") (pop args) (setf quiet t))
				(t (format *error-output* "invalid command-line option ~S~%" (pop args)))))
		(let* (
				(qst (merge-pathnames (nth 0 args) (make-pathname :type "qst")))
				(cnc 
					(if (nth 1 args)
						(merge-pathnames (nth 1 args) (make-pathname :type cntyp))
						(make-pathname :type cntyp :defaults qst)))
				(html
					(if (nth 2 args)
						(merge-pathnames (nth 2 args) (make-pathname :type "html"))
						(make-pathname :type "html" :defaults qst))))
			(unless quiet 
				(apply #'format *error-output* "Converting ~S with ~S into ~S...~%" 
					(mapcar #'namestring (list qst cnc html))))
			(qst-to-html qst cnc html)
			(unless quiet (format *error-output* "~&Done.~%")))))

(eval-when (:load-toplevel :execute) (qst-lesy::test))
