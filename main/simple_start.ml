open Flite_type.Journey
open Flite_mongo_journey
open Flite_fs
open Lwt
open Logging

let frequency = 1.

let rec start () = 
  (Lwt_unix.sleep frequency)  >>= 
    (fun () -> 
      schedule_warning "%s" "Begin a new round";
      try_lwt (
	(get_all_journeys ()) >>=
	  (fun fl -> Printf.printf "%d journeys" (List.length fl);(Lwt_list.iter_p fs fl) >>= (fun() -> schedule_warning "Finished a round";return_unit))
      ) with exn -> schedule_error ~exn:exn "error:%s" "in main loop";return_unit
    )

let _ = Lwt_main.run (start()) 

