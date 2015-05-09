; $Id: qst-lesy-test.lisp,v 1.25 2005/03/28 00:15:05 dvd Exp $

(in-package "QST-LESY")

(defmacro TEST-EXPECT-PARSED (test-name src samp)
	`(with-input-from-string (inp (format nil ,src))
		(let (
				(qst (car (read-qst inp))	)
				(samp ,samp))
			(assert (equalp qst samp) nil (format nil "~S failed" ',test-name)))))

(defun TEST ()
	(test-expect-parsed BASIC
		"A() Title~%A Query"
		(qst:make-section :name (qst:intern-name "A") :title "Title"
			:questions `((,(format nil "    Title~%  Query")))))
			
	(test-expect-parsed JOINED-LINES
		"A() Title~%\\ Subtitle~%A Query"
		(qst:make-section :name (qst:intern-name "A")
			:title "Title Subtitle"
			:questions `((,(format nil "    Title Subtitle~%  Query")))))
			
	(test-expect-parsed NO-TITLE
		"A()# Title~%A Query"
		(qst:make-section :name (qst:intern-name "A") 
			:questions `((,(format nil "     Title~%  Query")))))
			
	(test-expect-parsed GUARD
		"A(ABC)~%A"
		(qst:make-section :name (qst:intern-name "A") :guard 
			(qst:make-guard 
				:name (qst:intern-name "ABC")
				:eigen nil
				:conditions nil)
			:questions `((,(format nil "      ~% ")))))
			
	(test-expect-parsed NESTED
		"A()~%B()~%B~%A"
		(qst:make-section :name (qst:intern-name "A")
			:questions `(("   ") 
				,(qst:make-section :name (qst:intern-name "B")
					:questions `((,(format nil "   ~% "))))
			(" "))))
			
	(test-expect-parsed NESTED-COLLAPSED-ENDS
		"A()~%B()~%B;A"
		(qst:make-section :name (qst:intern-name "A")
			:questions `(("   ")
				,(qst:make-section :name (qst:intern-name "B")
					:questions `((,(format nil "   ~%   ")))))))
				
	(test-expect-parsed NESTED-REPEATED
		"A()~%B()~%B~%B()~%B~%A"
		(qst:make-section :name (qst:intern-name "A")
			:questions `(("   ")
				,(qst:make-section :name (qst:intern-name "B") :guard nil
					:questions `((,(format nil "   ~% "))))
				,(qst:make-section :name (qst:intern-name "B") :guard nil
					:questions `((,(format nil "   ~% "))))
			(" "))))

	(test-expect-parsed PARENTHESES
		"A() Sex (gender)~%A"
		(qst:make-section :name (qst:intern-name "A") :title "Sex (gender)"
			:questions `(
				(,(format nil "    Sex (gender)~% ")))))

	(test-expect-parsed RANGE-*
		"A() Value (1-10): *~%A"
		(qst:make-section :name (qst:intern-name "A") :title "Value (1-10):"
			:questions `(
				("    Value (1-10): "
      		,(qst:make-numeric :name (qst:intern-name "A_1") 
      			:min 1 :max 10 :prec 0))
				(" "))))
				
	(test-expect-parsed RANGE-**.*
		"A() Value (1-10): **.*~%A"
		(qst:make-section :name (qst:intern-name "A") :guard nil :title "Value (1-10):"
			:questions `(
				("    Value (1-10): "
      		,(qst:make-numeric :name (qst:intern-name "A_1")
      			:min 1 :max 10 :prec 1))
				(" "))))
				
	(test-expect-parsed RANGE-VAR
		"A() Value (1-10): * X1~%A"
		(qst:make-section :name (qst:intern-name "A") :title "Value (1-10):"
			:questions `(
				("    Value (1-10): "
      		,(qst:make-numeric :name (qst:intern-name "X1") :min 1 :max 10 :prec 0))
				(" "))))
				
	(test-expect-parsed RANGE-VARS
		"A() Value (1-10): *,* X1,X2~%A"
		(qst:make-section :name (qst:intern-name "A") :title "Value (1-10): ,"
			:questions `(
				("    Value (1-10): "
      		,(qst:make-numeric :name (qst:intern-name "X1") :min 1 :max 10 :prec 0)
      		","
      		,(qst:make-check :name (qst:intern-name "X2")))
				(" "))))

	(test-expect-parsed TEXT-VAR
		"A() Value: ... A1~%A"
		(qst:make-section :name (qst:intern-name "A") :title "Value:"
			:questions `(
				("    Value: " 
					,(qst:make-freeform :name (qst:intern-name "A1")))
				(" "))))
				
	(test-expect-parsed OPTION
		"
A() Option -1
    Another -2: *
A"
		(qst:make-section :name (qst:intern-name "A")
			:questions `(
				(,(format nil "   ~%: ")
					,(qst:make-choice :name (qst:intern-name "A_1")
						:options '((1 . "Option") (2 . "Another")))) 
				(" "))))

	(test-expect-parsed VERBATIM
		"
A()
[Value (1-10): **
 second line
]third line
A"
		(qst:make-section :name (qst:intern-name "A")
			:questions `((
				,(format nil "   ~% Value (1-10): **~% second line~% third line~% ")))))

	(test-expect-parsed GRID1
		"
A()
 Questions Yes No Either
 Coffee    *   *  *
A"
		(qst:make-section :name (qst:intern-name "A") 
			:questions `((,(format nil "   ~%"))
				,(make-array '(2 4) :initial-contents
						`((" Questions " "Yes " "No " "Either
")						(" Coffee    "
							,(qst:make-check :name (qst:intern-name "A_1/1")) 
							,(qst:make-check :name (qst:intern-name "A_1/2"))
							,(qst:make-check :name (qst:intern-name "A_1/3")))))
				(" "))))

	(test-expect-parsed NOT-A-GRID
		"
A()
 Yes No
 Coffee    *   *
A"
		(qst:make-section :name (qst:intern-name "A") 
			:questions `((,(format nil "   ~% Yes No~% Coffee    ")
 					,(qst:make-check :name (qst:intern-name "A_1/1")) "   "
 					,(qst:make-check :name (qst:intern-name "A_1/2")))
 				(" "))))

(test-expect-parsed GRID-RULE
		"
A()
 Questions Yes No Either
 =======================
 Coffee    *   *  *
A"
		(qst:make-section :name (qst:intern-name "A") 
			:questions `((,(format nil "   ~%"))
				,(make-array '(2 4) :initial-contents
						`((" Questions " "Yes " "No " "Either
")						(" Coffee    "
							,(qst:make-check :name (qst:intern-name "A_1/1")) 
							,(qst:make-check :name (qst:intern-name "A_1/2"))
							,(qst:make-check :name (qst:intern-name "A_1/3")))))
				(" "))))

(test-expect-parsed GRID2
		"
A()
 Questions Yes  No Either
 Coffee     *   *    *
 Tea        *   *    *
A"
		(qst:make-section :name (qst:intern-name "A") 
			:questions `((,(format nil "   ~%"))
				,(make-array '(3 4) :initial-contents
						`((" Questions " "Yes  " "No " "Either
")						(" Coffee     "
							,(qst:make-check :name (qst:intern-name "A_1/1")) 
							,(qst:make-check :name (qst:intern-name "A_1/2"))
							,(qst:make-check :name (qst:intern-name "A_1/3")))
							(" Tea        "
							,(qst:make-check :name (qst:intern-name "A_2/1")) 
							,(qst:make-check :name (qst:intern-name "A_2/2"))
							,(qst:make-check :name (qst:intern-name "A_2/3")))))
				(" "))))

(test-expect-parsed TWO-GRIDS
		"
A()
 Fragen  Ja Nein
 ---------------
 Kaffee   *  *
 Tee      *  *
 Questions Yes  No Either
 Coffee     *   *    *
 Tea        *   *    *
A"
		(qst:make-section :name (qst:intern-name "A") 
			:questions `((,(format nil "   ~%"))
				,(make-array '(3 3) :initial-contents
						`((" Fragen  " "Ja " "Nein
")						(" Kaffee   "
							,(qst:make-check :name (qst:intern-name "A_1/1")) 
							,(qst:make-check :name (qst:intern-name "A_1/2")))
							(" Tee      "
							,(qst:make-check :name (qst:intern-name "A_2/1")) 
							,(qst:make-check :name (qst:intern-name "A_2/2")))))
				,(make-array '(3 4) :initial-contents
						`((" Questions " "Yes  " "No " "Either
")						(" Coffee     "
							,(qst:make-check :name (qst:intern-name "A_3/1")) 
							,(qst:make-check :name (qst:intern-name "A_3/2"))
							,(qst:make-check :name (qst:intern-name "A_3/3")))
							(" Tea        "
							,(qst:make-check :name (qst:intern-name "A_4/1")) 
							,(qst:make-check :name (qst:intern-name "A_4/2"))
							,(qst:make-check :name (qst:intern-name "A_4/3")))))
				(" "))))
	t)