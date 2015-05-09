; $Id: cnc-dot.lisp,v 1.1 2005/04/03 12:56:06 dvd Exp $

(defpackage "CNC-DOT"
	(:documentation "syndrome diagram (via graphviz)")
	(:use "COMMON-LISP")
	(:export "SERIALIZE"))
(in-package "CNC-DOT")

; clr target
; inc target var low high 

(defun SERIALIZE (out cnc)
	(format out "digraph CNC { size=\"8,8\"; ratio=\"fill\"; rankdir=\"LR\";~%")
	(do* ((i 0 (1+ i)) (cmd (aref cnc i) (aref cnc i)))
		((= i (length cnc)))
		(case (cnc:cmd-opcode cmd)
			(:CLR (format out "	~S;~%" (cnc:cmd-target cmd)))
			(:INC (format out "	~S->~S;~%" (cnc:cmd-var cmd) (cnc:cmd-target cmd)))))
	(format out "}~%"))