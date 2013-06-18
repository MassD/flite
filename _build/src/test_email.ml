(*http://projects.camlcity.org/projects/dl/ocamlnet-3.6.5/doc/html-main/Netsendmail_tut.html*)
let s_html = "<html>...</html>";;

let body = (Netsendmail.wrap_attachment ~content_type:("text/html", [])
                                        (new Netmime.memory_mime_body s_html))::[];;

let email = Netsendmail.wrap_mail
        ~from_addr:("Flite Price Alert", "iamindcs@gmail.com")
        ~to_addrs:[("xinuo", "iamindcs@gmail.com")]
        ~out_charset:`Enc_utf8
        ~subject:"price info"
        (
          Netsendmail.wrap_parts 
            ~content_type:("multipart/mixed",[])
            body);;

 Netsendmail.sendmail ~mailer:"/usr/sbin/sendmail" email;;
