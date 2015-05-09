; $Id: util.lisp,v 1.28 2005/06/18 11:29:43 dvd Exp $

(defpackage "UTIL"
	(:documentation "common language utilities")
	(:use "COMMON-LISP")
	(:export
		"NAME-PARENTHESES"
		"WITH-TAIL-CALLS" "DEFEXTRUCT"
		"PARSE-FIXNUM" "TOKENIZE" "TOKENIZE-IF" "TOKENIZE-ON"
		"REVERSE-JOINING"))
(in-package "UTIL")

(defun NAME-PARENTHESES (inp c1 c2)
	(declare (ignore c1 c2))
	(let ((c (peek-char nil inp)))
		(cond
			((alpha-char-p c)
				(ecase (let ((*package* (find-package "UTIL"))) (read inp))
					(Lpar #\() (Rpar #\))
					(Lsqr #\[) (Rsqr #\])
					(Lcur #\{) (Rcur #\})
					(Lang #\<) (Rang #\>)
					(Tab #\Tab) (Space #\Space)
					(Return #\Return) (Newline #\Newline)))
			(t
				(read-char inp)))))

(defmacro DEFEXTRUCT (&rest args)
	(let (
			(name (if (listp (car args)) (caar args) (car args)))
			(fields 
				(mapcar 
					(lambda (x)
						(cond
							((symbolp x) x)
							((listp x) (car x))
							(t (error "cannot happen"))))
					(remove-if 
						(lambda (x)
							(or (stringp x)
								(and (listp x) (keywordp (car x)))))
						(cdr args)))))
		`(progn
			(export '(
				,@(mapcar #'intern
					(mapcar (lambda (f) (format nil f name)) 
						'("~A" "MAKE-~A" "COPY-~A" "~A-P")))
				,@(mapcar #'intern
					(apply #'nconc
						(mapcar
							(lambda (field)
								(mapcar (lambda (f) (format nil f name field)) 
									'("~A-~A")))
							fields)))))
			(defstruct ,@args))))

(defun PARSE-FIXNUM (str &key (start 0) end)
	"(parse-fixnum str &key start end)
	reads a decimal integer from the string,
	returns the integer and first non-numeric position after the integer"
	(declare (type string str) (type integer start)
		(type (or integer null) end))
	(unless end (setf end (length str)))
	(let* (
			(startx
				(if (and (< start end) (member (char str start) '(#\+ #\-)))
					(1+ start)
					start))
			(sign (if (or (= startx start) (char= (char str start) #\+)) 1 -1)))
			(declare (type integer startx))
		(do ((j startx (1+ j))
			(f 0 (+ (* f 10) (- (char-code (char str j)) (char-code #\0)))))
			((or (= j end) (not (digit-char-p (char str j))))
				(if
					(or (= j end) (not (char= (char str j) #\.)))
						(values (* sign f) j)
					(do ((j (1+ j) (1+ j))
						(n 10 (* n 10))
						(f f (+ f (/ (- (char-code (char str j)) (char-code #\0)) n))))
						((or (= j end) (not (digit-char-p (char str j))))
							(values (float (* sign f)) j))))))))

(defmacro DEFTOKENIZE (name pos)
	`(defun ,name (crit seq &key start end key)
		(declare (type (or integer null) start end))
		(let (
				(start (or start 0))
				(end (or end (length seq))))
			(labels (
					(TOKREC (tokens start)
						(let* (
								(pos
									(or (,pos crit seq :start start :end end :key key)
										end))
								(tokens
									(if (= start pos) tokens
										(cons (subseq seq start pos) tokens))))
							(if (= pos end) (reverse tokens)
								(tokrec tokens (1+ pos))))))
				(tokrec '() start)))))

(deftokenize TOKENIZE position)
(deftokenize TOKENIZE-IF position-if)
(defmacro TOKENIZE-ON (seplist seq &rest rest)
	`(tokenize-if (lambda (c) (member c ,seplist)) ,seq ,@rest))

(defun REVERSE-JOINING (list)
	"reverse the list joining consequitive strings"
	(reduce
		#'(lambda (v w)
			(cond
				((and (stringp (car v)) (stringp w))
					(setf (car v) (concatenate 'string w (car v)))
					v)
				((equal w "") (or v (cons w v)))
				((equal (car v) "")
					(setf (car v) w)
					v)
				(t (cons w v))))
		list
		:initial-value '()))

(defun TEST ()
; parse-fixnum
	(multiple-value-bind (n i) (parse-fixnum "123456abcd")
		(assert (equal n 123456))
		(assert (equal i 6)))
	(multiple-value-bind (n i) (parse-fixnum "")
		(assert (equal n 0))
		(assert (equal i 0)))
	(multiple-value-bind (n i) (parse-fixnum "a")
		(assert (equal n 0))
		(assert (equal i 0)))	
	(multiple-value-bind (n i) (parse-fixnum "a1234567ne" :start 2 :end 3)
		(assert (equal n 2))
		(assert (equal i 3)))	
	(multiple-value-bind (n i) (parse-fixnum ".1")
		(assert (equal n 0.1))
		(assert (equal i 2)))	
	(multiple-value-bind (n i) (parse-fixnum "1.")
		(assert (equal n 1.0))
		(assert (equal i 2)))	
	(multiple-value-bind (n i) (parse-fixnum "+1")
		(assert (equal n 1))
		(assert (equal i 2)))	
	(multiple-value-bind (n i) (parse-fixnum "1.a")
		(assert (equal n 1.0))
		(assert (equal i 2)))	
	(multiple-value-bind (n i) (parse-fixnum "1.2")
		(assert (equal n 1.2))
		(assert (equal i 3)))	
	(multiple-value-bind (n i) (parse-fixnum "-1.25")
		(assert (equal n -1.25))
		(assert (equal i 5)))	

; tokenize
	(assert (equal (tokenize #\, "a") '("a")))
	(assert (equal (tokenize #\, "a,b") '("a" "b")))
	(assert (equal (tokenize #\, "") '()))
	(assert (equal (tokenize #\,  ",,,ab,,,cd,,") '("ab" "cd")))
	(assert (equal (tokenize-on '(#\, #\;) "a,b;cd;ef,") '("a" "b" "cd" "ef")))
	(assert (equal (tokenize #\, "a,b,c,d" :start 1) '("b" "c" "d")))
	(assert (equal (tokenize #\, "a,b,c,d" :end 3) '("a" "b")))

; reverse-joining
	(assert (equal (reverse-joining nil) nil))
	(assert (equal (reverse-joining '("a")) '("a")))
	(assert (equal (reverse-joining '("")) '("")))
	(assert (equal (reverse-joining '("a" a)) '(a "a")))
	(assert (equal (reverse-joining '("" a)) '(a)))
	(assert (equal (reverse-joining '(a "")) '(a)))
	(assert (equal (reverse-joining '("" "a" "b" c "d" "e")) '("ed" c "ba")))
	t)
		
(eval-when (:load-toplevel :execute) (test))
