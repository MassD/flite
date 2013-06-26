open Flite_type
open Flite_type.Alert
open Lwt

val get_all_alerts : int -> int -> Alert.t list Lwt.t
val get_all_alerts_simple : int -> Alert.t list Lwt.t
val to_mongo : Alert.t -> unit Lwt.t
