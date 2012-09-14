---
layout: page
title: Making a Stack with `push` / `pop`
---

## Making a stack with `push`/`pop`

A stack is a collection where the last element added to it will be the first element to be removed, a concept known as last-in, first-out, or LIFO. The usual example for thinking about this is a stack of food trays in a cafeteria: when a tray is placed on top of the stack, it will be the next tray to be picked up and used, unless another tray is put on top of it beforehand.

The operations for manipulating a stack are called `push` and `pop`, and Ruby `Array` objects implement them. We `push` elements onto the `Array` instance and we `pop` elements off of it. It looks like this:

```ruby
stack = []
stack.push "cat"
#=> ["cat"]
stack.push "bear"
#=> ["cat", "bear"]
stack.push "ant"
#=> ["cat", "bear", "ant"]
stack.pop
#=> "ant"
stack
#=> ["cat", "bear"]
stack.pop
#=> "bear"
stack
#=> ["cat"]
stack.pop
#=> "cat"
stack
#=> []
```

Stacks, among other handy uses, allow us to give priorty to things that have happened the most recently and can be useful for recursive operations.