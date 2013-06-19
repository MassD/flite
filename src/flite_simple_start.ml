open Flite.Flight
open Flite_mongo
open Flite_fs
open Lwt

let frequency = 1.

let rec start () = 
  (Lwt_unix.sleep frequency)  >>= 
    (fun () -> 
      print_endline "\nbegin fs all";
      let fl = get_all_flights () in 
      (*email_price_simple_lwt (List.nth fl 0)*)
      Lwt_list.iter_p email_price_simple_lwt fl
    )

let _ = Lwt_main.run (start()) 

