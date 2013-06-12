type flight =
    { 
      airline : string;
      dep_ap : string;
      arr_ap : string;
      dep_date : string;
      ret_date : string;
      price : float;
    };;
 
val fs_flex: string -> string -> string -> string -> string -> string -> flight list;;
