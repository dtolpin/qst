; $Id: cnc-cl.lisp,v 1.5 2005/11/03 23:05:43 dvd Exp $

(defpackage "CNC-CL"
	(:documentation "CNC interpreter in Common Lisp")
	(:use "COMMON-LISP" "CNC")
	(:export "*VARTAB*" "*CONCLUSION-OUTPUT*" "MAKEFUN"))
(in-package "CNC-CL")

(defvar *vartab* nil "hash table with symptom and syndrome values")
(defvar *conclusion-output* nil "stream to write the conclusion to")

(defparameter punctuation-characters ",;.:"
	"two punctuation characters around a phrase break collapse")

(defun FIRES (cmd)
	(let ((var (cmd-var cmd)) (low (cmd-low cmd)) (high (cmd-high cmd)))
		(or (null var) (= low high -inf)
			(let ((val (gethash var *vartab*)))
				(cond
					((and (= low -inf) (= high +inf)) (not (null val)))
					((and (= low +inf) (= high -inf)) (null val))
					(t (and (numberp val) (<= low val) (<= val high))))))))

(defun OPVAL (x)
	(if (stringp x)
		(gethash x *vartab*)
		x))

(defmacro GENCODE (&body body)
	`#'(lambda ()
		(when (fires cmd)
			,@body)
		(funcall (svref code (1+ addr)))))

; for legacy syntax
(defmacro GENCODE-OP (fun)
	`(gencode
		(setf (gethash (cmd-target cmd) *vartab*)
			(,fun (or (opval (cmd-op1 cmd)) 0) (or (opval (cmd-op2 cmd)) 0)))))

(defvar *last-punctuation*)

(defun MAKEFUN (cnc)
	"creates CNC interpreter; the function must be called in a dynamic
	environment where *conclusion-output* and *vartab* are bound"
	(let ((code (make-array (list (1+ (length cnc))))))
		(setf (svref code (length cnc))
			#'(lambda ()
					(when (and *conclusion-output* *last-punctuation*)
						(princ *last-punctuation* *conclusion-output*))
					nil))
		(dotimes (addr (length cnc) 
				(lambda () 
					(let (*last-punctuation*)
						(funcall (svref code 0)))))
			(let ((cmd (aref cnc addr)) (addr addr))
				(setf (svref code addr)
					(ecase (cmd-opcode cmd)
						(:CLR (gencode (setf (gethash (cmd-target cmd) *vartab*) 0)))
						(:INC (gencode 
							(incf (gethash (cmd-target cmd) *vartab*) (or (opval (cmd-op1 cmd)) 0))))
						(:JMP
							(let ((alt (cmd-target cmd)))
								(when (= (cmd-target cmd) +inf) (setf alt (length cnc)))
								#'(lambda () (funcall (svref code (if (fires cmd) alt (1+ addr)))))))
						(:PRN (gencode
							(when *conclusion-output*
								(let* ((s (cmd-target cmd))
										(i (position #\* s)) (j (position #\* s :from-end t)))
									(when i
										(setf s (format nil 
											(concatenate 'string (subseq s 0 i) "~A" (subseq s (1+ j))) 
											(or (gethash (cmd-var cmd) *vartab*) ""))))
									(when (and *last-punctuation* 
											(or (zerop (length s)) 
												(not (position (char s 0) punctuation-characters))))
										(princ *last-punctuation* *conclusion-output*))
									(setf *last-punctuation*
										(and (plusp (length s)) 
											(find (char s (1- (length s))) punctuation-characters)))
									(when *last-punctuation*
										(setf s (subseq s 0 (1- (length s)))))
									(princ s *conclusion-output*)))))
						(:ADD (gencode-op +))
						(:SUB (gencode-op -))
						(:MUL (gencode-op *))
						(:DIV (gencode-op /))))))))
