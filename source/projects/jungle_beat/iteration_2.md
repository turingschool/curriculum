# Iteration 2 - Append, Prepend and Insert (Multiple Nodes)

Now we have nodes and a `LinkedList` class that manages the list. Next step is to add the `insert` and `prepend` methods as well as ensuring that `insert`, `append` and `prepend` works for both single and multiple nodes.

`prepend` will add nodes to the beginning of the list.

`insert` will insert one or more elements at a given position in the list. It takes two parameters, the first one is the position at which to insert nodes, the second parameter is the string of data to be inserted.

`prepend` and `append` takes a string parameter with data separated by spaces. Given the string "plop sup dip", three nodes should be added to the list.

Expected behavior:

```ruby
> require "./lib/linked_list"
> list = LinkedList.new
> list.append("plop sup")
=> 2
> list.alist
=> "deep plop sup"
> list.prepend("dop waa")
=> 2
> list.all
=> "dop waa deep plop sup"
> list.count
=> 5
> list.insert(2, "woo wii")
=> "dop waa woo wii deep plop sup"
```