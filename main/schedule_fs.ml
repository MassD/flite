open Flite_type.Journey
open Flite_mongo_journey
open Flite_fs
open Lwt
open Lwt_log
open Logging

let rec start i = 
  (Lwt_unix.sleep Flite_config.fs_frequency)  >>= 
    (fun () -> 
      try_lwt (
	schedule_warning "Begin a new round, #%d" i;
	(Flite_fs_all.fs_all ()) >>= 
	  (fun() -> schedule_warning "Finished round #%d" i;start (i+1))
      ) with
	| exn -> 
	  schedule_error ~exn:exn "%s" "error occurs in main loop";
	  start (i+1)
    )

let _ = Lwt_main.run (
  (return (schedule_warning "FS_ALL scheduler is started!")) >>=
    (fun() -> start 0)) 
