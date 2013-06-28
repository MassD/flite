open Flite_type
open Flite_type.Price
open Lwt

val get_all_fresh_prices : int -> Price.t list Lwt.t
val to_mongo : Price.t list -> unit Lwt.t
val spoil_prices : int -> unit Lwt.t
