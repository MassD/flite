open Flite_type.Alert
open Flite_mongo_alert
open Flite_alert
open Lwt
open Lwt_log
open Logging

let alert_all () = 
  let hour = Utils.current_hour () in
  (get_current_alerts hour) >>=
    (fun al -> 
      flite_notice "obtained %d alerts, begin alert all" (List.length al);
      (Lwt_list.iter_p alert al))
