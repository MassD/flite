open Lwt


let u = "http://www.lastminute.com/trips/flightlist/flexiCal?arrAp=LHR&depMo=2013-9&depDy=15&depAp=HKG&retMo=2013-9&retDy=22&srchSnr=0&showFlexiCal=True&flexDate=True&srchAdt=1&path=flights&airline=NONE&pTxId=1501649&numLegs=2&srchChld=0&configId=S72722479&intcmp=tsm&redirectOnly=false&source=&cabins=X&srchInf=0"

let u1 = "http://www.lastminute.com/"

let u2 = "http://www.google.com/"

let u3 = "http://twitter.com"


(* a simple function to access the content of the response *)
let content = function
  | { Ocsigen_http_frame.frame_content = Some v } ->
      Ocsigen_stream.string_of_stream 1073741823 (Ocsigen_stream.get v)
  | _ -> return ""


(* launch both requests in parallel *)
let t = Lwt_list.map_p Ocsigen_http_client.get_url [ u]

(* maps the result through the content function *)
let t2 = t >>= Lwt_list.map_p content

let t3 = t2 >>= Lwt_list.iter_p (Lwt_io.printf "%s")  


(* launch the event loop *)
let v = Lwt_main.run t3




