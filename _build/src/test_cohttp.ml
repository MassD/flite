open Lwt
open Cohttp
open Cohttp_lwt_unix

let u = "http://www.lastminute.com/trips/flightlist/flexiCal?arrAp=LHR&depMo=2013-9&depDy=15&depAp=HKG&retMo=2013-9&retDy=22&srchSnr=0&showFlexiCal=True&flexDate=True&srchAdt=1&path=flights&airline=NONE&pTxId=1501649&numLegs=2&srchChld=0&configId=S72722479&intcmp=tsm&redirectOnly=false&source=&cabins=X&srchInf=0"

let u1 = "http://www.lastminute.com/"

let u2 = "http://www.google.com"

let u3 = "http://twitter.com"

let redirect = function
  | Some (response, _) -> 
    let headers = Response.headers response in
    let location = Header.get headers "location" in
    begin 
      match location with 
      | Some l -> return l
      | _ -> return "no location"
    end 
  | _ -> return "no location"

(* a simple function to access the content of the response *)
let content = function
  | Some (_, body) ->  Cohttp_lwt_body.string_of_body body
  | _ -> return ""

let h = Header.add (Header.init ()) "User-Agent" "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.110 Safari/537.36"

(* launch both requests in parallel *)
let t = Lwt_list.map_p (Cohttp_lwt_unix.Client.get ~headers:h)
  (List.map Uri.of_string
     [ u1;
     (*"http://www.google.com";
     "http://www.bbc.co.uk"*)])

(* maps the result through the content function *)
let t2 = t >>= Lwt_list.map_p content

let t3 = t2 >>= Lwt_list.iter_p (Lwt_io.printf "%s")  


(* launch the event loop *)
let v = Lwt_main.run t3




