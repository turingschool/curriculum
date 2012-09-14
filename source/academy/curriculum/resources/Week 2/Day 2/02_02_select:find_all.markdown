---
layout: page
title: select/find_all
---

## `select`/`find_all`

These synonym methods will return an array of elements for which the block is true. It'll still be an array even if only one element was found.

```ruby
%w{ant bear cat bird}.select {|word| word.length == 4}
#=> ["bear", "bird"]
```