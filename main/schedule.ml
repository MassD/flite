open Flite_type.Journey
open Flite_mongo_lwt
open Flite_fs
open Lwt
open Lwt_log
open Logging

let frequency = 60. *. 60.

let rec start () = 
  (Lwt_unix.sleep frequency)  >>= 
    (fun () -> 
      schedule_notice "Begin a new round";
      (get_all_journeys ()) >>=
	(fun fl -> (Lwt_list.iter_p email_price_lwt fl) >>= start)
    )

let _ = Lwt_main.run (start()) 

