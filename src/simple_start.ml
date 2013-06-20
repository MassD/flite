open Flite_type.Journey
open Flite_mongo
open Flite_fs
open Lwt

let frequency = 1.

let rec start () = 
  (Lwt_unix.sleep frequency)  >>= 
    (fun () -> 
      print_endline "\nbegin fs all";
      let fl = get_all_journeys () in 
      (*email_price_simple_lwt (List.nth fl 0)*)
      Lwt_list.iter_p email_price_simple_lwt fl
      (*Lwt_list.iter_p get_price_html_lwt_simple fl*)
    )

let _ = Lwt_main.run (start()) 

