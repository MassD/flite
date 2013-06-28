open Flite_type
open Flite_type.Alert
open Lwt

val alert : Alert.t -> unit Lwt.t
