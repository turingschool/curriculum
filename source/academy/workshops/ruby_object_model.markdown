---
layout: page
title: Ruby Object Model
---

To understand how Ruby works you need to understand the object model.

## Key Points

* Inheritance
* Ancestors
* Local variables and constants
* Classes are stored in constants
* Classes are instances of the Class class
* `BasicObject`, `Kernel`, and `Object`
* Instances of a class
* Calling instance methods
* Method lookup chain
* Overriding instance methods
* Class methods
* Inserting modules
* Monkey Patching
* Refinements

## Snippets

```ruby
class Greeter
  def hello
    puts "Hello, World!"
  end
end
```

```ruby
Greeter2 = Class.new do
  def hello
    puts "Hello, Second World!"
  end
end
```

## References

* http://www.hokstad.com/ruby-object-model
* [Metaprogramming Ruby](http://www.amazon.com/Metaprogramming-Ruby-Program-Like-Pros/dp/1941222129/ref=sr_1_2?ie=UTF8&qid=1402519944&sr=8-2&keywords=metaprogramming+ruby)
* http://viewsourcecode.org/why/hacking/seeingMetaclassesClearly.html
