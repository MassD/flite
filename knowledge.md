## 2013.06.20

### --Ocsigen_http_client will give to server 2.18.217.8:80 a first probing period for pipelinin

[17:46] <jackinlost> can anyone tell me why I get this: --Ocsigen_http_client will give to server 2.18.217.8:80 a first probing period for pipelining.

[17:46] <def-lkb_> You are doing http requests using Http_client, right?

[17:48] <def-lkb_> Ocsigen tries to do http pipelining, that is reusing the same connection when doing multiple requests against the same server.

[17:49] <def-lkb_> To this end, it keeps a table of recent requests and servers status. These logging messages just keep you informed of what happens in this table.

[17:54] <jackinlost> oh good

[17:54] == ttamttam [~Thunderbi@2a02-8423-2330-8c00-6184-6aaf-0dc5-c89e.rev.sfr.net] has joined #ocsigen

[17:54] <jackinlost> thanks for your answer

[17:54] <jackinlost> so you mean, if I send 5 similar requests to the same server, Ocsigenserver will try to use one connection to do them all?

[17:55] <def-lkb_> If I remember well -- I don't know the exact implementation -- it will reuse the connection if it is no longer busy.