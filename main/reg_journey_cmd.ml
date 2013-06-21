open Core
open Flite_reg

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
      +> flag "-airline" (optional_with_default "" string) 
        ~doc:" The desired airline, e.g. KLM, "
      +> flag "-trip-type" (optional_with_default 1 int) 
        ~doc:" The trip type, single=0, return=1, multihop=2 "
      +> flag "-user" (required string) 
        ~doc:" The username for the alert, e.g., 'xinuo'"
      +> flag "-email" (required string) 
        ~doc:" The email to receive the alert, e.g., 'iamindcs@gmail.com;jennyindcs@gmail.com'"
      +> flag "-frequency" (required string) 
        ~doc:" The list of clock hours at which prices needed to be sent, e.g., 12::14::23"
      
    )
    (* The command-line spec determines the argument to this function, which
       show up in an order that matches the spec. *)
    register_journey

let () = Command.run command
