open Flight;;

let f = 
  { 
    dep_ap = "LON";
    arr_ap = "PEK";

    dep_mo = "2013-9";
    dep_dy = "20";

    ret_mo = "2013-10";
    ret_dy = "13";
    
    email = "iamindcs@gmail.com";
    frequency = 6.0;
    desired_airline = "";
  }

(*let f1 = Flight.create "LON" "PEK" "2013-9" "20" "2013-10" "13" 6.0 None;;*)

let fr_list = Lastminute_fs.fs_flex f;;
let _ = print_int (List.length fr_list); print_endline "";;
