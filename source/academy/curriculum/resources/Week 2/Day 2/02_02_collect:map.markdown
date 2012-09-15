---
layout: page
title: "`collect` / `map`"
---

## `collect` / `map`

One of the very most common, these synonym methods go through each element of the collection, run the block, gather the return value, then return a collection of those values.

```ruby
%w{ant bear cat}.collect {|word| word.length}   #=> [3, 4, 3]
```
