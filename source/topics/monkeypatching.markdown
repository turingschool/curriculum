---
layout: page
title: Monkeypatching Ruby
---

## Monkeypatching

In Ruby, all classes can be modified at runtime, a technique commonly known as "Monkeypatching".

### Example:

```
> "hello".leet_speak
# NoMethodError: undefined method `leet_speak' for "hello":String
> class String
>   def leet_speak
>     self.gsub("e","3").gsub("l", "!")
>     end
>   end
# => nil
> "hello".leet_speak
# => "h3!!o"
```

We reopen the class just the same as defining a new one. If you define a new method it will be added to all new and existing instances of the class. Redefining a method will overwrite that method for all instances.

### Practical Application

In general, don't do it.

It is the right technique when you're using a library, particularly a third party library, that has a bug or insufficient flexibility to fit your application. The monkeypatch should be a temporary fix, like a piece of duct tape, while a real patch is being developed.

If you're really sure it should stick around, then you should at least write it into a module or "mix-in".

## Modules & Mix-ins

Ruby classes can only inherit from one parent, but they can mix in multiple modules. As such, modules are a powerful way to modularize and reuse chunks of your code across objects.

### Example

We can write a module like this:

```ruby
module Leet
  def leet_speak
  self.gsub("e","3").gsub("l", "!")
  end
end
```

Then utilize that from a class:

```ruby
class LeetString < String
  include Leet
end
```

Then use it:

```ruby
sample = LeetString.new("Hello, World")
# => "Hello, World"
sample.leet_speak
# => "H3!!o, Wor!d"
```

### Notes

By using `include`, any methods in the module were added as instance methods. If we used `extend` they would be added as class methods.

### Extension

But what if you want to write both instance and class methods in a module? There is a common pattern that accomodates that usage:

```ruby
module LeetSpeak
  module ClassMethods
    def leet?(input)
      input.include?("!")
    end
  end

  module InstanceMethods
    def leet_speak
	  self.gsub("e","3").gsub("l", "!")
	end
  end

  def self.included(base)
    base.send :include, InstanceMethods
    base.send :extend, ClassMethods
  end
end
```

We define two submodules, one for instance methods and one for class methods. When the outer module is included into a class the `self.included` method is triggered and the including class is passed in as `base`.

The `.included` method then forces the including class to `include` the module named `InstanceMethods`, adding them as instance methods like a normal `include`. It then forces `base` to `extend` the `ClassMethods` module, creating class methods.

Using the module is the same as before:

```ruby
class LeetString < String
  include LeetSpeak
end
```

Then exercising both the instance and class methods:

```irb
> sample = LeetString.new("Hello, World")
# => "Hello, World"
> sample.leet_speak
# => "H3!!o, Wor!d"
> LeetString.leet?("0wn3d!")
# => true
```

And that's about it!