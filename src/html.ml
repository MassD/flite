open Flite.Price



let price_theader = 
  "<thead>
    <tr>
      <th scope='col' style='font-size: 13px;font-weight: normal;padding: 8px;background: #b9c9fe;border-top: 4px solid #aabcfe;border-bottom: 1px solid #fff;color: #039;'>Airline</th>
      <th scope='col' style='font-size: 13px;font-weight: normal;padding: 8px;background: #b9c9fe;border-top: 4px solid #aabcfe;border-bottom: 1px solid #fff;color: #039;'>Departure Date</th>
      <th scope='col' style='font-size: 13px;font-weight: normal;padding: 8px;background: #b9c9fe;border-top: 4px solid #aabcfe;border-bottom: 1px solid #fff;color: #039;'>Return Date</th>
      <th scope='col' style='font-size: 13px;font-weight: normal;padding: 8px;background: #b9c9fe;border-top: 4px solid #aabcfe;border-bottom: 1px solid #fff;color: #039;'>Price</th>
      <th scope='col' style='font-size: 13px;font-weight: normal;padding: 8px;background: #b9c9fe;border-top: 4px solid #aabcfe;border-bottom: 1px solid #fff;color: #039;'>Last Checked</th>
    </tr>
  </thead>\n"

let price_table = 
  Printf.sprintf "<html><body><table style=\"font-family: 'Lucida Sans Unicode', 'Lucida Grande', Sans-Serif;font-size: 12px;margin: 45px;width: 480px;text-align: left;border-collapse: collapse;\" summary='Newest price info'>
      %s%s
   </table></body></html>\n" price_theader

let price_tbody = Printf.sprintf "<tbody>%s</tbody>\n"

let price_tr = Printf.sprintf "<tr>%s</tr>\n"

let price_td = Printf.sprintf "<td style='padding: 8px;background: #e8edff; border-bottom: 1px solid #fff;color: #669;border-top: 1px solid transparent;'>%s</td>\n"

let format_pl pl =
  let format_p p =
    let airline = price_td p.airline in
    let dep_date = price_td p.actual_dep_date in
    let ret_date = price_td p.actual_ret_date in
    let price = price_td (string_of_float p.price) in
    let last_checked = price_td (Utils.string_of_utime p.last_checked) in
    let tr_content = airline^dep_date^ret_date^price^last_checked in
    price_tr tr_content
  in
  price_tbody (price_tbody (List.fold_left (fun r p -> r ^ (format_p p)) "" pl))
    
