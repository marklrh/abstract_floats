all: build

build: float.ml test.ml dichotomy.ml dichotomy_test.ml
	ocamlfind c -package bisect_ppx -c -g float.ml
	ocamlfind c -c -g test.ml
	ocamlfind c -linkpkg -g -package bisect_ppx float.cmo test.cmo
	ocamlfind c -package bisect_ppx -c -g dichotomy.ml
	ocamlfind c -c -g dichotomy_test.ml
	ocamlfind c -linkpkg -g -package bisect_ppx dichotomy.cmo dichotomy_test.cmo -o test_dich.out

coverage:
	bisect-ppx-report -I bulid/ -html . bisect*.out

clean:
	rm -rf coverage
	rm -f *.cmo *.cmi *.cmp *.out *.html
