---
layout: page
title: `max_by` / `min_by`
---

## `max_by` / `min_by`

Similarly, these are like shortcuts for using `sort_by`:

```ruby
%w{ant bear cat bird}.max_by{|word| word.chars.max}
# => "ant" 
%w{ant bear cat bird}.min_by{|word| word.chars.min}
# => "ant"
```
With `max_by`, here, we get `"ant"` because it has the "maximum" letter of all the words, `"t"`.

With `min_by`, we get `"ant"` because it has the "minimum" letter of all the words, `"a"`.