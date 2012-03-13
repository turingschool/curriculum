---
layout: page
title: Focus on Collections
section: Tuesday 3/13/12 Class Sessions
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

#### `find` / `detect`

#### `select` / `find_all`

#### `grep`

#### `group_by`

#### `include?`

#### `inject`

#### `max` / `min`

#### `max_by` / `min_by`

#### `partition`

#### `reject`

#### `sort` / `sort_by`



