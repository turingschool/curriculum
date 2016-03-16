# Iteration 3 - Managing Nodes

Perfect, we are almost there! Next is to add `find`, `pop` and `includes?` methods.

`find` takes two parameters, the first indicates the first position to return and the second parameter specifies how many elements to return.

`pop` removes elements from the list. It takes an integer as a parameter which indicates how many elements will be popped off the list. If no parameter is given, it removes only one element.

`includes?` gives back true or false whether the supplied value is in the list.

Expected behavior:

```ruby
> require "./lib/linked_list"
> list = LinkedList.new
> list.append("deep woo whi shu blop")
=> 5
> list.all
=> "deep woo whi shu blop"
> list.find(2, 1)
=> "shi shu"
> list.pop
=> "blop"
> list.pop(2)
=> "shi shu"
> list.all
=> "deep woo"
```