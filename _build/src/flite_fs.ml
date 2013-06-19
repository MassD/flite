open Flite.Flight
open Flite.Price
open Flite.Alert
open Lwt
open Flite_mongo

let get_fs_price_lwt f =
  print_endline "begin fs";
  (Lastminute.fs_lwt f) >>= 
    (fun pl -> 
      print_endline "lastminute finished"; 
      prices_to_mongo pl; 
      return pl)

let get_price_lwt f =
  (*print_endline "begin get_price_html_lwt";*)
  (return (get_all_prices f)) >>= 
    (fun pl -> if pl = [] then get_fs_price_lwt f else return pl)

let get_price_html_lwt f =
  (get_price_lwt f) >>=
  (fun pl -> return (Html_2.format_pl f pl))

let email_price_lwt f =
  (get_price_html_lwt f) >>=
    (fun ph ->
      print_endline "begin emailing";
      let hour = Utils.current_hour () in
      let alerts = get_all_alerts f.id hour in
      print_endline ("find alerts: "^(string_of_int (List.length alerts)));
      let subj = Printf.sprintf "Flite: from %s to %s, depature on %s-%s, return on %s-%s" f.dep_ap f.arr_ap f.dep_mo f.dep_dy f.ret_mo f.ret_dy in
      let send a = Email.send_lwt (a.user, a.email, subj, ph) in
      Lwt_list.iter_p send alerts)
 

