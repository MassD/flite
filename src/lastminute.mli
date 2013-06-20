open Flite_type
open Lwt

val build_fs_url: Journey.t -> string

val fs_flex: Journey.t -> Price.t list

val fs_lwt: Journey.t -> Price.t list Lwt.t
