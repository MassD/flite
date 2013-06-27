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
	try_lwt (
	  schedule_warning "Begin a new round of alerts, hour:%d" c_hour;
	  (Flite_alert_all.alert_all ()) >>= 
	    (fun() -> schedule_warning "Finished alert round, hour:%d" c_hour;start c_hour)
	) with
	  | exn -> 
	    schedule_error ~exn:exn "%s" "error occurs in main loop";
	    start c_hour
      else 
	start hour
    )

let _ = Lwt_main.run (start (Utils.current_hour())) 

