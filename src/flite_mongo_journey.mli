open Flite_type
open Flite_type.Journey
open Lwt

val get_all_journeys : unit -> Journey.t list Lwt.t
val to_mongo : Journey.t -> unit Lwt.t
