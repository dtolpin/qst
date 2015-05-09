; $Id: qst-lesy-guard.lisp,v 1.11 2006/05/25 22:03:06 dvd Exp $
; parser for legacy syntax guard expressions

(in-package "QST-LESY")

(defun GUARD (str)
	"(guard str)
	parses guard expression, returns a syntax tree"
	(and (/= (length str) 0)
		(let* (
				(end-of-name
					(or
						(and (digit-char-p (char str 0)) 0)
						(position-if 
							(lambda (x) (member x '(#\= #\< #\> #\!)))
							str)
						(length str)))
				(name 
					(and (> end-of-name 0) (qst:intern-name (subseq str 0 end-of-name))))
				(conds 
					(mapcar
						#'(lambda (s)
							(cond
							 	((digit-char-p (char s 0)) 
									(format nil "==~A" s))
								((and (char= (char s 0) #\=) (char/= (char s 1) #\=))
									(format nil "=~A" s))
								((and (> (length s) 2) (string= (subseq s 0 2) "<>"))
									(format nil "!=~A" (subseq s 2)))
							  (t s)))
						(tokenize #\, (subseq str end-of-name)))))
			(qst:make-guard :name name :eigen (null name) :conditions conds))))

(defun GUARD-TEST ()
	(assert (null (guard "")))
	(assert (equalp (guard "A")
		(qst:make-guard :name (qst:intern-name "A") :eigen nil :conditions nil)))
	(assert (equalp (guard ">0")
		(qst:make-guard :name nil :eigen t :conditions '(">0"))))
	(assert (equalp (guard "0,1,2")
		(qst:make-guard :name nil :eigen t :conditions '("==0" "==1" "==2"))))
	(assert (equalp (guard "Abc=0,1,<>2")
		(qst:make-guard :name (qst:intern-name "Abc") :eigen nil
			:conditions '("==0" "==1" "!=2"))))
	(assert (equalp (guard ">3,<1")
		(qst:make-guard :name nil :eigen t :conditions '(">3" "<1"))))
	t)

(eval-when (:execute :load-toplevel) (guard-test))