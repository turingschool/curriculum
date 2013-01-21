---
layout: page
title: Moving to Ruby 1.9
---

Ruby 1.8 is antiquated and all projects/libraries should move to Ruby 1.9. Below are a few small features you can take advantage of:

## Hash Syntax

The most well known change in Ruby 1.9 is the addition of a new, simplified, JavaScript-inspired hash syntax:

The traditional (and still perfectly good) syntax:

```ruby
{ :a => 'apple', :b => 'banana' }
```

When you're using 1.9 and the keys are symbols, you can write it like this:

```ruby
{ a: 'apple', b: 'banana' }
```

Nice! But the clarity breaks down when the data elements are also symbols:

```ruby
{ a: :apple, b: :banana }
```

It works fine...but it's ugly.

## Regular Expressions with Named Captures

Regular expressions too regular for you? How about some more symbols to achieve named captures!

```ruby
> match_set = "10:56:01".match(/(?<hour>\d\d):(?<min>\d\d):(?<sec>\d\d)/)
# => #<MatchData "10:56:01" hour:"10" min:"56" sec:"01">
> match_set[:hour]
# => "10"
> match_set.captures[0]
# => "10"
```

Inside the opening `(` of a capture add `?<name>` with a name of your choice. Access the results in the `MatchData` with a hash/symbol lookup.

## Collections

The already rich `Enumerable` class got several new methods. Here are some highlights.

### .shuffle

Randomize the elements:

```irb
[1,2,3,4,5].shuffle
# => [3, 5, 4, 1, 2]
```

### .permutation(size)

Compute the permutations of the source collection into sets of `size`:

```irb
> [1,2,3,4,5].permutation(2)
# => #<Enumerator: [1, 2, 3, 4, 5]:permutation(2)>
> [1,2,3,4,5].permutation(2).to_a
# => [[1, 2], [1, 3], [1, 4], [1, 5], [2, 1], [2, 3], [2, 4], [2, 5], [3, 1], [3, 2], [3, 4], [3, 5], [4, 1], [4, 2], [4, 3], [4, 5], [5, 1], [5, 2], [5, 3], [5, 4]]
```

### .each_slice(size)

Cut the collection into slices of `size`, pass a block to iterate over the slices:

```irb
> [1,2,3,4,5].each_slice(2){ |data| puts data.inspect }
[1, 2]
[3, 4]
[5]
# => nil
```

### .rotate(quantity)

Unshift elements from the left and append them to the right. Defaults to one, but you can pass a number of elements to move:

```irb
> [1,2,3,4,5].rotate
# => [2, 3, 4, 5, 1]
> [1,2,3,4,5].rotate(2)
# => [3, 4, 5, 1, 2]
```

## UTF-8

* Files are assumed to be 7-bit ASCII
* You can specify the encoding of a file by starting it with:

```ruby
# encoding: utf-8
```

### Example:

Try running this code in IRB, from a file with the encoding line, and from a file with the encoding line removed.

```
# encoding: utf-8
str = "∂og"
puts str.length
puts str[0]
puts str.reverse
```

### References

* http://rbjl.net/27-new-array-and-enumerable-methods-in-ruby-1-9-2-keep_if-chunk
* http://pragprog.com/magazines/2010-12/whats-new-in-ruby-
* http://www.strictlyuntyped.com/2010/12/new-ruby-19-hash-syntax.html
* http://ruby.runpaint.org/regexps
