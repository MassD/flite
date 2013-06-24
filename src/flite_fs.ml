open Flite_type
open Flite_type.Journey
open Flite_type.Price
open Flite_type.Alert
open Lwt
open Logging
open Flite_mongo_lwt
open Printf

let get_fs_price_lwt j =
  (Lastminute.fs_lwt j) >>= 
    (fun pl -> 
      (prices_to_mongo pl) >>= (fun () -> return pl))

let get_price_lwt j =
  (get_all_prices j) >>= 
    (fun pl -> if pl = [] then get_fs_price_lwt j else return pl)

let get_price_html_lwt j =
  (get_price_lwt j) >>=
  (fun pl -> 
    return (Html.format_pl j pl)
  )

let email_price_lwt j =
  flite_notice "begin fs for journey=%d" j.id;
  (get_price_html_lwt j) >>=
    (fun ph ->
      match ph with 
	| Some h ->
	  let hour = Utils.current_hour () in
	  (get_all_alerts j.id hour) >>=
	    (fun alerts ->
	      let alen = List.length alerts in
	      if alen = 0 then (flite_warning "cannot find any alerts for journey=%d" j.id; return_unit)
	      else begin
		flite_notice "find %d alerts for journey=%d, preparing to email" alen j.id;
		let subj = Printf.sprintf "Flite: from %s to %s, depature on %s-%s, return on %s-%s" j.dep_ap j.arr_ap j.dep_mo j.dep_dy j.ret_mo j.ret_dy in
		let send a = Flite_email.send_lwt (a.user, a.email, subj, h) in
		Lwt_list.iter_p send alerts
	      end 
	    )
	| None -> flite_warning "html email is empty for journey=%d, aborted sending email" j.id; return_unit
    )

let get_price_html_lwt_simple j =
  (get_price_lwt j) >>=
  (fun pl -> 
    let html = Html.format_pl j pl in
      match html with 
	| Some h ->
	  let oc = open_out "./email.html" in 
	   fprintf oc "%s\n" h;  
	   close_out oc;
	   return_unit
	| _ -> return_unit
  )

let email_price_simple_lwt j =
  flite_notice "begin fs for journey=%d" j.id;
  (get_price_html_lwt j) >>=
    (
      fun ph ->
      match ph with 
	| Some h ->
	  (get_all_alerts_simple j.id) >>=
	    (fun alerts ->
	      let alen = List.length alerts in
	      if alen = 0 then (flite_warning "cannot find any alerts for journey=%d" j.id;return_unit)
	      else begin
		flite_notice "find %d alerts for journey=%d, preparing to email" alen j.id;
		let subj = Printf.sprintf "Flite: from %s to %s, depature on %s-%s, return on %s-%s" j.dep_ap j.arr_ap j.dep_mo j.dep_dy j.ret_mo j.ret_dy in
		let send a = Flite_email.send_lwt (a.user, a.email, subj, h) in
		Lwt_list.iter_p send alerts
	      end 
	    )
	| None -> flite_warning "html email is empty for journey=%d, aborted sending email" j.id;return_unit
    )
 

