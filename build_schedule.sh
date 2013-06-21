ocamlbuild -use-ocamlfind -I src main/simple_start.native
ocamlbuild -use-ocamlfind -cflags -ppopt,-lwt-debug -I src main/schedule.native
