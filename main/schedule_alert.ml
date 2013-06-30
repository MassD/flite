open Flite_type.Journey
open Flite_mongo_journey
open Flite_fs
open Lwt
open Lwt_log
open Logging

let rec start hour = 
  (Lwt_unix.sleep 60.)  >>= 
    (fun () -> 
      let c_hour = Utils.current_hour() in
      if c_hour > hour then
	let next = if c_hour = 23 then -1 else c_hour in
	try_lwt (
	  schedule_warning "Begin a new round of alerts, hour:%d" c_hour;
	  (Flite_alert_all.alert_all ()) >>= 
	    (fun() -> schedule_warning "Finished alert round, hour:%d" c_hour;start next)
	) with
	  | exn -> 
	    schedule_error ~exn:exn "%s" "alert error occurs in main loop";
	    start next
      else 
	start hour
    )

let _ = Lwt_main.run (start (Utils.current_hour())) 

