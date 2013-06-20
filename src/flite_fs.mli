open Flite_type
open Flite_type.Journey
open Flite_type.Price
open Lwt

val get_fs_price_lwt : Journey.t -> Price.t list Lwt.t
val get_price_lwt : Journey.t -> Price.t list Lwt.t
val email_price_lwt : Journey.t -> unit Lwt.t
val email_price_simple_lwt : Journey.t -> unit Lwt.t

val get_price_html_lwt_simple : Journey.t -> unit Lwt.t
