

let email_header = "\
From: Flite <noreply@massd.me>\r\n\
To: Rob <iamindcs@gmail.com>\r\n\
Subject: Your flite alert\r\n\
Content-Type: Multipart/Alternative" in
let email_msg = "<h1>Hi Rob</h1>" in
let data = email_header ^ "\r\n\r\n" ^ email_msg;
