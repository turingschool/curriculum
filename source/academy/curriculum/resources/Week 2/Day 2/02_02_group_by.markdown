---
layout: page
title: group_by
---

## `group_by`

This method will run a block for each element and return a `Hash` with the result as a key and an array containing all elements which generated that result as the value.

```ruby
%w{ant bear cat bird}.group_by{|word| word.length}
#=> {3=>["ant", "cat"], 4=>["bear", "bird"]}
```