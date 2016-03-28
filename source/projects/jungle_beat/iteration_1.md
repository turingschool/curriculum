# Iteration 1 - Append, All and Count

Great! We have nodes. In this iteration we'll create the `LinkedList` class and start filling in its basic functionality.

We'll be adding the following methods:

1. `append` - adds a new piece of data (data can really be anything) to the list
2. `count` - tells us how many things are in the list
3. `to_string` - generates a string of all the elements in the list, separated by spaces

Expected behavior:

```ruby
> require "./lib/linked_list"
> list = LinkedList.new
=> <LinkedList head=nil #45678904567>
> list.head
=> nil
> list.append("doop")
=> "doop"
> list
=> <LinkedList head=<Node data="doop" next_node=nil #5678904567890> #45678904567>
> list.head.next_node
=> nil
> list.count
=> 1
> list.to_string
=> "doop"
```
