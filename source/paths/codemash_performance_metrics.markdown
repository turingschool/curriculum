---
layout: page
title: Metrics-Driven Rails Performance
---

Hi, thanks for coming to my session at CodeMash 2012. Here are the slides:

http://speakerdeck.com/u/j3/p/metrics-driven-rails-performance

The sample project I used is available here:

https://github.com/jumpstartlab/jsblogger_advanced

To get it ready to rock:

* Run `bundle`
* Open the `db/seeds.rb` and change the `10.times` to `1000.times`
* You may optionally want to implement pagination on the `Articles#index` page. I used Kaminari following this tutorial: http://tutorials.jumpstartlab.com/topics/better_views/pagination.html
* Follow the directions in the slides

Enjoy!

### Other Resources

Aman Gupta has an interesting presentation about Debugging Ruby up here:

http://speakerdeck.com/u/tmm1/p/debugging-ruby-performance

It's a great jumping-off point if you want to dive into the depths of deep debugging/performance.