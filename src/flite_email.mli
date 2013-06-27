open Flite_type
open Flite_type.Journey
open Flite_type.Price
open Flite_type.Alert

val email : Alert.t -> Journey.t -> Price.t list -> unit Lwt.t
