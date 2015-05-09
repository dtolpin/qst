#!/usr/local/bin/clisp -norc -M /Users/dvd/Workplace/Davidashen/QST/qst-cgi.clisp -q -q

#+clisp (progn
	(setf custom:*terminal-encoding* charset:utf-8)
	(setf custom:*default-file-encoding* charset:utf-8))

(qst-cgi:translate)

