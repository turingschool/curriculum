# Iteration 0 - Node Basics

We are going to compose a linked list with nodes, so the first part of our program we are going to build out is the `Node` class.

Expected behavior:

```ruby
> require "./lib/node"
> node = Node.new("plop")
> node.data
=> "plop"
> node.next_node
=> nil
```