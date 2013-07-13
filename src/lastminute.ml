open Http_client.Convenience;;
open Flite_type
open Flite_type.Journey
open Flite_type.Price
open Flite_type.Airline
open Flite_mongo_airline
open Lwt
open Ocsigen_http_frame
open Http_header
open Logging
open Cohttp_lwt

let airline_tbl =
  let al = Lwt_main.run ((get_all_airlines ()) >>= (fun al -> return al)) in
  let tbl = Hashtbl.create (List.length al) in
  List.iter (fun a -> Hashtbl.add tbl a.name a) al;
  let l = Hashtbl.length tbl in
  if l > 0 then lastminute_notice "read %d airlines into hashtbl" l
  else lastminute_error "%s" "Cannot obtain any airlines";
  tbl

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

let build_fs_url j = 
  let url = Printf.sprintf "%s&depAp=%s&arrAp=%s&depMo=%s&depDy=%s&retMo=%s&retDy=%s" fs_url_base j.dep_ap j.arr_ap j.dep_mo j.dep_dy j.ret_mo j.ret_dy in
  lastminute_notice "built fs_url=%s" url;
  url

let get_fs_html j = http_get (build_fs_url j)

let parse j html = 
  let html_len = String.length html in
  lastminute_notice "lastminute html length=%d, %s" html_len html;
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
	      journey_id = j.id;
	      airline = String.capitalize airline;
	      airline_http = 
		(
		  let low_airline = String.lowercase airline in
		  if Hashtbl.mem airline_tbl low_airline then
		    let a = Hashtbl.find airline_tbl low_airline in
		    a.http
		  else
		    (
		      lastminute_warning "cannot obtain the airline http for %s" airline;
		      ""
		    )
		);
	      actual_dep_date = dep_mo ^ "-" ^ dep_dy;
	      actual_ret_date = ret_mo ^ "-" ^ ret_dy;
	      price = float_of_string price;
	      last_checked = Unix.time ();
	      expired = false;
	    } in
	  parse_rec (next+1) (fr::acc)
	) with Not_found -> acc
    end 
  in 
  parse_rec 0 [] 
  

let fs_flex j = parse j (get_fs_html j)

let content_ocsi = function
  | { Ocsigen_http_frame.frame_content = Some v } ->
      Ocsigen_stream.string_of_stream 1073741823 (Ocsigen_stream.get v)
  | _ -> return ""

let download_fs_html_lwt_ocsi j = 
  lastminute_warning "begin download, journey=%d" j.id;
  try_lwt (
    Ocsigen_http_client.get_url ~headers:(Http_headers.add Http_headers.user_agent "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1468.0 Safari/537.36" Http_headers.empty) (build_fs_url j)) with
    | exn -> 
      lastminute_error ~exn:exn "download journey=%d (%s) has problem, returning \"\"" j.id (build_fs_url j);
      return 
	{
	  frame_header=
	    {
	      mode = Answer (-1);
	      proto = HTTP11;
	      headers = Http_headers.empty
	    };
	  frame_content=None;
	  frame_abort=(fun () -> return_unit)
	}


let content_cohttp = function
  | Some (_, body) ->  Cohttp_lwt_body.string_of_body body
  | _ -> return ""

let download_fs_html_lwt_cohttp j = 
  lastminute_notice "begin download, journey=%d" j.id;
  try_lwt (
    Cohttp_lwt_unix.Client.get (Uri.of_string (build_fs_url j))
    (*Ocsigen_http_client.get_url ~headers:(Http_headers.add Http_headers.user_agent "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1468.0 Safari/537.36" Http_headers.empty) (build_fs_url j)*))  with
    | exn -> 
      lastminute_error ~exn:exn "download journey=%d (%s) has problem, returning \"\"" j.id (build_fs_url j);
      return None

let content = content_ocsi
let download_fs_html_lwt = download_fs_html_lwt_ocsi

let get_fs_html_lwt j =
  (download_fs_html_lwt j) >>= (fun response_body -> lastminute_notice "finished download journey=%d" j.id;content response_body)

let fs_lwt j =
  (get_fs_html_lwt j) >>= 
    (fun html -> 
      let pl = parse j html in
      let len = List.length pl in 
      if len = 0 then 
	(lastminute_warning "cannot obtain any price for journey=%d, html=%s" j.id html;
	 Lwt.return None)
      else 
	(lastminute_notice "obtained %d prices for journey=%d\n" len j.id;
	 Lwt.return (Some pl)
	)
    )
    


  

  
      
