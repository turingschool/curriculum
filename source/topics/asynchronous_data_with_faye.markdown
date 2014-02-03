---
layout: page
title: Asynchronous Data with Faye and PubSub
---
As web applications become more mature and advanced, there's a high demand for interactivity. We try to build web applications that act more like desktop applications.

No desktop application asks you to "click refresh." The elements of the page just update when there are changes. Let's look at how to make that happen.

## Getting New Data

When should your application fetch new data from the server? In order of increasing programming complexity *and* user enjoyment:

1. User-driven - a UI event, like clicking on an element
2. Time-driven - Using an interval timer to check for updates every X seconds
3. Supply-driven - Server-Side event which triggers action on the client when data on the server changes

### Time-Driven: Interval Timer

Writing an interval timer in JavaScript is very easy:

```javascript
setInterval(
  function() { alert "Tada!"},
  5000);
```

Or to do something more interesting:

```javascript
setInterval(
  function() { $('#chat').load('http://example.com/rooms/102/messages.json')},
  5000);
```

But this has issues:

* No updates in between intervals (UX)
* Causing server load even when there are no updates (Performance)

### Supply-Driven: Server-Side Event

When something changes on the server side how should it tell the client? HTTP is "stateless", so once the original transmission is complete the connection closes. The server has no idea which browsers are currently viewing which pages.

#### Solution 1: Flash

When web browsers can't do what you want them to do, use Adobe Flash. Now your application has two problems.

Flash is no longer an acceptable option.

#### Solution 2: Long Polling

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

Long polling kind of works. Reasons it can break:

* Necessitates many conncurrent connections on the server side which doesn't scale well
* Middle-men like proxies, firewalls, and browsers can often say "Ok, seriously, break it up you two" and drop connections after 30 to 90 seconds.

But at least it's not Flash. Long-polling is a decent solution.

#### Solution 3: Web Sockets

Web Sockets are the "right" solution, though they've been on the fringe for too long. You can dig into the nitty-gritty at http://en.wikipedia.org/wiki/WebSocket.

The basic idea is that Web Sockets are very lightweight open connections between the client and server. They look like HTTP conversations, so proxies and firewalls don't treat them any differently than normal web traffic. When a websocket is open, the server and client can have a "full-duplex" conversation -- each side can be talking and listening at the same time. It's like my in-laws house.

So what's the downside? The protocol isn't set in stone nor is it implemented in all browsers. We can try using Web Sockets, but we'll need the ability to fall back if the technology isn't available. Typically we go back to long-polling and, if that doesn't work out, consider Flash. Ugh.

##### This Sounds Hard

Yeah, and that's only the transport part. What about keeping track of which user is associated with which connection, handling transmission errors, layering on SSL, and all that?

Stand on the shoulders of James Coglan and the contributors to Faye.

### Faye Workshop

Faye is an awesome library to manage live connections between the server and clients. 

Let's all practice working with Faye. Break into your groups and:

1. Watch and *work through* the Faye episode on RailsCasts: http://railscasts.com/episodes/260-messaging-with-faye
2. Watch and *work through* the PrivatePub episode on RailsCasts: http://railscasts.com/episodes/316-private-pub
3. Implement pub/sub on JSBlogger (`git://github.com/JumpstartLab/blogger_advanced.git`) so that the dashboard is automatically updated when new articles or comments are added.

#### Other Links of Note

* Faye on GitHub: https://github.com/faye/faye
* Faye documentation: http://faye.jcoglan.com/ruby.html
* Faye::Redis Back-end: https://github.com/faye/faye-redis-ruby

#### Note on PrivatePub

PrivatePub doesn't seem to be particularly healthy as an OSS project. There are currently 28 issues and 5 pull requests. The most recent commit, a month ago, was Ryan adding a note saying that he isn't actively maintaining the library.

So expect some bumps along the way. Check the existing issues and pull requests if you run into problems. If you get interested in the domain, maybe fork it, merge the pull requests, and try solving some of the issues.
