---
layout: page
title: Focus on Collections
---

We write programs to deal with collections of data. Let's look at some of the tools you'll need to manage and manipulate them effectively.

### `Enumerable`

The granddaddy of it all. The `Enumerable` module can be mixed into any class which implements an `each` method. Most any class that acts like a collection will mixin `Enumerable`, so it's methods are some of the most valuable you can study.

You'll find that most `Enumerable` methods work with blocks. The method generally iterates through the collection, runs the block once for each element, then does _something_ with the results.

The full API is at http://ruby-doc.org/core-1.9.3/Enumerable.html, but below are a few of the best.

#### `all?`

Is the block true for *all* elements in the collection?

```ruby
%w{ant bear cat}.all? {|word| word.length >= 3}   #=> true
```

#### `any?`

Is the block true for at least one element?

```ruby
%w{ant bear cat}.any? {|word| word.length >= 5}   #=> false
%w{ant bear cat}.any? {|word| word.length >= 4}   #=> true
```

#### `collect` / `map`

One of the very most common, these synonym methods go through each element of the collection, run the block, gather the return value, then return a collection of those values.

```ruby
%w{ant bear cat}.collect {|word| word.length}   #=> [3, 4, 3]
```

#### `each_slice`

Slice the collection into smaller collections, then iterate through each of those:

```ruby
%w{ant bear cat dog bird fish}.each_slice(2) {|animals| puts animals.join}
#=> antbear
#=> catdog
#=> birdfish
```

#### `each_with_index`

Uses two local block parameters to iterate through the collection but also use the element's position in the origininal collection:

```ruby
%w{ant bear cat}.each_with_index {|word, i| puts [i, word].join(". ")}
#=> 0. ant
#=> 1. bear
#=> 2. cat
```

#### `detect` / `find`

These synonym methods will return the first result for which the block is true.

```ruby
%w{ant bear cat}.find {|word| word.length == 3}
#=> "ant"
```

#### `select` / `find_all`

These synonym methods will return an array of elements for which the block is true. It'll still be an array even if only one element was found.

```ruby
%w{ant bear cat bird}.select {|word| word.length == 4}
#=> ["bear", "bird"]
```

#### `grep`

This method is a searching chainsaw. It's a little different from `select` in that it can take a "pattern" argument which is a Regular Expression or a Range. It will return an array of the matching elements.

These synonym methods will return an array of elements for which the block is true. It'll still be an array even if only one element was found.

```ruby
%w{ant bear cat bird}.grep /b/
#=> ["bear", "bird"]
```

Here the regular expression matches all words containing a `b`. Where it gets interesting is if you also pass in a block, you get a result that's similar to calling `select` to pick elements, then `collect` to run an operation and gather the results.

```ruby
%w{ant bear cat bird}.grep(/b/){|word| word.length}
#=> [4, 4]
```

The results, `[4, 4]`, are the lengths of `"bear"` and `"bird"`.

#### `group_by`

This method will run a block for each element and return a `Hash` with the result as a key and an array containing all elements which generated that result as the value.

```ruby
%w{ant bear cat bird}.group_by{|word| word.length}
#=> {3=>["ant", "cat"], 4=>["bear", "bird"]}
```

#### `include?`

Does this collection contain the specified object?

```ruby
%w{ant bear cat bird}.include?("cat")
#=> true
```

#### `inject` / `reduce`

The most lauded and most hated method in `Enumerable`, you can use `inject` to create magical rainbows while simultaneously confusing your colleagues.

```ruby
%w{ant bear cat bird}.inject(0){|sum, word| sum + word.length}
#=> 14
```

This effectively says "Start with the value `0`, put that in a variable `sum`, go through the collection and for each element add the length of the element to `sum`, returning `sum`".

#### `max` / `min`

These methods are basically shortcuts. `max` is equivalent to `.sort.last` while `min` is equivalent to `.sort.first`

```ruby
%w{ant bear cat bird}.max
#=> "cat"
%w{ant bear cat bird}.min
#=> "ant"
```

#### `max_by` / `min_by`

Similarly, these are like shortcuts for using `sort_by`:

```ruby
%w{ant bear cat bird}.max_by{|word| word.chars.max}
# => "ant"
%w{ant bear cat bird}.min_by{|word| word.chars.min}
# => "ant"
```

With `max_by`, here, we get `"ant"` because it has the "maximum" letter of all the words, `"t"`.

With `min_by`, we get `"ant"` because it has the "minimum" letter of all the words, `"a"`.

#### `partition`

This method is used to divide a collection into two sets based on whether the block is true or false:

```ruby
%w{ant bear cat bird}.partition{|word| word.include?("a")}
# => [["ant", "bear", "cat"], ["bird"]]
```

It returns an `Array` which contains two nested arrays. This is often used with Ruby's automatic decomposition to store the results into separate variables:

```ruby
has_a, no_a = %w{ant bear cat bird}.partition{|word| word.include?("a")}
# => [["ant", "bear", "cat"], ["bird"]]
has_a
# => ["ant", "bear", "cat"]
no_a
# => ["bird"]
```

#### `reject`

The opposite of `select`, find the elements for which the block is false:

```ruby
%w{ant bear cat bird}.reject{|word| word.include?("a")}
# => ["bird"]
```

This is often used with the alternate form `reject!` to remove the elements for which the block is true:

```ruby
words = %w{ant bear cat bird}
# => ["ant", "bear", "cat", "bird"]
words.reject!{|word| word.include?("a")}
# => ["bird"]
words
# => ["bird"]
```

#### `sort` / `sort_by`

The simple `sort` will delegate responsibility to the "spaceship method", `<=>`, defined for the object. For `String` objects, spaceship sorts them into alphabetical order with all capital letters coming before any lowercase letters.

```ruby
%w{ant bear Cat bird}.sort
# => ["Cat", "ant", "bear", "bird"]
```

Note how `"C"` comes first.

The `sort_by` method accepts a block to run on each element, then uses spaceship to sort the resulting values:

```ruby
%w{ant bear Cat bird}.sort_by{|word| word.length}
# => ["ant", "Cat", "bear", "bird"]
```

But within the similar lengths of 3 and 4, how do you determine the sorting order? A common technique is to have the block return an array with multiple criteria for sorting:

```ruby
%w{ant bear Cat bird}.sort_by{|word| [word.length, word]}
# => ["Cat", "ant", "bear", "bird"]
```

Now it sorts by length first, then by alphabetical order within a common length.

### More than just an `Array`

The most common object implementing `Enumerable` that you'll work with is certainly `Array`. The abstract data type we call array can be thought of as a contiguous list of elements, like a set of train cars on a track, each with their own payload, that can be walked from beginning to end or accessed at an arbitrary place in the middle. Because it is layed out as connected cells, each side by side, it can be easy to add an item to the end, but it is difficult to add items in the middle. (Think about how much physical effort it would take to add a car into the middle of a long train!)

In Ruby, the `Array` class actually plays more roles than just the traditional array data type. It also can act like a linked list, a stack, or a queue, among others. We'll take a look at the how the latter two data types can be simulated.

#### Making a stack with `push`/`pop`

A stack is a collection where the last element added to it will be the first element to be removed, a concept known as last-in, first-out, or LIFO. The usual example for thinking about this is a stack of food trays in a cafeteria: when a tray is placed on top of the stack, it will be the next tray to be picked up and used, unless another tray is put on top of it beforehand.

The operations for manipulating a stack are called `push` and `pop`, and Ruby `Array` objects implement them. We `push` elements onto the `Array` instance and we `pop` elements off of it. It looks like this:

```ruby
stack = []
stack.push "cat"
#=> ["cat"]
stack.push "bear"
#=> ["cat", "bear"]
stack.push "ant"
#=> ["cat", "bear", "ant"]
stack.pop
#=> "ant"
stack
#=> ["cat", "bear"]
stack.pop
#=> "bear"
stack
#=> ["cat"]
stack.pop
#=> "cat"
stack
#=> []
```

Stacks, among other handy uses, allow us to give priorty to things that have happened the most recently and can be useful for recursive operations.

#### Queueing it up with `shift`/`unshift`

A queue is pretty recognizable data structure because it shows up frequently in everyday life. While an American may say they're "standing in line" for a movie, a Briton would likely say they're "standing in queue" (or "queuing"). A queue is a first-in, first-out, or FIFO, structure.

Ruby `Array`s act as queues when we use the `pop` and `unshift` methods. We `unshift` elements onto the left side of the array and `pop` elements from the right. Alternatively, we could `push` elements onto the right side and `unshift` them from the left.

```ruby
queue = []
queue.unshift "cat"
#=> ["cat"]
queue.unshift "bear"
#=> ["bear", "cat"]
queue.unshift "ant"
#=> ["ant", "bear", "cat"]
queue.pop
#=> "cat"
queue
#=> ["ant", "bear"]
queue.pop
#=> "bear"
queue
#=> ["ant"]
queue.pop
#=> "ant"
queue
#=> []
```

With a queue, we can give priority to the oldest element.

Ruby does have an explicit `Queue` class, but it's built for sharing data between Ruby threads, not for the more general-purpose use cases here.

## Exercises

Given the following set of data:

```
[126, 516, 846, 491, 774, 824, 640, 913, 276, 309, 127, 175, 471, 274, 200, 56, 40, 533, 514, 451, 893, 723, 395, 
 217, 65, 158, 121, 573, 574, 91, 235, 17, 54, 889, 332, 404, 120, 178, 35, 162, 670, 837, 576, 645, 370, 203, 420, 
 400, 498, 270, 207, 648, 22, 524, 818, 821, 307, 588, 413, 52, 102, 352, 537, 634, 347, 42, 673, 116, 350, 884, 
 446, 108, 190, 764, 817, 608, 734, 79, 883, 584, 231, 50, 892, 353, 183, 660, 95, 945, 630, 58, 348, 812, 663, 865, 
 830, 791, 1000, 605, 756, 229, 583, 37, 874, 291, 686, 147, 948, 689, 125, 265, 96, 890, 64, 844, 195, 894, 579, 
 129, 257, 703, 20, 788, 443, 526, 606, 384, 698, 742, 34, 596, 357, 825, 852, 953, 354, 853, 531, 790, 432, 558, 
 656, 221, 293, 595, 754, 938, 885, 599, 399, 355]
```

Use collection operations to...

1. Find all the even numbers
2. Find the square of each number
3. Determine if there is a number evenly divisible by 31 (you'll need the modulo operator: http://www.ruby-forum.com/topic/181880)
4. Split the numbers into two sets: ones below 500 and ones above
5. Print them in ascending order with a place marker, like this:
```
1. 17
2. 20
3. 22
```
6. Find the sum of all numbers between 600 and 700
7. Create groups by hundreds (100s, 200s, 300s), where each set is sorted in increasing order
8. Find all numbers which have the digit 6
