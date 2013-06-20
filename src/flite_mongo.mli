open Flite_type
open Flite_type.Journey
open Flite_type.Price
open Flite_type.Alert

val get_journey : int -> Journey.t option
val get_alert : int -> string -> Alert.t option
val journey_to_mongo : Journey.t -> Alert.t -> unit

val get_all_journeys : unit -> Journey.t list

val get_all_alerts : int -> int -> Alert.t list

val get_all_alerts_simple : int -> Alert.t list

val prices_to_mongo : Price.t list -> unit
val get_all_prices : Journey.t -> Price.t list
