; $Id: qst.lisp,v 1.45 2005/09/07 10:10:57 dvd Exp $

(defpackage "QST"
	(:documentation "internal representation of questionnaire")
	(:use "COMMON-LISP" "UTIL")
	(:export "INTERN-NAME" "TRAVERSE" "GUARDS" "QUESTIONS"))
(in-package "QST")

(let ((nametab (make-hash-table :test #'equal)))
	(defun INTERN-NAME (n)
		"interns a QST name (section or question)"
		(let ((p (gethash n nametab)))
			(or p
				(setf (gethash n nametab) n)))))
	
(defextruct FIELD "generic input field"
	name)

(defextruct (CHOICE (:include field))
	"singular choice, options is alist of choices"
	options)

(defextruct (CHECK (:include field))
	"check box")

(defextruct (NUMERIC (:include field))
	"number between min and max with <= prec decimal digits"
	min max prec)

(defextruct (FREEFORM (:include field))
	"free-form text")

(defextruct (REF (:include field))
	"value reference")

(defextruct GUARD
	"guard condition for sections"
	name eigen conditions)

(defextruct SECTION
	"questionnaire or a section of it,
  if the guard fails, the question is visible"
	name guard title
	questions
	cnc)

(defun h-void (&rest args) 
	"default handler for traverse"
	(declare (ignore args)))

(defun TRAVERSE (section &key
	(h-start-section #'h-void) (h-end-section #'h-void)
	(h-start-question #'h-void) (h-end-question #'h-void)
	(h-start-grid #'h-void) (h-end-grid #'h-void)
	(h-start-row #'h-void) (h-end-row #'h-void)
	(h-start-cell #'h-void) (h-end-cell #'h-void)
	(h-field #'h-void) (h-text #'h-void))

	"(traverse section &key
		(h-start-section name title guard) (h-end-section name)
		(h-start-question) (h-end-question) 
		(h-start-grid) (h-end-grid) 
		(h-start-row) (h-end-row) 
		(h-start-cell) (h-end-cell) 
		(h-field field) (h-text text))
	traverses questionnaire, calling handlers on nodes,
	default handlers are no-op"

	(labels (
			(TRAVERSE-SECTION (section)
				(traverse section 
					:h-start-section h-start-section 
					:h-end-section h-end-section
					:h-start-question h-start-question
					:h-end-question h-end-question
					:h-start-grid h-start-grid
					:h-end-grid h-end-grid
					:h-start-row h-start-row
					:h-end-row h-end-row
					:h-start-cell h-start-cell
					:h-end-cell h-end-cell
					:h-field h-field 
					:h-text h-text))

			(PROCESS-NODE (n)
				(etypecase n
					(string (funcall h-text n))
					(field (funcall h-field n))))

			(TRAVERSE-QUESTION (question)
				(funcall h-start-question)
				(mapc #'process-node question)
				(funcall h-end-question))

			(TRAVERSE-GRID (grid)
				(funcall h-start-grid)
				(do ((i 0 (1+ i))) ((= i (array-dimension grid 0)))
					(funcall h-start-row)
					(do ((j 0 (1+ j))) ((= j (array-dimension grid 1)))
						(funcall h-start-cell)
						(process-node (aref grid i j))
						(funcall h-end-cell))
					(funcall h-end-row))
				(funcall h-end-grid)))
					
		(funcall h-start-section
			(section-name section)
			(section-title section)
			(section-guard section))
		(mapc
			#'(lambda (n)
				(etypecase n
					(array (traverse-grid n))
					(list (traverse-question n))
					(section (traverse-section n))))
			(section-questions section))
		(funcall h-end-section (section-name section))))

(defun GUARDS (section)
	"collects guards for all guarded
	sections. Returns alist  (section-name . section-guard)."
	(let ((index ()))
		(traverse section
			:h-start-section 
				#'(lambda (name title guard) (declare (ignore title))
					(when guard (push (cons name guard) index))))
		(nreverse index)))

(defun QUESTIONS (section)
	"Binds questions to sections they belong to.
	Questions always belong to the most nested titled section.
	Returns alist: (answer . (section-name . section-title))."
	(let ((index ()) (sections ()))
		(traverse section
			:h-start-section
				#'(lambda (name title guard) (declare (ignore guard))
					(push 
						(cons name (or title (cdar sections)))
						sections))
			:h-end-section 
				#'(lambda (name) (declare (ignore name))
					(pop sections))
			:h-field 
				#'(lambda (field)
					(push (cons (field-name field) (car sections)) index)))
		(nreverse index)))
			