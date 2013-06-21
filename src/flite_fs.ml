open Flite_type
open Flite_type.Journey
open Flite_type.Price
open Flite_type.Alert
open Lwt
open Flite_mongo_lwt

let get_fs_price_lwt j =
  Printf.printf "lastminute begin for %d\n" j.id;
  (Lastminute.fs_lwt j) >>= 
    (fun pl -> 
      Printf.printf "lastminute finished for %d\n" j.id;
      (prices_to_mongo pl) >>= (fun () -> return pl))

let get_price_lwt j =
  (get_all_prices j) >>= 
    (fun pl -> if pl = [] then get_fs_price_lwt j else return pl)

let get_price_html_lwt j =
  (get_price_lwt j) >>=
  (fun pl -> 
    Printf.printf "begin creating email html for %d\n" j.id;
    let html = Html.format_pl j pl in
    Printf.printf "email html is created for %d\n" j.id;
    return html
  )

let email_price_lwt j =
  (get_price_html_lwt j) >>=
    (fun ph ->
      Printf.printf "Begin emailing for journey %d\n" j.id;
      let hour = Utils.current_hour () in
      (get_all_alerts j.id hour) >>=
	(fun alerts ->
	  print_endline ("find alerts: "^(string_of_int (List.length alerts)));
	  let subj = Printf.sprintf "Flite: from %s to %s, depature on %s-%s, return on %s-%s" j.dep_ap j.arr_ap j.dep_mo j.dep_dy j.ret_mo j.ret_dy in
	  let send a = Flite_email.send_lwt (a.user, a.email, subj, ph) in
	  Lwt_list.iter_p send alerts)
    )

let get_price_html_lwt_simple j =
  (get_price_lwt j) >>=
  (fun pl -> 
    Printf.printf "begin creating email html for %d\n" j.id;
    let html = Html.format_pl j pl in
    Printf.printf "email html (len=%d) is created for %d\n" (String.length html) j.id;
    return_unit
  )

let email_price_simple_lwt j =
  (get_price_html_lwt j) >>=
    (fun ph ->
      Printf.printf "Begin emailing for journey %d\n" j.id;
      (get_all_alerts_simple j.id) >>=
	(fun alerts ->
	  print_endline ("find alerts: "^(string_of_int (List.length alerts)));
	  let subj = Printf.sprintf "Flite: from %s to %s, depature on %s-%s, return on %s-%s" j.dep_ap j.arr_ap j.dep_mo j.dep_dy j.ret_mo j.ret_dy in
	  let send a = Flite_email.send_lwt (a.user, a.email, subj, ph) in
	  Lwt_list.iter_p send alerts)
    )
 

