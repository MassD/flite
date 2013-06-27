open Flite_type
open Lwt

val build_fs_url: Journey.t -> string

val fs_lwt: Journey.t -> Price.t list option Lwt.t
