open Flite_type
open Flite_type.Journey
open Flite_type.Price
open Flite_type.Alert
open Lwt

val journey_to_mongo : Journey.t -> Alert.t -> unit Lwt.t

val get_all_journeys : unit -> Journey.t list Lwt.t

val get_all_alerts : int -> int -> Alert.t list Lwt.t

val get_all_alerts_simple : int -> Alert.t list Lwt.t

val prices_to_mongo : Price.t list -> unit Lwt.t
val get_all_prices : Journey.t -> Price.t list Lwt.t
