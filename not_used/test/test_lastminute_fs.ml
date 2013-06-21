open Flite.Flight;;

let f = 
  { 
    dep_ap = "LON";
    arr_ap = "PEK";

    dep_mo = "2013-9";
    dep_dy = "20";
    dep_utime = Utils.to_utime ("2013-9"^"-"^"20");

    ret_mo = "2013-10";
    ret_dy = "13";
    ret_utime = Utils.to_utime ("2013-10"^"-"^"13");
    
    desired_airline = "";
    id = 0;
  }

(*let f1 = Flight.create "LON" "PEK" "2013-9" "20" "2013-10" "13" 6.0 None;;*)

let fr_list = Lastminute.fs_flex f;;
let _ = print_int (List.length fr_list); print_endline "";;
