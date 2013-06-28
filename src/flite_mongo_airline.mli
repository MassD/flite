open Flite_type
open Flite_type.Airline
open Lwt

val get_airline : string -> Airline.t option Lwt.t
val get_all_airlines : unit -> Airline.t list Lwt.t
