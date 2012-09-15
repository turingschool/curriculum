---
layout: page
title: "`partition`"
---

## `partition`

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

