# Iteration 0 - Node Basics

Our Linked List will ultimately be composed of individual nodes, so in this iteration we'll start with building out these nodes.
Note that they are quite simple -- a Node simply needs to have a slot for some data and a slot for a "next node". Eventually this
`next_node` position will be what we use to link the multiple nodes together to form the list.

For this iteration, build a simple node class that can perform these functions:

```ruby
> require "./lib/node"
> node = Node.new("plop")
> node.data
=> "plop"
> node.next_node
=> nil
```
