---
layout: page
title: Getting Started with JSON
---

## Getting Started with JSON

JSON has...

* Curly Brackets
* Colons
* String labels
* Typed Data: 
  * String
  * Number
  * Array
  * Boolean

#### In Ruby

* [http://flori.github.com/json/](http://flori.github.com/json/)


Experiments:

```
JSON.parse('{"first":"Hello","second":"World"}')
JSON.parse({"first" => "Hello", "second" => "World"}.to_json)
JSON.parse('{"third":[4,5],"fourth":true}')
"Hello, World".to_json
require 'date'; Date.today.to_json
{"hello" => "world"}.to_json
```

Observe the data types in this example:

```
content = {:outer => {:inner => "content", :inner2 => "content2"}, :outer2 => true}
output = content.to_json
content == JSON.parse(output)
```

Interesting?
