open Flite_type
open Flite_type.Journey
open Flite_type.Price
open Flite_type.Alert
open Lwt
open Logging
open Flite_mongo_alert
open Flite_mongo_price
open Flite_mongo_journey
open Flite_email

let alert a =
  flite_notice "alert to %s, %s for journey %d" a.user a.email a.journey_id;
  (get_journey a.journey_id) >>=
    (fun j' ->
      match j' with
	| Some j ->
	  (get_all_fresh_prices j.id) >>=
	    (fun pl ->
	      if pl =[] then 
		(flite_warning "alert to %s, %s for journey %d, cannot find any fresh prices" a.user a.email a.journey_id;
		 return_unit)
	      else 
		email a j pl
	    )
	| None -> flite_warning "alert to %s, %s for journey %d, cannot find journey" a.user a.email a.journey_id;return_unit
    )
