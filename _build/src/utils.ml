open Unix;;

let to_int32 = Int32.of_int;;

let string_of_utime time = 
  let gtime = Unix.gmtime time in
  (string_of_int (gtime.tm_year)) ^ "-"
  ^ (string_of_int (gtime.tm_mon)) ^ "-"
  ^ (string_of_int (gtime.tm_mday));;

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

let string_of_utime ut =
  let t = Unix.gmtime ut in
  Printf.sprintf "%d-%d-%d %d:%d" t.tm_year t.tm_mon t.tm_mday t.tm_hour t.tm_min;; 


