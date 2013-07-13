open Lwt

let u1 = "http://www.lastminute.com"

let u2 = "http://www.bbc.co.uk"

(* a simple function to access the content of the response *)
let content = function
  | Some (_, body) ->  Cohttp_lwt_body.string_of_body body
  | _ -> return ""

(* launch both requests in parallel *)
let t = Lwt_list.map_p Cohttp_lwt_unix.Client.get
  (List.map Uri.of_string [u1])

(* maps the result through the content function *)
let t2 = t >>= Lwt_list.map_p content

let t3 = t2 >>= Lwt_list.iter_p (Lwt_io.printf "%s")  

(* launch the event loop *)
let v = Lwt_main.run t3
