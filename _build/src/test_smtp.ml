open Netsmtp

let h = Netsmtp.connect "localhost";;
Netsmtp.helo h "localhost";;
Netsmtp.mail h "iamindcs@gmail.com";;
let email_header = "\
From: John Smith <john.smith@example.com>
To: John Doe <john-doe@example.com>
Subject: surprise";;
let email_msg = "Happy Birthday";;
Netsmtp.data h (email_header ^ "\r\n\r\n" ^ email_msg);;
Netsmtp.quit h;;
