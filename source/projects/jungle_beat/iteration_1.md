# Iteration 1 - Append, All and Count

Great! We have nodes. Next step is to build out the `LinkedList` class.

We are also going to build the `append`, `all` and `count` methods. `append` will add nodes to the end of the list, `all` will return the data of the linked list in order, and `count` will return the number of nodes in the list.

Let's also make sure that we can append multiple nodes using the `append` method.

Expected behavior:

```ruby
> require "./lib/linked_list"
> list = LinkedList.new
> list.append("plop pa")
=> "plop pa"
> list.head
=> "plop pa"
> list.head.next_node
=> nil
> list.count
=> 1
> list.all
=> "plop pa"
```