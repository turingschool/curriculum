# Iteration 2 - Append, Prepend and Insert (Multiple Nodes)

Now we have nodes and a `LinkedList` class that manages the list. Next step is to add the `insert` and `prepend` methods as well as ensuring that `insert`, `append` and `prepend` works for both single and multiple nodes.

`prepend` will add nodes to the beginning of the list.

`insert` will insert one or more elements at a given position in the list. It takes two parameters, the first one is the position at which to insert nodes, the second parameter is the string of data to be inserted.

Expected behavior:

```ruby
> require "./lib/linked_list"
> LL = LinkedList.new
> LL.append("plop sup")
=> 2
> LL.all
=> "deep plop sup"
> LL.prepend("dop waa")
=> 2
> LL.all
=> "dop waa deep plop sup"
> LL.count
=> 5
> LL.insert(2, "woo wii")
=> "dop waa woo wii deep plop sup"
```