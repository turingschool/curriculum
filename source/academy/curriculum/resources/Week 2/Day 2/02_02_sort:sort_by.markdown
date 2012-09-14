---
layout: page
title: `sort` / `sort_by`
---

## `sort` / `sort_by`

The simple `sort` will delegate responsibility to the "spaceship method", `<=>`, defined for the object. For `String` objects, spaceship sorts them into alphabetical order with all capital letters coming before any lowercase letters.

```ruby
%w{ant bear Cat bird}.sort
# => ["Cat", "ant", "bear", "bird"] 
```

Note how `"C"` comes first.

The `sort_by` method accepts a block to run on each element, then uses spaceship to sort the resulting values:

```ruby
%w{ant bear Cat bird}.sort_by{|word| word.length}
# => ["ant", "Cat", "bear", "bird"]
```

But within the similar lengths of 3 and 4, how do you determine the sorting order? A common technique is to have the block return an array with multiple criteria for sorting:

```ruby
%w{ant bear Cat bird}.sort_by{|word| [word.length, word]}
# => ["Cat", "ant", "bear", "bird"]
```

Now it sorts by length first, then by alphabetical order within a common length.
