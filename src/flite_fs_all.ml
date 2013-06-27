open Flite_type.Journey
open Flite_mongo_journey
open Flite_fs
open Lwt
open Lwt_log
open Logging

let fs_all () = 
  (get_all_journeys ()) >>=
    (fun jl -> 
      flite_notice "obtained %d journeys, begin fs all" (List.length jl);
      (Lwt_list.iter_p fs jl))
