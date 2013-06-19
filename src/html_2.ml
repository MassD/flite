open Flite.Price
open Flite.Flight
open Lwt

let print_html =
  Printf.sprintf "<html><body>%s%s%s</body></html>" (*title, table and footer*)

let print_table =
  Printf.sprintf "<table style='font-family: \"Trebuchet MS\", sans-serif;
    font-size: 14px;
    line-height: 1.4em;
    font-style: normal;
    border-collapse:separate;'>%s%s</table>" (*theader and tbody*)

let print_theader = 
  Printf.sprintf "<thead><tr>%s</tr></thead>"

let print_theader_th = 
  Printf.sprintf "<th style='padding:15px;
    color:#fff;
    text-shadow:1px 1px 1px #568F23;
    border:1px solid #93CE37;
    border-bottom:3px solid #9ED929;
    background-color:#9DD929;
    background:-webkit-gradient(
        linear,
        left bottom,
        left top,
        color-stop(0.02, rgb(123,192,67)),
        color-stop(0.51, rgb(139,198,66)),
        color-stop(0.87, rgb(158,217,41))
        );
    background: -moz-linear-gradient(
        center bottom,
        rgb(123,192,67) 2%%,
        rgb(139,198,66) 51%%,
        rgb(158,217,41) 87%%
        );
    -webkit-border-top-left-radius:5px;
    -webkit-border-top-right-radius:5px;
    -moz-border-radius:5px 5px 0px 0px;
    border-top-left-radius:5px;
    border-top-right-radius:5px;'>%s</th>"

let print_tbody = 
  Printf.sprintf "<tbody>%s</tbody>"

let print_tbody_th =
  Printf.sprintf "<tr><th style='color:#fff;
    text-shadow:1px 1px 1px #568F23;
    background-color:#9DD929;
    border:1px solid #93CE37;
    border-right:3px solid #9ED929;
    padding:0px 10px;
    background:-webkit-gradient(
        linear,
        left bottom,
        right top,
        color-stop(0.02, rgb(158,217,41)),
        color-stop(0.51, rgb(139,198,66)),
        color-stop(0.87, rgb(123,192,67))
        );
    background: -moz-linear-gradient(
        left bottom,
        rgb(158,217,41) 2%%,
        rgb(139,198,66) 51%%,
        rgb(123,192,67) 87%%
        );
    -moz-border-radius:5px 0px 0px 5px;
    -webkit-border-top-left-radius:5px;
    -webkit-border-bottom-left-radius:5px;
    border-top-left-radius:5px;
    border-bottom-left-radius:5px;'>%s</th>%s</tr>"

let print_td_desired = 
  Printf.sprintf "<td style='padding:10px;
    text-align:center;
    background-color:#99CCFF;
    border: 2px solid #6699FF;
    -moz-border-radius:2px;
    -webkit-border-radius:2px;
    border-radius:2px;
    color:#444;
    text-shadow:1px 1px 1px #fff;'>%s</td>"

let print_td_lower =
  Printf.sprintf "<td style='padding:10px;
    text-align:center;
    background-color:#FFC2C2;
    border: 2px solid #FF9999;
    -moz-border-radius:2px;
    -webkit-border-radius:2px;
    border-radius:2px;
    color:#444;
    text-shadow:1px 1px 1px #fff;'>%s</td>"

let print_td_other = 
  Printf.sprintf "<td style='padding:10px;
    text-align:center;
    background-color:#DEF3CA;
    border: 2px solid #E7EFE0;
    -moz-border-radius:2px;
    -webkit-border-radius:2px;
    border-radius:2px;
    color:#444;
    text-shadow:1px 1px 1px #fff;'>%s</td>"

let print_td i j desired_p p = 
    if i = 3 && j = 3 then
      print_td_desired
    else begin
      if p.price < desired_p.price then
	print_td_lower
      else 
	print_td_other
    end

let get_html f pl =
  let title =
    (Printf.sprintf "<h2>From %s to %s, depature on %s-%s, return on %s-%s</h2>" f.dep_ap f.arr_ap f.dep_mo f.dep_dy f.ret_mo f.ret_dy)
  in 
  let theader = 
    let rec ths i acc = 
      if i = 7 then acc
      else 
	let p = List.nth pl i in
	let th = print_theader_th p.actual_ret_date in
	ths (i+1) (acc^th) 
    in 
    print_theader (ths 0 "<th style='background:transparent;border:none;'></th>")
  in 
  let tbody =
    let desired_p = List.nth pl 24 in
    let rec tds i j acc_j = 
      if j = 7 then acc_j
      else 
	let p = List.nth pl (i*7+j) in
	let new_td_content = 
	  Printf.sprintf "<a href='%s'>%s</a><br><br>%s" p.airline_http p.airline (string_of_float p.price)
	in 
	tds i (j+1) (acc_j ^ (print_td i j desired_p p new_td_content))
    and trs i acc_i =
      if i = 7 then acc_i
      else 
	let p = List.nth pl (i*7) in
	trs (i+1) (acc_i ^ (print_tbody_th (p.actual_dep_date) (tds i 0 "")))
    in 
    print_tbody (trs 0 "")
  in 
  let table = print_table theader tbody 
  in 
  let footer = Printf.sprintf "<h3><a href='%s'>Click here for lastminute.com to buy</a></h3>" (Lastminute.build_fs_url f)
  in 
  print_html title table footer
	
let preprocess pl =
  let comp p1 p2 =
    let c1 = compare p1.actual_dep_date p2.actual_dep_date in
    if c1 = 0 then compare p1.actual_ret_date p2.actual_ret_date
    else c1
  in 
  List.sort comp pl;;

let format_pl f pl = get_html f (preprocess pl)


    
