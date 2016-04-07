all: build

build: float.ml test.ml dichotomy.ml dichotomy_test.ml
	ocamlfind ocamlopt -package bisect_ppx -c -g -unsafe float.ml
	ocamlfind ocamlopt -c -g -unsafe test.ml
	ocamlfind ocamlopt -linkpkg -g -unsafe -package bisect_ppx float.cmx test.cmx -o test.out
	ocamlfind ocamlopt -package bisect_ppx -c -g -unsafe dichotomy.ml
	ocamlfind ocamlopt -c -g -unsafe dichotomy_test.ml
	ocamlfind ocamlopt -linkpkg -g -unsafe -package bisect_ppx dichotomy.cmx dichotomy_test.cmx -o test_dich.out

coverage:
	bisect-ppx-report -I bulid/ -html . bisect*.out

clean:
	rm -rf coverage
	rm -f *.cmo *.cmi *.cmp *.out *.html
