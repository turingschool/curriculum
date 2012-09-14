---
layout: page
title: `inject` / `reduce`
---

## `inject` / `reduce`

```ruby
%w{ant bear cat bird}.inject(0){|sum, word| sum + word.length}
#=> 14
```

This effectively says "Start with the value `0`, put that in a variable `sum`, go through the collection and for each element add the length of the element to `sum`, returning `sum`".
