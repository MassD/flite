open Http_client.Convenience;;
open Flite.Flight;;
open Flite.Price;;
open Lwt;;
open Cohttp_lwt_unix;;


let airline_begin = "<p class=\"flexi-airline\">";;
let airline_end = "<";;

let price_begin = "<input type=\"hidden\" name=\"price\" value=\"";;

let dep_dy_begin = "<input type=\"hidden\" class=\"depart_day_sel\" name=\"depart_day\" value=\"";;
let dep_mo_begin = "<input type=\"hidden\" class=\"depart_month_sel\" name=\"depart_month\" value=\"";;
let ret_dy_begin = "<input type=\"hidden\" class=\"return_day_sel\" name=\"return_day\" value=\"";;
let ret_mo_begin = "<input type=\"hidden\" class=\"return_month_sel\" name=\"return_month\" value=\"";;

let value_end = "\"";;

let fs_url_base = 
  "http://www.lastminute.com/trips/flightlist/flexiCal?srchSnr=0&showFlexiCal=True&flexDate=True&srchAdt=1&path=flights&airline=NONE&pTxId=1887981&numLegs=2&srchChld=0&configId=S72722479&intcmp=tsm&redirectOnly=false&source=&cabins=X&srchInf=0";;

let build_fs_url f = 
  Printf.sprintf "%s&depAp=%s&arrAp=%s&depMo=%s&depDy=%s&retMo=%s&retDy=%s" fs_url_base f.dep_ap f.arr_ap f.dep_mo f.dep_dy f.ret_mo f.ret_dy

let get_fs_html f = http_get (build_fs_url f)

let parse f html = 
  let html_len = String.length html in
  let rec parse_rec start acc =
    if start >= html_len then acc
    else begin
      try 
	(
	  let extract s b e =
	    let c_begin = (Str.search_forward (Str.regexp_string b) html s) + (String.length b) in
	    let c_end = Str.search_forward (Str.regexp_string e) html c_begin in
	    let c = String.sub html c_begin (c_end-c_begin) in
	    (c, c_end+1)
	  in 
	  let (airline, next) = extract start airline_begin airline_end in
	  let (price, next) = extract next price_begin value_end in
	  let (dep_dy, next) = extract next dep_dy_begin value_end in
	  let (dep_mo, next) = extract next dep_mo_begin value_end in
	  let (ret_dy, next) = extract next ret_dy_begin value_end in
	  let (ret_mo, next) = extract next ret_mo_begin value_end in
	  let fr = 
	    { 
	      flight = f;
	      airline = String.capitalize airline;
	      actual_dep_date = dep_mo ^ "-" ^ dep_dy;
	      actual_ret_date = ret_mo ^ "-" ^ ret_dy;
	      price = float_of_string price;
	      last_checked = Unix.time ();
	    } in
	  parse_rec (next+1) (fr::acc)
	) with Not_found -> acc
    end 
  in 
  parse_rec 0 [] 
  

let fs_flex f = parse f (get_fs_html f)

let content = function
  | Some (_, body) -> Cohttp_lwt_body.string_of_body body
  | _ -> return ""

let download_fs_html_lwt f = 
  print_endline ("download begin " ^ (build_fs_url f));
  Cohttp_lwt_unix.Client.get (Uri.of_string (build_fs_url f))

let get_fs_html_lwt f =
  (download_fs_html_lwt f) >>= (fun response_body -> print_endline "finished download fs";content response_body)

let fs_lwt f =
  (get_fs_html_lwt f) >>= (fun html -> Lwt.return (parse f html))
    


  

  
      
