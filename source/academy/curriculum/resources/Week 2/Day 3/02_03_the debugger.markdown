---
layout: page
title: The Debugger
---

## Understanding and Debugging Ruby

As a developer you spend some small fraction of your time writing code, the rest of it is spent understanding what's already been written and debugging. Today we're going to go through a few techniques to make that easier. Ruby tries to help you read error messages. Let's intentionally create a few errors and breakdown the issues in a pairing exercise.

### The Debugger

We have a Rails-centric tutorial on the debugger here:

[http://tutorials.jumpstartlab.com/topics/debugging/debugger.html](http://tutorials.jumpstartlab.com/topics/debugging/debugger.html)

Let's practice:

* installing the debugger: `gem install debug-19`
* walking through execution
* using the core instructions
  * `continue`
  * `step`
  * `next`
  * `list`
  * `display`
* tracing execution with your project