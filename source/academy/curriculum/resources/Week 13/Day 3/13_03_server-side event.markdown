---
layout: page
title: Server-Side Event
---

## Server-Side Event

When something changes on the server side how should it tell the client? HTTP is "stateless", so once the transmission is complete the connection closes. The server has no idea which browsers are currently viewing which pages.

### Solution 1: Flash

When web browsers can't do what you want them to do, use Adobe Flash. Now your restaurant site has two problems.

### Solution 2: Long Polling

There is state during a connection. What if the data transfer went like this:

* *CLIENT*: Can have the messages page?
* *SERVER*: Yeah, here's the first part
* *SERVER*: Ok, here's some more of the page...and there's more coming soon.
* *long delay*
* *SERVER*: Here's the end of that thing you asked for. Oh, and here's a little special gift too.
* *CLIENT*: Thanks for that data. What's this gift? It says I have to ask you for...more data? Can I get that data?
* *SERVER*: Yeah, just a sec.
* *SERVER*: Ok, keep waiting.
* *SERVER*: Here you go bro, and a special gift with it you'll never guess what it is!
* *CLIENT*: Data! And a gift for me? Wait says I have to ask you for more data...
* *(repeat to infinity)*

Long polling kind of works. Reasons it sucks or breaks:

* Necessitates many conncurrent connections on the server side which doesn't scale well
* Middle-men like proxies, firewalls, and browsers can often say "Ok, seriously, break it up you two" and drop connections after 30 to 90 seconds.

But at least it's not Flash. Long-polling is a half-decent fallback when you can't use...

#### Web Sockets

Web Sockets are the "right" solution, though they've been on the fringe for too long. You can dig into the nitty-gritty at http://en.wikipedia.org/wiki/WebSocket.

The basic idea is that Web Sockets are very lightweight open connections between the client and server. They look like HTTP conversations, so proxies and firewalls don't treat them any differently than normal web traffic. When a websocket is open, the server and client can have a "full-duplex" conversation -- each side can be talking and listening at the same time. It's like my in-laws house.

So what's the downside? The protocol isn't set in stone nor is it implemented in all browsers. We can try using Web Sockets, but we'll need the ability to fall back if the technology isn't available. Typically we go back to long-polling and, if that doesn't work out, consider Flash. Ugh.

##### This Sounds Hard

Yeah, and that's only the transport part. What about keeping track of which user is associated with which connection, handling transmission errors, layering on SSL, and all that?

Stand on the shoulders of James Coglan and the contributors to Faye.
