---
layout: page
title: `detect` / `find`
---

## `detect` / `find`

These synonym methods will return the first result for which the block is true.

```ruby
%w{ant bear cat}.find {|word| word.length == 3}
#=> "ant"
```