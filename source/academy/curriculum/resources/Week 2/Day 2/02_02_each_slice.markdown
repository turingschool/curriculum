---
layout: page
title: each_slice
---

## `each_slice`

Slice the collection into smaller collections, then iterate through each of those:

```ruby
%w{ant bear cat dog bird fish}.each_slice(2) {|animals| puts animals.join}
#=> antbear
#=> catdog
#=> birdfish
```