---
layout: page
title: Ruby Servers
---

## Ruby Servers

* Ruby server's roles
* Why do you need it?
* Pros & Cons
* Options
  * Webrick
  * Thin / Mongrel
  * Passenger
  * Unicorn
  * Puma

### Workshop Time

Configure your front-end web server and underlying Ruby servers so that:

* http://localhost/ reaches the static page from before
* http://localhost/blog reaches an instance of JSBlogger ([https://github.com/JumpstartLab/jsblogger_advanced](https://github.com/JumpstartLab/jsblogger_advanced))
* http://localhost/feed reaches an instance of SimpleFeed ([https://github.com/JumpstartLab/simple_feed](https://github.com/JumpstartLab/simple_feed))

If you're really bold, get each app working with a different Ruby server.

We'll talk more about database servers tomorrow, in the meantime do whatever works to get the apps running -- probably using SQLite3 is the easiest.
