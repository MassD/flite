open Flite.Flight
open Flite.Price
open Flite.Alert

val get_all_flights : unit -> Flite.Flight.t list

val get_all_alerts : int -> int -> Flite.Alert.t list

val prices_to_mongo : Flite.Price.t list -> unit
val get_all_prices : Flite.Flight.t -> Flite.Price.t list
