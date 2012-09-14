---
layout: page
title: "`each_with_index`"
---

## `each_with_index`

Uses two local block parameters to iterate through the collection but also use the element's position in the origininal collection:

```ruby
%w{ant bear cat}.each_with_index {|word, i| puts [i, word].join(". ")}
#=> 0. ant
#=> 1. bear
#=> 2. cat
```