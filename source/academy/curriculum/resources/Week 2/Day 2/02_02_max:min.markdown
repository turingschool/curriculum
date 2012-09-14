---
layout: page
title: `max` / `min`
---

## `max` / `min`

These methods are basically shortcuts. `max` is equivalent to `.sort.last` while `min` is equivalent to `.sort.first`

```ruby
%w{ant bear cat bird}.max
#=> "cat" 
%w{ant bear cat bird}.min
#=> "ant" 
```