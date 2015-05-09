f; $Id: scratch.lisp,v 1.12 2005/09/05 10:10:02 dvd Exp $ 

;; Frequently used commands

(cd "/Users/dvd/Workplace/Davidashen/QST") 
(cd "/Users/dvd/Workplace/Davidashen/CL-UTILS")

(mk:oos :qst :load)
(mk:oos :qst :compile :force t)

(main '("Examples/Cardio"))

(main '("Examples/seleng")) 
(main '("-n" "Examples/seleng"))

(main '("Examples/eeg0-8" "Examples/eeg8")) 
(main '("Examples/eeg0" "Examples/eeg"))

(cnc-to-dot "Examples/seleng.cnc" "Examples/seleng.dot")

;; temporary

; drawing ranked tables
(with-open-file (out "test.html" :direction :output :if-exists :supersede)
	(format out "<html><head><script type=\"text/javascript\">")
	(cnc-html:paint out ranks)
	(format out "</script></head><body>")
	(cnc-html:serialize out ranks)
	(format out "</body></html>"))

(mapcan #'qst:questions
	(with-open-file (inp "Examples/eeg.qst" :direction :input)
		(qst-lesy:read-qst inp)))
		
; variables in ranks
(cnc:ranks
	(with-open-file (inp "Examples/seleng.cnd" :direction :input) 
		(cnc-nova:read-cnc inp)))

(cnc:ranks
	(with-open-file (inp "Examples/eeg8.cnc" :direction :input) 
		(cnc-lesy:read-cnc inp)))

; probing cl interpreter for CNC
(progn
	(setq cnc-cl:*vartab* (make-hash-table) cnc-cl:*conclusion-output* *standard-output*)
	(mapc 
		(lambda (b) 
			(setf (gethash (qst:intern-name (car b)) cnc-cl:*vartab*) (cadr b)))
		'(("Pasp_2" "Vasya_Pupkin")
			("Pasp_3" 1)
			("Pasp_4" 3)
			("Rnt_1" 1)
			("AbdP_1" 1)))
	(setf runcnc
		(cnc-cl:makefun
			(with-open-file (inp "Examples/seleng.cnd" :direction :input) 
				(cnc-nova:read-cnc inp)))))

