open Flite_type
open Flite_type.Journey
open Flite_type.Price
open Flite_type.Alert
open Flite_type.Airline
open Lwt

type collection =
  | Journeys
  | Alerts
  | Prices
  | Airlines

val from_mongo_all : collection -> Bson.t -> (Bson.t -> 'a) -> 'a list Lwt.t
val from_mongo_single : collection -> Bson.t -> (Bson.t -> 'a) -> 'a option Lwt.t
val to_mongo : collection -> Bson.t list -> unit Lwt.t
val update_mongo : collection -> Bson.t -> Bson.t -> unit Lwt.t


