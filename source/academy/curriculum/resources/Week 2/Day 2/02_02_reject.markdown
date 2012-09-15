---
layout: page
title: "`reject`"
---

## `reject`

The opposite of `select`, find the elements for which the block is false:

```ruby
%w{ant bear cat bird}.reject{|word| word.include?("a")}
# => ["bird"] 
```

This is often used with the alternate form `reject!` to remove the elements for which the block is true:

```ruby
words = %w{ant bear cat bird}
# => ["ant", "bear", "cat", "bird"] 
words.reject!{|word| word.include?("a")}
# => ["bird"] 
words
# => ["bird"] 
```