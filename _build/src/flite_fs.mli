open Flite.Flight
open Flite.Price
open Lwt

val get_fs_price_lwt : Flite.Flight.t -> Flite.Price.t list Lwt.t
val get_price_lwt : Flite.Flight.t -> Flite.Price.t list Lwt.t
val email_price_lwt : Flite.Flight.t -> unit Lwt.t
