# Iteration 0 - Node Basics

We are going to compose a linked list with nodes, so the first part of our program we are going to build out is the `Node` and `LinkedList` class. We are also going to add the `append` method so that we can add nodes to our linked list.

Expected behavior:

```ruby
> require "./lib/linked_list"
> LL = LinkedList.new
> LL.head
=> nil
> LL.append("deep")
=> "deep"
> LL.head
=> <Node data="deep" next_node=nil #234567890>
> LL.head.data
=> "deep"
> LL.head.next_node
=> nil
```