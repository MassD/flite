open Flite_type.Journey
open Flite_mongo_lwt
open Flite_fs
open Lwt
open Lwt_log
open Logging

let frequency = 30. *. 60.

let rec start () = 
  (Lwt_unix.sleep frequency)  >>= 
    (fun () -> 
      try (
	schedule_notice "Begin a new round";
	(get_all_journeys ()) >>=
	  (fun fl -> (Lwt_list.iter_p email_price_lwt fl) >>= start)
      ) with
	| _ as exn -> 
	  schedule_error ~exn:exn "%s" "error occurs in main loop";
	  start ()
    )

let _ = Lwt_main.run (start()) 

