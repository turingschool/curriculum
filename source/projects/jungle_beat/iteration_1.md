# Iteration 1 - Append, All and Count

Great! We have nodes. Next step is to create the `LinkedList` class.

We are also going to build the `append`, `to_string` and `count` methods. `append` will add nodes to the end of the list, `to_string` will return the data of the linked list in order, and `count` will return the number of nodes in the list.

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