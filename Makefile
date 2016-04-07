all: build

build: float.ml test.ml dichotomy.ml dichotomy_test.ml
	ocamlfind ocamlopt -package bisect_ppx -c -g -unsafe float.ml
	ocamlfind ocamlopt -c -g -unsafe test.ml
	ocamlfind ocamlopt -linkpkg -g -unsafe -package bisect_ppx float.cmx test.cmx -o test.out
	ocamlfind ocamlopt -package bisect_ppx -c -g -unsafe dichotomy.ml
	ocamlfind ocamlopt -c -g -unsafe dichotomy_test.ml
	ocamlfind ocamlopt -linkpkg -g -unsafe -package bisect_ppx dichotomy.cmx dichotomy_test.cmx -o test_dich.out

build-byte: float.ml test.ml dichotomy.ml dichotomy_test.ml
	ocamlfind ocamlc -package bisect_ppx -c -g float.ml
	ocamlfind ocamlc -c -g test.ml
	ocamlfind ocamlc -linkpkg -g -unsafe -package bisect_ppx float.cmo test.cmo -o test_byte.out
	ocamlfind ocamlc -package bisect_ppx -c -g dichotomy.ml
	ocamlfind ocamlc -c -g -unsafe dichotomy_test.ml
	ocamlfind ocamlc -linkpkg -g -unsafe -package bisect_ppx dichotomy.cmo dichotomy_test.cmo -o test_dich_byte.out

coverage:
	bisect-ppx-report -I bulid/ -html . bisect*.out

clean:
	rm -rf coverage
	rm -f *.cmo *.cmi *.cmp *.out *.o *.cmx *.html
