# Iteration 4 - Tying It All Together

Awesome! We have built out almost the entire program. At this point, go through your code (and tests) to make sure the methods you have built comply with these descriptions:

* `append` an element to the end of the list
* `prepend` an element at the beginning of the list
* `all` return all elements in the linked list in order
* `insert` one or more elements at an arbitrary position in the list
* `includes?` gives back `true` or `false` whether the supplied value is in the list
* `pop` one or more elements from the end of the list
* `count` the number of elements in the list
* `find` one or more elements based on arbitrary positions in the list. The first parameter indicates the first position to return and the second parameter specifies how many elements to return.

The last step is to actually play sounds with our `JungleBeat` class.

Expected behavior:

```ruby
> require "./lib/jungle_beat"
> jb = JungleBeat.new("deep doop shi shu woo")
=> 5
> jb.play
=> 5 (as well as playing the sounds!)
```
