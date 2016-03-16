# Iteration 2 - Append, Prepend and Insert (Multiple Nodes)

Now we have nodes and a `LinkedList` class that manages the list. Next step is to add the `insert` and `prepend` methods.

`prepend` will add nodes to the beginning of the list.

`insert` will insert one or more elements at a given position in the list. It takes two parameters, the first one is the position at which to insert nodes, the second parameter is the string of data to be inserted.

Expected behavior:

```ruby
> require "./lib/linked_list"
> list = LinkedList.new
> list.append("plop")
=> 1
> list.to_string
=> "plop"
> list.append("suu")
=> 1
> list.prepend("dop")
=> 1
> list.to_string
=> "dop plop suu"
> list.count
=> 3
> list.insert(1, "woo")
=> "dop plop woo suu"
```