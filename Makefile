all: build

build: float.ml test.ml
	ocamlfind c -package bisect_ppx -c float.ml
	ocamlfind c -c test.ml
	ocamlfind c -linkpkg -package bisect_ppx float.cmo test.cmo

coverage:
	bisect-ppx-report -I bulid/ -html . bisect*.out

clean:
	rm -rf coverage
	rm -f *.cmo *.cmi *.cmp *.out *.html
