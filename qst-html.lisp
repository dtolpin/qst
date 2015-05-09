; $Id: qst-html.lisp,v 1.54 2005/09/23 09:47:47 dvd Exp $

(defpackage "QST-HTML"
	(:documentation "QST in dynamic HTML")
	(:use "COMMON-LISP" "UTIL")
	(:export "SERIALIZE"))
(in-package "QST-HTML")

(defmacro VARREF (name)
	"references a JavaScript variable for the question"
	`(format nil "vartab['~A']" ,name))

(defgeneric FIELD-HTML (field)
	(:documentation "returns an HTML-WRITER tree for QST fields")

	(:method ((choice qst:choice))
		(let ((name (qst:field-name choice)))
			`(,(format nil "table class=\"choice\" title=\"~A\"" name)
				,@(mapcar
					(lambda (o)
						`("tr"
							("td" ,(cdr o))
							("td"
								(,(format nil 
									"input type=\"radio\" name=\"~A\" value=\"~A\" ~
										onclick=\"~A=value;refresh()\""
									name (car o) (varref name))))))
					(qst:choice-options choice)))))

	(:method ((check qst:check))
			(let ((name (qst:field-name check)))
				`("span class=\"check\""
					(,(format nil
							"input type=\"checkbox\" ~
								name=\"~A\" title=\"~:*~A\" value=\"1\" ~
								onclick=\"parentNode.style.backgroundColor = 'transparent';~
								~A=checked?1:0;refresh()\""
							name (varref name))))))

	(:method ((numeric qst:numeric))
		(let ((name (qst:field-name numeric)))
			`(,(format nil "input type=\"text\" size=\"6\" ~
						name=\"~A\" title=\"~:*~A\" ~
						onblur=\"~A=value;refresh()\""
					name (varref name)))))

	(:method ((freeform qst:freeform))
		(let ((name (qst:field-name freeform)))
			`(,(format nil "input type=\"text\" size=\"48\" ~
						name=\"~A\" title=\"~:*~A\" ~
						onblur=\"~A=value;refresh()\""
					name (varref name)))))
	
	(:method ((ref qst:ref))
		`(,(format nil "span class=\"ref\" name=\"~A\"" (qst:field-name ref)) "?")))

(defun SERIALIZE (out qst &optional (cnc #()) (submit nil))
	"writes questionnaire to the output stream as HTML"
	(let* (
			(qst-guards (mapcan #'qst:guards qst))
			(qst-questions (mapcan #'qst:questions qst))
			(cnc-deps (cnc:dependencies cnc))
			(cnc-infs (cnc:influences cnc-deps))
			(cnc-ranks (cnc:ranks cnc-deps))
			(new-section nil))
		(format out "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01//EN\">~%") ; MSIE
		(html:serialize out
			`("html"
				("head"
					("title" ,(qst:section-title (car qst)))
					("style type=\"text/css\""
"body {margin-right: 40%; background-color: #ccc;}

div.conclusion {top: 1%; right: 1%; left: 60%; height: 90%;
	padding: 6pt;
}
#conclusion-text {width: 100%; height: 60%;}
/* IE hack */
@media screen {
	div.conclusion {position: fixed;}
	* html {overflow-y: hidden;}
	* html body {overflow-y: auto; height: 95%;}
	* html div.conclusion {position: absolute;}
	* html #conclusion-text {width: 67%;}
}

div.conclusion p.button {text-align: left; margin: 0pt; padding: 0pt;
	margin-bottom: 6pt}
div.conclusion a.button {padding: 2pt;
	background-color: #fff; border: thin solid black;
	text-decoration: none; color: black; font-size: small;}

div.hints {padding: 6pt 0pt; }
div.hints p.hint {margin: 2pt 0pt; padding: 4pt; 
	 border: thin solid black; background-color: #999;}
div.hints a.hint {color: white; text-decoration: none;}

div.questionnaire {margin: 0pt; padding: 0pt;
	background-color: white; border: thin solid black;}
div.section {margin: 6pt 0pt 6pt 6pt; padding: 6pt; background-color: #fff;
	border: medium none red;}			

/* this is nonsense, but processors are fast */
div.section div.section {background-color: #fef;}
div.section div.section div.section {background-color: #fdf;}
div.section div.section div.section div.section {background-color: #fcf;}
div.section div.section
div.section div.section div.section {background-color: #fcc;}
div.section
div.section div.section
div.section div.section div.section {background-color: #fdd;}
div.section div.section div.section
div.section div.section div.section div.section {background-color: #fee;}
div.section div.section div.section div.section
div.section div.section div.section div.section {background-color: #fff;}
div.section div.section
div.section div.section div.section
div.section div.section div.section div.section {background-color: #ffe;}
div.section
div.section div.section
div.section div.section div.section
div.section div.section div.section div.section {background-color: #ffd;}

div.section .title {font-weight: bold; padding: 0pt; margin: 0pt;}
div.section .flip {float: right;
	border: thin solid black; padding: 0em 0.25em;
	text-decoration: none; background-color: #fff; color: #000;
	font-family: monospace; font-size: large; font-weight: bold;
	line-height: 1;
}

div.question {margin: 6pt 0pt; padding: 0pt;}
span.check {padding: 2pt 2pt; margin: -2pt 0pt; background-color: #ccc;}
span.ref {font-style: italic;}

table.grid {width: 90%; border-collapse: collapse; margin: 6pt 0pt;}
table.grid td {border-top: thin dashed #999; padding: 2pt 4pt;}
table.grid tr:first-child td {border-top-style: none;}
table.grid td:first-child {text-align: right; width: 70%;}

table.choice {width: 75%; margin: 6pt 0pt 6pt 24pt;
	border: thin dashed #999;
}
table.choice td {padding: 0pt 4pt;}
table.choice td:first-child { text-align: right; width: 90%;}

div.syndromes {margin: 0pt; padding: 0pt; display: none;}

div.syndromes table {font-size: xx-small;
	margin: 0pt; padding: 6pt;
	background-color: white; border: thin solid black;
	border-spacing: 0pt;}")

					("script type=\"text/javascript\"" "<!--
var hideIt = '-', showIt = '+';

function flipTail(id){
	var children = document.getElementById(id).childNodes;
	var hide =
		document.getElementById('flip-'+id).childNodes[0].data==hideIt;
	var tail = 0;
	for(var i = 0; i != children.length; ++i) {
		var child = children[i];
		if(child.nodeType==1) {
			if(tail==2)
				child.style.display = hide? 'none':'block';
			else
				++tail;
		}
	}
	document.getElementById('flip-'+id).childNodes[0].data = hide?
		showIt
	:	hideIt;
}

function switchTail(id,nextState){
	if(document.getElementById('flip-'+id).childNodes[0].data==nextState) {
		flipTail(id);
	}
}

var hilited = undefined;

function hiliteSection(id) {
	if(hilited)
		hilited.style.borderStyle = 'none';
	hilited = document.getElementById(id);
	hilited.style.borderStyle = 'solid';
}

var vartab = {}, dynatab = {};"
			
			(,#'cnc-js:serialize ,cnc)
			(,#'cnc-html:paint ,cnc-deps ,cnc-infs)
			(,#'cnc-html:hints ,qst-questions ,cnc-ranks)
		
"function refresh() {//}
	if(hilited)
		hilited.style.borderStyle = 'none';
	var v;"
		,@(mapcar
			#'(lambda (section-name-guard)
				(let ((section-name (car section-name-guard))
						(guard (cdr section-name-guard)))
					(format nil "
					v = ~A; switchTail('~A',v==undefined~{~^||v~A~}?hideIt:showIt);"
						(varref (qst:guard-name guard)) section-name
						(qst:guard-conditions guard))))
			qst-guards)
"
	runcnc();
	choose_hints(); //{
}
window.onload = refresh;

function showQst() {
	document.getElementById('question-list').style.display = 'block';
	document.getElementById('hint-list').style.display = 'block';
	document.getElementById('syndrome-map').style.display = 'none';
}

function showCnc() {
	unfold_tree();
	document.getElementById('question-list').style.display = 'none';
	document.getElementById('hint-list').style.display = 'none';
	document.getElementById('syndrome-map').style.display = 'block';
}
//-->"))
				("body"
					(,(if submit
							(format nil "form method=\"POST\" action=\"~A\"" submit)
							"form onsubmit=\"return false;\"")
						("div class=\"questionnaire\" id=\"question-list\""
							,@(mapcar
								#'(lambda (section)
									(let ((body-stack (list nil)))
										(labels (
												(add-to-body (elem) (push elem (car body-stack)))
												(push-body () (push nil body-stack))
												(pop-body (head)
													(add-to-body (cons head (nreverse (pop body-stack))))))
											(qst:traverse section
												:h-start-section
													#'(lambda (name title guard)
														(push-body)
														(setf new-section (or title t))
														(when guard 
															(add-to-body
																`(,(format nil
																	"a class=\"flip\" name=\"flip\" ~
																			id=\"flip-~A\" href=\"#\" ~
																			onclick=\"flipTail('~:*~A'); return false\" ~
																			title=\"~:*~A~:[~*~;: ~A~]\""
																		name title (html:escape-avalue title))
																	"-"))
															(when (not (qst:guard-eigen guard))
																(add-to-body '("span")))))
												:h-end-section
													#'(lambda (name)
														(pop-body
															(format nil "div id=\"~A\" class=\"section\"" name))
														(setf new-section nil))
												:h-start-question #'push-body
												:h-end-question
													#'(lambda () (pop-body "div class=\"question\""))
												:h-start-grid #'push-body
												:h-end-grid #'(lambda () (pop-body "table class=\"grid\""))
												:h-start-row #'push-body
												:h-end-row #'(lambda () (pop-body "tr"))
												:h-start-cell #'push-body
												:h-end-cell #'(lambda () (pop-body "td"))
												:h-field
													#'(lambda (field)
														(let ((elem (field-html field)))
															(setf (car elem)
																(concatenate 'string (car elem)
																	(format nil " id=\"question-~A\""
																		(qst:field-name field))))
															(add-to-body elem)))
												:h-text
													#'(lambda (text)
														(when new-section
															(let (
																	(end-of-title
																		(or (and (stringp new-section)
																				(position #\Newline text))
																			0)))
																(add-to-body
																 `("span class=\"title\""
																 	,(subseq text 0 end-of-title)))
																(setf text (subseq text end-of-title)))
															(setf new-section nil))
														(add-to-body text))))
										(caar body-stack)))
							qst))
						("div class=\"conclusion\" title=\"conclusion\""
							("p class=\"button\""
								(,(format nil "a href=\"#\" class=\"button\" ~
										onclick=\"showQst();return true\" ~
										title=\"show questionnaire\"")
									"QST")
								(,(format nil "a href=\"#\" class=\"button\" ~
										onclick=\"showCnc(); return true\" ~
										title=\"show syndrome network\"")
									"CNC"))
							(,(format nil "textarea name=\"conclusion-text\" id=\"conclusion-text\" ~
									rows=\"24\""))
							("div class=\"hints\" id=\"hint-list\""
								,@(mapcar 
									#'(lambda (hint)
											`(,(format nil "p class=\"hint\" id=\"hint-~A\"" (car hint))
												(,(format nil "a href=\"#~A\" class=\"hint\" ~
													onclick=\"hiliteSection('~:*~A'); return true\"" (car hint))
													,(cdr hint))))
									(remove-duplicates (mapcar #'cdr qst-questions) :test #'equal)))
							,(when submit
								'("input type=\"submit\"")))
						("div class=\"syndromes\" id=\"syndrome-map\""
							(,#'cnc-html:serialize ,cnc-ranks))))))))
