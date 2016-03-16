# Iteration 1 - Append, All and Count

Great! We have nodes. Next step is to build out the `LinkedList` class.

We are also going to build the `all` and `count` methods. `all` will return the data of the linked list in order, and `count` will return the number of nodes in the list.

Let's also make sure that we can append multiple nodes using the `append` method.

Expected behavior:

```ruby
> require "./lib/linked_list"
> LL = LinkedList.new
> LL.append("plop pa")
=> "plop pa"
> LL.head
=> "plop"
> LL.head.next_node
=> "pa"
> LL.count
=> 2
> LL.all
=> "deep plop"
```