---
layout: page
title: Queuing It Up With `shift` / `unshift`
---

## Queueing it up with `shift`/`unshift`

A queue is pretty recognizable data structure because it shows up frequently in everyday life. While an American may say they're "standing in line" for a movie, a Briton would likely say they're "standing in queue" (or "queuing"). A queue is a first-in, first-out, or FIFO, structure.

Ruby `Array`s act as queues when we use the `pop` and `unshift` methods. We `unshift` elements onto the left side of the array and `pop` elements from the right. Alternatively, we could `push` elements onto the right side and `unshift` them from the left.

```ruby
queue = []
queue.unshift "cat"
#=> ["cat"]
queue.unshift "bear"
#=> ["bear", "cat"]
queue.unshift "ant"
#=> ["ant", "bear", "cat"]
queue.pop
#=> "cat"
queue
#=> ["ant", "bear"]
queue.pop
#=> "bear"
queue
#=> ["ant"]
queue.pop
#=> "ant"
queue
#=> []
```

With a queue, we can give priority to the oldest element.

Ruby does have an explicit `Queue` class, but it's built for sharing data between Ruby threads, not for the more general-purpose use cases here.
