; $Id: cnc-html.lisp,v 1.24 2006/05/25 22:17:31 dvd Exp $

(defpackage "CNC-HTML"
	(:documentation "CNC map in browser")
	(:use "COMMON-LISP" "CNC")
	(:export "SERIALIZE" "PAINT" "HINTS"))
(in-package "CNC-HTML")

(defconstant hints-limit 3
	"maximum number of active dialogue hints displayed")
(defconstant hint-watermark 1
	"hints with weight above the watermark are shown") 

(defun GRID (ranks)
	"builds a transposed grid from the list of ranks;
	seems to look better than the top-down list of ranks"
	(let* (
			(ncols (length ranks)) 
			(nrows (if ranks (apply #'max (mapcar #'length ranks)) 0))
			(grid (make-array (list nrows ncols) :initial-element nil)))
		(do ((icol (1- ncols) (1- icol))
				(rank (car ranks) (car ranks))
				(ranks (cdr ranks) (cdr ranks)))
			((null rank) grid)
			(let ((rank (sort rank #'string-lessp)))
				(do ((irow 0 (1+ irow))
						(node (car rank) (car rank))
						(rank (cdr rank) (cdr rank)))
					((null node))
					(setf (aref grid irow icol) node))))))
			
(defun SERIALIZE (out ranks)
	"writes an HTML representation of CNC network"
	(let ((grid (grid ranks)) (rows nil))
		(dotimes (irow (array-dimension grid 0))
			(let ((cells nil))
				(dotimes (icol (array-dimension grid 1))
					(push
						(let ((cell (aref grid irow icol)))
							(if cell
								(list (format nil
									"td id=\"cnc-~A\" onclick=\"mark_tree('~:*~A')\"" cell)
									cell)
								'("td")))
							cells))
			(push (list* "tr" (reverse cells)) rows)))
		(html:serialize out (list* "table" (reverse rows)) :level (html:level))))

(defun PAINT (out deps infs)
	"writes a JavaScript function to color the network"

	(format out "
			var nodetab = {}, partab = {}, cldtab = {};") ; parent table, child table
	(format out "
			~:{nodetab['~A'] = ~#*'transparent';~:^
			~}" deps)
	(format out "
			~:{partab['~A'] = [~@{'~A'~^,~}];~:^
			~}" deps);
	(format out "
			~:{cldtab['~A'] = [~@{'~A'~^,~}];~:^
			~}" infs);

	(format out "

			function unfold_tree() {
				for(var node in nodetab) {
					var elem = document.getElementById('cnc-'+node);
					elem.style.color = '#999';
					elem.title = undefined;
					if(node in vartab) {
						var val = vartab[node];
						elem.title = val;
						if(partab[node].length!=0 && val==0)
							elem.style.color = '#6cc';
						else
							elem.style.color = 'black';
					}
				}
			}

			function paint_node(node,color) {
				nodetab[node] = color;
				document.getElementById('cnc-'+node).style.backgroundColor = color;
			}
			
			var
				Static = {par: '#fdd', cld: '#ddf', all: true},
				Dynamic = {par: '#f99', cld: '#99f', all: false},
				Root = '#ff6';

			function mark_tree_mode(root,mode) {
				mark_node(root,cldtab,mode.cld,mode.all);
				mark_node(root,partab,mode.par,mode.all);
			}

			function mark_tree(root) {
				for(var node in nodetab)
					paint_node(node,'transparent');
				mark_tree_mode(root,Static);
				mark_tree_mode(root,Dynamic);
				mark_node(root,{},Root,false);
			}
			
			function mark_node(node,partab,color,all) {
				if(nodetab[node]!=color) {
					paint_node(node,color);
					for(var parent in partab[node]) {
						var next = partab[node][parent];
						if(all 
								|| (node in dynatab && next in dynatab[node])
								|| (next in dynatab && node in dynatab[next]))
							mark_node(next,partab,color,all);
					}
				}
			}~%"))

(defun HINTS (out questions ranks)
	"writes a JavaScript function to choose hints"
	(format out "
			var questions = [~{'~A'~^,~}], sections = [~{'~A'~^,~}];" 
		(mapcar #'car questions)
		(remove-duplicates (mapcar #'cadr questions)))
	(format out "
			var quetab = {};
			~:{quetab['~A'] = '~A';
			~}" (mapcar #'(lambda (q) (list (first q) (second q))) questions))
	(format out "
			var ranks = [
				~{[~{'~A'~^,~}]~^,
				~}
			];" ranks)
	(format out "

			function clean(node) {
				/* true if the node is clean */
				return !(node in vartab) || (partab[node].length!=0 && vartab[node]==0);
			}

			function append_cleans(ancestors,parents) {
				/* append clean nodes from parents to ancestors recursively */
				for(var i = 0;i!=parents.length;++i) {
					var parent = parents[i];
					if(clean(parent))
						ancestors.push(parent);
					else
						append_cleans(ancestors,partab[parent]);
				}
			}
	
			function choose_hints() {
				/* make at most hints-limit hints with highest weights visible */
				var weightab = {};
				for(var node in nodetab) {
					if(clean(node))
						weightab[node] = 1.0;
				}
				for(var ir = 0;ir<ranks.length-1;++ir) {
					var rank = ranks[ir];
					for(var jr = 0;jr!=rank.length;++jr) {
						var node = rank[jr];
						if(clean(node)) {
							var ancestors = [];
							append_cleans(ancestors,partab[node]);
							if(ancestors.length!=0) {
								var influence = weightab[node]/ancestors.length;
								for(var ia = 0;ia!=ancestors.length;++ia) {
									weightab[ancestors[ia]]+= influence;
								}
							}
						}
					}
				}
				var secweightab = {};
				for(var is = 0;is!=sections.length;++is) {
					secweightab[sections[is]] = 0;
				}
				for(var iq = 0;iq!=questions.length;++iq) {
					var node = questions[iq];
					var section = quetab[node];
					if(!(node in vartab)
							&& document.getElementById('question-'+node).offsetHeight) {
						if(secweightab[section]<weightab[node]) 
							secweightab[section] = weightab[node];
					}
				}
				sections.sort(function(a,b) {return secweightab[b]-secweightab[a];})
				var hints_limit = ~A, hint_watermark = ~A;
				if(hints_limit > sections.length)
					hints_limit = sections.length;
				var is;
				for(is = 0;is!=hints_limit;++is) {
					var section = sections[is];
					if(secweightab[section]<=hint_watermark)
						break;
					hint =  document.getElementById('hint-'+section);
					hint.style.display = '';
					hint.title = secweightab[section];
					for(var ic=0;ic!=hint.childNodes.length;++ic) {
						var child = hint.childNodes[ic];
						if(child.nodeType==1)
							child.title = hint.title;
					}
				}
				for(;is!=sections.length;++is) {
					document.getElementById('hint-'+sections[is]).style.display = 'none';
				}
			}~%" hints-limit hint-watermark))
