open Flite.Flight
open Flite_mongo
open Flite_fs
open Lwt

let frequency = 60. *. 60.

let rec start () = 
  (Lwt_unix.sleep frequency)  >>= 
    (fun () -> 
      print_endline "\nbegin fs all";
      let fl = get_all_flights () in 
      (Lwt_list.iter_p email_price_lwt fl) >>= start
    )

let _ = Lwt_main.run (start()) 

