open Flite_type
open Flite_type.Journey
open Flite_type.Price
open Flite_type.Alert
open Lwt
open Logging
open Flite_mongo_alert
open Flite_mongo_price
open Printf

let fs j =
  (Lastminute.fs_lwt j) >>= 
    (fun pl' -> 
      match pl' with
	| Some pl -> 
	  (Flite_mongo_price.spoil_prices j.id) >>=
	    (fun() ->
	      (Flite_mongo_price.to_mongo pl) >>= return)
	| None -> return_unit)

let fs_pl j =
  (Lastminute.fs_lwt j) >>= return
 

