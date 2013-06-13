type fs_result =
    { 
      flight: Flight.t;
      airline : string;
      actual_dep_date : string;
      actual_ret_date : string;
      price : float;
    }
 
val fs_flex: Flight.t -> fs_result list;;
