; $Id: qst-lesy-package.lisp,v 1.4 2005/09/07 10:10:57 dvd Exp $

(defpackage "QST-LESY"
	(:documentation "QST legacy syntax parser")
	(:use "COMMON-LISP" "UTIL")
	(:export "READ-QST" "QST-PARSE-ERROR"))
(in-package "QST-LESY")
