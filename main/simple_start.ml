open Flite_type.Journey
open Flite_mongo_lwt
open Flite_fs
open Lwt
open Logging

let frequency = 1.

let rec start () = 
  (Lwt_unix.sleep frequency)  >>= 
    (fun () -> 
      schedule_notice "%s" "Begin a new round";
      (get_all_journeys ()) >>=
	(fun fl -> (Lwt_list.iter_p email_price_simple_lwt fl) >>= (fun() -> schedule_notice "Finished a round";return_unit))
    )

let _ = Lwt_main.run (start()) 

