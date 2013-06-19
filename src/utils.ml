open Unix;;

let to_int32 = Int32.of_int;;

let to_utime s = 
  let sp_list = Str.split (Str.regexp_string "-") s in
  let year = List.nth sp_list 0 in
  let mo = List.nth sp_list 1 in
  let dy = List.nth sp_list 2 in
  let utime, _ = mktime
    {
      tm_sec = 0;
      tm_min = 0; 
      tm_hour = 0;
      tm_mday = int_of_string dy;
      tm_mon = (int_of_string mo) -1;
      tm_year = int_of_string year;
      tm_wday = 0;
      tm_yday = 0;
      tm_isdst = false;
    }
  in 
  utime;;

(* Using Unix.localtime instead of Unix.gmtime *)
(* http://stackoverflow.com/questions/17188464/why-unix-tm-hour-is-the-real-hour-minus-one *)
let string_of_utime time = 
  let gtime = Unix.localtime time in
  Printf.sprintf "%d-%d-%d %d:%d:%d" (gtime.tm_year+1900) (gtime.tm_mon+1) (gtime.tm_mday) (gtime.tm_hour) gtime.tm_min gtime.tm_sec

let current_hour () = let ut = Unix.localtime (Unix.time ()) in ut.tm_hour


