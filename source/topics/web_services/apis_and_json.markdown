---
layout: page
title: APIs and JSON
section: Web Services
---

## What is an API?

* Technical: http://en.wikipedia.org/wiki/Application_programming_interface
* We use "API" in two contexts:
  * Libraries/Classes
  * External Services
* Communication Patterns
  * Client/Server protocol
* Communication Language
  * Plain text?
  * XML
  * JSON

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

### Working in Ruby

JSON is a great format with parsers and generators written in just about every language. In Ruby, there are several different libraries for parsing JSON, but the cannonical one is the `json` gem. Check out its documentation at http://flori.github.com/json/

### JSON to Ruby

A JSON parser takes JSON-formatted strings as input, then outputs native Ruby objects. 

Try these experiments in IRB:

```irb
require 'json'
JSON.parse('{"first":"Hello","second":"World"}')
JSON.parse({"first" => "Hello", "second" => "World"}.to_json)
JSON.parse('{"third":[4,5],"fourth":true}')
"Hello, World".to_json
require 'date'; Date.today.to_json
{"hello" => "world"}.to_json
```

### Ruby to JSON

Converting Ruby objects to JSON is easy, too:

```irb
require 'json'
content = {:outer => {:inner => "content", :inner2 => "content2"}, :outer2 => true}
output = content.to_json
content == JSON.parse(output)
puts output
```

One of the powers of JSON is that, like Ruby's hashes, you can nest JSON within JSON to any depth.