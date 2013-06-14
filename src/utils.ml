open Unix;;

let to_int32 = Int32.of_int;;

let string_of_utime time = 
  let gtime = Unix.gmtime time in
  (string_of_int (gtime.tm_year)) ^ "-"
  ^ (string_of_int (gtime.tm_mon)) ^ "-"
  ^ (string_of_int (gtime.tm_mday));;
