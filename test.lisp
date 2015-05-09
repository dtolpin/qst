(defvar x 0)

(defun test (&optional (x x))
	(when (< x 100)
		(print x)
		(let ((x (1+ x))) (test))))
