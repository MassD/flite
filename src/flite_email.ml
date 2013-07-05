open Flite_type
open Flite_type.Journey
open Flite_type.Price
open Flite_type.Alert
open Lwt
open Logging

(*http://projects.camlcity.org/projects/dl/ocamlnet-3.6.5/doc/html-main/Netsendmail_tut.html*)
(*http://stackoverflow.com/questions/17157392/how-to-send-email-in-ocaml-with-setting-content-type-multipart-alternative*)
let send (user,user_email,subj,html) = 
  flite_notice "begin emailing %s, %s" user user_email;
  let body = 
    (Netsendmail.wrap_attachment 
       ~content_type:("text/html", [])
       (new Netmime.memory_mime_body html))::[] in
  try (
    Netsendmail.sendmail ~mailer:"/usr/sbin/sendmail" 
      (Netsendmail.wrap_mail
	 ~from_addr:("Flite Price letter", "no-reply@massd.me")
	 ~to_addrs:[(user, user_email)]
	 ~out_charset:`Enc_utf8
	 ~subject:subj
	 (Netsendmail.wrap_parts 
            ~content_type:("multipart/mixed",[])
            body));
    flite_notice "email sent to %s, %s" user user_email
  ) with
    | _ as exn ->
      flite_error ~exn:exn "Cannot email %s, %s" user user_email

let send_lwt (user,user_email,subj,html) = 
  return (send (user,user_email,subj,html))

let format_pl = Html.format_pl

let email a j pl = 
  let html = format_pl j pl in
  match html with 
    | Some h ->
      (* ✈ in subject http://www.emailmarketingtipps.de/2012/02/21/specials-characters-and-symbols-in-email-subject-lines-does-it-work/, http://www.webatic.com/run/convert/qp.php *)
      let subj = Printf.sprintf "?UTF-8?Q?=E2=9C=88?= %s to %s, %s-%s, back on %s-%s, checked on %s" j.dep_ap j.arr_ap j.dep_mo j.dep_dy j.ret_mo j.ret_dy (Utils.string_of_utime j.last_fsed) in
      send_lwt (a.user, a.email, subj, h)
    | None -> return_unit
  




