open Flite
open Lwt

val fs_flex: Flight.t -> Price.t list

val fs_lwt: Flight.t -> Price.t list Lwt.t
