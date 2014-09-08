---
layout: page
title: Concurrency
---

Concurrent programming is hard. But as your push to scale applications it can make for huge performance improvements.

## Threads

The simplest method of concurrency is using Ruby threads. For example:

```ruby
begin
  numbers = Thread.new do
  100.times{ sleep 0.1; print "1" }
  end
  letters = Thread.new do
 	100.times{ print "a"; sleep 0.1 }
  end
  sleep 10
  numbers.join
  letters.join
end
```

Things to know about threads:

* Ruby will automatically switch between threads every 10ms
* If execution of the containing method completes and there isn't a `.join` for the thread, it will be terminated
* Threads all run in the same process, so they all stop during garbage collection
* Threads can deadlock

Overall, threads can give you some parallelism without much work. But the performance gains are limited.

## Fibers and Continuations

If you're comfortable with programming concurrent systems, them Ruby 1.9's fibers (also called continuations) are for you.

The best known usage of Fibers is with the EventMachine library: https://github.com/eventmachine/eventmachine/wiki

Generally, Fibers are powerful because you as the developer control when they start and stop. They are a lot of work because, well, you as the developer control when they start and stop.

In general, the complexity of programming fibers means that they'll be implemented in lower-level libraries like EventMachine, then we can use the APIs provided by the libraries in our application code.

Because of the nature of the MRI interpreter, Fibers still suffer from lockout during garbage collection. Platforms with more advanced GC, like Rubinus, will be able to improve this situation as they mature.