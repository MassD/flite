open Flite
open Lwt

val build_fs_url: Flight.t -> string

val fs_flex: Flight.t -> Price.t list

val fs_lwt: Flight.t -> Price.t list Lwt.t
