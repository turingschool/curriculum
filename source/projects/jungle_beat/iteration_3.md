# Iteration 3 - Managing Nodes

Perfect, we are almost there! Next is to add `find`, `pop` and `includes?` methods.

`find` takes two parameters, the first indicates the first position to return and the second parameter specifies how many elements to return.

`includes?` gives back true or false whether the supplied value is in the list.

`pop` removes elements from the list. It takes an integer as a parameter which indicates how many elements will be popped off the list. If no parameter is given, it defaults to removing one node.

Expected behavior:

```ruby
....
> list.to_string
=> "deep woo shi shu blop"
> list.find(2, 1)
=> "shi"
> list.find(1, 3)
=> "woo shi shu"
> list.includes?("deep")
=> true
> list.includes?("dep")
=> false
> list.pop
=> "blop"
> list.pop(2)
=> "shi shu"
> list.to_string
=> "deep woo"
```