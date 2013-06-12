let f_list = Lastminute_fs.fs_flex "LON" "PEK" "2013-9" "20" "2013-10" "13";;
let _ = print_int (List.length f_list);;

let _ =
    let s = "foo bar string" in
    let reg = Str.regexp_string "bar" in
    print_int (Str.search_forward reg s 0);;
