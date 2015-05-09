; $Id: cnc-js.lisp,v 1.17 2005/09/12 16:49:07 dvd Exp $

(defpackage "CNC-JS"
	(:documentation "CNC interpreter in JavaScript")
	(:use "COMMON-LISP")
	(:export "SERIALIZE"))
(in-package "CNC-JS")

(defun SERIALIZE (out cnc)
	"creates CNC interpreter in JavaScript"
	(format out "
			var NIL = 0, MINF = ~A, PINF = ~A;
			var PUNCTU = ',;.:';
			var CLR=0, INC=1, ADD=2, SUB=3, MUL=4, DIV=5, JMP=6, PRN=7;
			var Ncnc = ~A;
			var cnc = [~%" #|]|# cnc:-inf cnc:+inf (length cnc))
	(dotimes (i (length cnc))
		(let ((cmd (aref cnc i)))
			(format out "~:
					[~A~{~^,~A~}],~%" 
						(car cmd)
						(mapcar 
							#'(lambda (a)
								(if (and (stringp a) 
										(plusp (length a)) 
										(char= (char a 0) #\Newline))
									(format nil "\"\\n~A" 
										(subseq (format nil "~S" (subseq a 1)) 1))
									(format nil "~S" a)))
							(cdr cmd)))))
	(format out #|[|# "~:
			];

			function cncarg(a) {
				return typeof(a)=='string'?parseFloat(vartab[a]):a;
			}
			
			function cncond(cmd) {
				if(!cmd[2] || (cmd[3]==MINF && cmd[4]==MINF)) return true;
				var value = vartab[cmd[2]],
					any = (cmd[3]==MINF && cmd[4]==PINF),
					nil = (cmd[3]==PINF && cmd[4]==MINF);
				if(any || nil) return nil==(value==undefined || String(value)=='');
				var number = parseFloat(value);
				return number!=NaN && cmd[3]<=number && number<=cmd[4];
			}
			
			function runcnc() {
				var s = '';
				dynatab = {};
				for(var i = 0; i<Ncnc;) {
					var cmd = cnc[i];
					switch(cmd[0]) {
					case CLR:
						vartab[cmd[1]] = 0;
						dynatab[cmd[1]] = {};
						break;
					case INC:
						if(cncond(cmd)) {
							vartab[cmd[1]]+= cncarg(cmd[5]);
							dynatab[cmd[1]][cmd[2]] = true;
						}
						break;
					case ADD: case SUB: case MUL: case DIV:
						var op1 = cncarg(cmd[5]), op2 = cncarg(cmd[6]);
						var res;
						switch(cmd[0]) {
						case ADD: res = op1+op2; break;
						case DIV: res = op1/op2; break;
						case MUL: res = op1*op2; break;
						case SUB: res = op1-op2; break;
						}
						vartab[cmd[1]] = res;
						break;
					case JMP:
						if(cncond(cmd)) {
							i = cmd[1];
							continue;
						}
						break;
					case PRN:
						if(cncond(cmd)) {
							var ds = cmd[1];
							var isubst = ds.indexOf('*');
							if(isubst!=-1) {
								var jsubst = isubst+1, value = vartab[cmd[2]];
								while(jsubst!=ds.length && ds.charAt(jsubst)=='*')
									++jsubst;
								if(value==undefined)
									value = '';
								ds = ds.substring(0,isubst)+value+ds.substring(jsubst);
							}
							if(s.length!=0 && PUNCTU.indexOf(s.charAt(s.length-1))!=-1
									&& ds.length!=0 && PUNCTU.indexOf(ds.charAt(0))!=-1)
								s = s.substring(0,s.length-1);
							s+= ds;
						}
						break;
					}
					++i;
				}
				
				document.getElementById('conclusion-text').value = s;
			}
			~%")
	)
