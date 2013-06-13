open Core.Std
open Flight

(* A very basic command-line program, using Command, Core's Command line
   parsing library.  *)

let register dep_ap arr_ap dep_mo dep_dy ret_mo ret_dy email frequency desired_airline () =
  let f = 
    { 
    dep_ap = dep_ap;
    arr_ap = arr_ap;

    dep_mo = dep_mo;
    dep_dy = dep_dy;

    ret_mo = ret_mo;
    ret_dy = ret_dy;
    
    email = email;
    frequency = frequency;
    desired_airline = desired_airline;
  }
  in 
  print_endline (to_string f);;

let command =
  (* [Command.basic] is used for creating a command.  Every command takes a text
     summary and a command line spec *)
  Command.basic
    ~summary:"Register a flight alert"
    (* Command line specs are built up component by component, using a small
       combinator library whose operators are contained in [Command.Spec] *)
    Command.Spec.(
      empty
      +> flag "-dep-ap" (required string) 
        ~doc:" The departure airport code"
      +> flag "-arr-ap" (required string)
        ~doc:" The arrival airport code"
      +> flag "-dep-mo" (required string) 
        ~doc:" The departure month, e.g., 2013-9"
      +> flag "-dep-dy" (required string) 
        ~doc:" The departure day, e.g., 20"
      +> flag "-ret-mo" (required string) 
        ~doc:" The return month, e.g., 2013-10"
      +> flag "-ret-dy" (required string) 
        ~doc:" The return day, e.g., 2013-10"
      +> flag "-email" (required string) 
        ~doc:" The email to receive the alert, e.g., 'iamindcs@gmail.com;jennyindcs@gmail.com'"
      +> flag "-frequency" (required float) 
        ~doc:" The checking frequency, in hour, e.g., 4.5"
      +> flag "-desired-airline" (optional_with_default "" string) 
        ~doc:" The desired airline, e.g. KLM, "
    )
    (* The command-line spec determines the argument to this function, which
       show up in an order that matches the spec. *)
    register

let () = Command.run command
