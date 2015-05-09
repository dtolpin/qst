; $Id: cnc.lisp,v 1.18 2005/09/12 17:53:48 dvd Exp $

(defpackage "CNC"
	(:documentation "internal representation of syndrome network")
	(:use "COMMON-LISP" "UTIL")
	(:export "-INF" "+INF"
		"DEPENDENCIES" "INFLUENCES" "RANKS"))
(in-package "CNC")

(defextruct (cmd (:type list))
"clr target
inc target var low high op1
add target var low high op1 op2
sub target var low high op1 op2
mul target var low high op1 op2
div target var low high op1 op2
jmp target var low high
prn string var low high

op1,op2 ::= name | number .
low,high ::= number .
var,target ::= name ."

	opcode
	target 
	var low high
	op1 op2)

(defconstant -inf -2147483648)
(defconstant +inf +2147483647)

(defmacro GETASS (item list)
		"if assoc returns nil, adds (list item) to the list and returns it,
		otherwise, the same as assoc. Used by DEPS"
	(let ((assoc (gensym)) (itemvalue (gensym)))
		`(let* (
				(,itemvalue ,item)
				(,assoc (assoc ,itemvalue ,list)))
			(or ,assoc
				(let ((,assoc (list ,itemvalue)))
					(push ,assoc ,list)
					,assoc)))))

(defun DEPENDENCIES (cnc)
		"collects all variables used in CNC into alist
		(var . (list var1 .. varn)); var depends on var1 .. varn."
	(let ((deps ()))
		(dotimes (i (length cnc) deps)
			(let ((cmd (aref cnc i)))
				(case (cmd-opcode cmd)
					((:PRN :JMP))
					(:CLR (setf (cdr (getass (cmd-target cmd) deps)) ()))
					(t (when (cmd-var cmd)
						(push (cmd-var cmd) (cdr (getass (cmd-target cmd) deps))))))
				(when (cmd-var cmd) ; just mark
					(getass (cmd-var cmd) deps))))))

(defun INFLUENCES (deps)
		"inverts dependencies"
		(mapcar
			#'(lambda (dep)
				(let ((var (car dep)))
					(cons (car dep)
						(mapcar #'car	
							(remove-if
								#'(lambda (dep) (not (member var (cdr dep))))
								deps)))))
			deps))

(defun RANKS (deps)
		"splits dependencies into ranks; a target is higher in rank
		than a variable	it depends on. The result is a list 
		of ranks."
	(rank deps ()))

(defun RANK (deps ranks)
		"recursively adds ranks by splitting dependencies:
		Let's put all variables in the first rank. Move all
		variables from the first rank that depend on variables from
		the first rank to the second rank, and so on. If after a
		certain step, the rank becomes empty, stop: this is a
		circular dependency. if there is nothing to upgrade, stop: all done."
	(if (null deps) ranks
		(multiple-value-bind (upper lower) (split deps)
			(when (null lower) ; circular dependency
				(psetf lower upper upper lower))
			(rank upper (cons (mapcar #'car lower) ranks)))))

(defun SPLIT (deps)
		"splits dependencies into upper and lower ranks"
	(let ((vars (mapcar #'car deps)))
		(labels (
				(ROUTE (flat upper lower)
					(if (null flat) (values upper lower)
						(let ((dep (car flat)))
							(if (intersection (cdr dep) vars)
								(route (cdr flat) (cons dep upper) lower)
								(route (cdr flat) upper (cons dep lower)))))))
			(route deps () ()))))

(defun TEST ()
	; getass
	(let ((l '()))
		(assert (progn (getass 1 l) (equal l '((1)))))
		(assert (progn (getass 1 l) (equal l '((1)))))
		(assert (progn (setf (cdr (getass 1 l)) (list "a")) (equal l '((1 "a")))))
		(assert (progn (push "b" (cdr (getass 1 l))) (equal l '((1 "b" "a")))))
		(assert (progn (push 'b (cdr (getass 2 l))) (equal l '((2 b) (1 "b" "a"))))))

	; split
	(assert (equal (multiple-value-list (split '((1) (2)))) '(() ((2) (1)))))
	(assert (equal (multiple-value-list (split '((1 2) (2 1))))
		'(((2 1) (1 2)) ())))
	(assert (equal (multiple-value-list (split '((1 2) (2))))
		'(((1 2)) ((2)))))
	t)

(eval-when (:execute :load-toplevel)
	(test))
