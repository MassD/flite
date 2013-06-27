#ocamlbuild -use-ocamlfind -cflag -g -I src main/simple_start.native
ocamlbuild -use-ocamlfind -cflag -g -I src main/schedule_fs.native
ocamlbuild -use-ocamlfind -cflag -g -I src main/schedule_alert.native
