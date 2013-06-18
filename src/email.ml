(*http://projects.camlcity.org/projects/dl/ocamlnet-3.6.5/doc/html-main/Netsendmail_tut.html*)
(*http://stackoverflow.com/questions/17157392/how-to-send-email-in-ocaml-with-setting-content-type-multipart-alternative*)
let send (user,user_email,html) = 
  let body = 
    (Netsendmail.wrap_attachment 
       ~content_type:("text/html", [])
       (new Netmime.memory_mime_body html))::[] in
  Netsendmail.sendmail ~mailer:"/usr/sbin/sendmail" 
    (Netsendmail.wrap_mail
       ~from_addr:("Flite Price letter", "no-reply@massd.me")
       ~to_addrs:[(user, user_email)]
       ~out_charset:`Enc_utf8
       ~subject:"price info"
       (Netsendmail.wrap_parts 
          ~content_type:("multipart/mixed",[])
          body))
