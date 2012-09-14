---
layout: page
title: Faye Concepts, Interval Timer
---

## Faye Concepts

* When do you serve/fetch data?
  * UI Event
  * Interval Timer
  * Server-Side Event

* Some Helpful Links:
 * Faye on Github: [https://github.com/faye/faye](https://github.com/faye/faye)
 * Faye documentation: [http://faye.jcoglan.com/ruby.html](http://faye.jcoglan.com/ruby.html)
 * Faye::Redis Back-end: [https://github.com/faye/faye-redis-ruby](https://github.com/faye/faye-redis-ruby)

### Interval Timer

Writing an interval timer in JavaScript is very easy...

```javascript
setInterval(
  function() { alert "Tada!"},
  5000);
```

Or to do something more interesting:

```javascript
setInterval(
  function() { $('#chat').load('http://mychat.com/rooms/102/messages.json')},
  5000);
```

But this has issues:

* No updates in between intervals (UX)
* Causing server load even when there are no updates (Performance)