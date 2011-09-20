# Modules

One of the most powerful tools in a Rubyist's toolbox is the module.

## Namespacing

Modules are used to namespace Ruby classes. For example, if we had this code:

```ruby
module Sample
  class Hello
  end
end
```

The class `Hello` would be wrapped in the `Sample` namespace. That means when we want to create an instance of `Hello` instead of:

```ruby
h = Hello.new
```

We would prefix it with the namespace and two colons:

```ruby
h = Sample::Hello.new
```

The primary purpose of namespacing classes is to avoid collision. If I write a library that has an `Asset` class, for instance, and you use my library in a program which already has an `Asset` class, the two class definitions will merge into one Frankenstein class, usually causing unexpected behavior.

If, instead, I wrap mine into a namespace `Packager`, then my `Packager::Asset` in the library and your `Asset` class can happily coexist.

### In Rails

Modules can be used to namespace a group of related Rails models:

```ruby
# In packager/asset.rb
module Packager
  class Asset < ActiveRecord::Base  
  end
end

# In packager/text.rb
module Packager
  class Text < ActiveRecord::Base
  end
end

# Used in a controller:
asset = Packager::Asset.new
text = Packager::Text.new
```

Typically the classes would be stored in a subfolder of models with the name of the namespace, so here `app/models/packager/*.rb`

## Common Code

The more common usage of modules in Rails is to share common code. These sometimes go by the nickname "mix-ins", but that just means modules. 

### Inheritance, Modules, and Rails

Ruby implements a single inheritance model, so a given class can only inherit from one other class. Sometimes, though, it'd be great to inherit from two classes. Modules can cover that need.

<div class="opinion">
  
In `ActiveRecord`, inheritance leads into "Single Table Inheritance" (STI). Most advanced Rails users agree that STI sounds like a good idea, then you  end up ripping it out as the project matures. It just isn't a strong design practice.

Instead, we mimic inheritance using modules and allow each model to have its own table.

</div>

### Instance Methods

Let's look at a scenario where two classes could share an instance method.

```ruby
class Book < ActiveRecord::Base
  has_many :pages
  def word_count
    pages.inject(0){|count, page| count + page.word_count}
  end
end

class Brochure < ActiveRecord::Base
  has_many :pages
  def word_count
    pages.inject(0){|count, page| count + page.word_count}
  end
end
```

The `word_count` method is obviously repeated verbatim. We could imagine that, in the future, we might want to modify the word count method so it doesn't include "a", "and", "or", etc. Or we want to pass in a word and have it tell us how many times that word appears in the document. 

These changes will mean changing the same code in two places, and that a recipe for regression bugs. Instead, we extract the common code.

#### Creating the Module

First, we define the module. It can live in `/app/models` or another subfolder if you prefer:

```ruby
# app/models/text_content.rb
module TextContent
  def word_count
    pages.inject(0){|count, page| count + page.word_count}
  end
end
```

Then make use of the module from the two classes:

```ruby
class Book < ActiveRecord::Base
  has_many :pages
  include TextContent
end

class Brochure < ActiveRecord::Base
  has_many :pages
  include TextContent
end
```

The `include` method is basically like copying and pasting the module into that spot of the class. Any methods in the module are added as instance methods to the class. Nothing about the usage of `book.word_count` would change.

### Class Methods

You can use modules to share class methods, too. Starting with similar models:

```ruby
class Book < ActiveRecord::Base
  #... other code
  def self.title_search(fragment)
    find_by_title("%?%", fragment)    
  end
end

class Brochure < ActiveRecord::Base
  #... other code
  def self.title_search(fragment)
    find_by_title("%?%", fragment)    
  end
end
```
[TODO: Verify the syntax of that SQL find]

Extract the common code into a module:

```ruby
module TextSearch
  def title_search(fragment)
    find_by_title("%?%", fragment)    
  end
end
```

Note that we've removed the `self.` from the method definition. Then mix it into the original classes using `extend`:

```ruby
class Book < ActiveRecord::Base
  #... other code
  extend TextSearch
end

class Brochure < ActiveRecord::Base
  #... other code
  extend TextSearch
end
```

Using `extend` adds the methods in the modules as _class methods_ to the extending class. So our functionality, like `Brochure.title_search('World')` would be the same.

### Included

Besides adding instance and class methods, sometimes you want some instructions to be run when your module is included. For instance, both of our sample classes have this line:

```ruby
has_many :pages
```

Though many developers don't think about what this DSL is doing, it's calling the class method `has_many`, defined in `ActiveRecord::Base`, and passing an argument of `:pages`.

If we put that line in a module and `include` the module we won't get the desired output because it'll be trying to define an instance method. If we use `extend` it still won't work because we'd be defining a class methods rather than calling it.

What we need is the `.included` callback method, typically written like this:

```ruby
module HasPages
  def self.included(base)
    # Code to run when this module is included
    # base is a reference to the including class
  end
end
```

The tricky part here is that the `included` method runs in the context of the module, not in the context of the containing class. So this will *not work*:

```ruby
module HasPages
  def self.included(base)
    base.has_many :pages
  end
end
```

It will fail because `has_many` is a private method on `ActiveRecord::Base`. Since the method is running outside the class it cannot access the private method.

But, in Ruby, everything is possible. If you want an object to run a private method you can use `.send` and pass the name of the method to run like this:

```ruby
object.send(:method)
```

That will run the `.method` inside the context of the class, so it works with public, private, or protected methods. You can pass parameters to the method by adding them to the send call:

```ruby
object.send(:method, param1, param2)
```

Getting back to our example, we want to call the method `has_many` and pass it the parameter `:pages`:

```ruby
module HasPages
  def self.included(base)
    base.send(:has_many, :pages)
  end
end
```

Now, when this module is included, the `has_many` class method will be successfully called with the parameter `:pages`. 

### Bringing It All Together

So how does this mimic inheritance? We can bring all three techniques together to share instance methods, class methods, and method calls or relationships.

Starting with this code:

```ruby
class Book < ActiveRecord::Base
  has_many :pages
  def word_count
    pages.inject(0){|count, page| count + page.word_count}
  end
  def self.title_search(fragment)
    find_by_title("%?%", fragment)    
  end
end

class Brochure < ActiveRecord::Base
  has_many :pages
  def word_count
    pages.inject(0){|count, page| count + page.word_count}
  end
  def self.title_search(fragment)
    find_by_title("%?%", fragment)    
  end
end
```

We can write a module like this:

```ruby
module TextContent
  def word_count
    pages.inject(0){|count, page| count + page.word_count}
  end

  def self.title_search(fragment)
    find_by_title("%?%", fragment)    
  end

  def self.included(base)
    base.send(:has_many, :pages)
  end
end
```

Then our models become:

```ruby
class Book < ActiveRecord::Base
  include TextContent
end

class Brochure < ActiveRecord::Base
  include TextContent
end
```

### Style Points

Inside the module there is a common pattern for organizing methods to group them as instance or class methods. It looks like this:

```ruby
module ModuleName
  module InstanceMethods
    def my_instance_method
    end
  end
  module ClassMethods
    def my_class_method
    end
  end
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.send(:extend, ClassMethods)
  end
end
```

Now we trigger `include` on the including class to add the `InstanceMethods` nested module and use `extend` to add the `ClassMethods` module as class methods. In this usage, there's nothing special about the names `InstanceMethods` and `ClassMethods`, they're just conventional.

We'd rewrite our module like this to follow the pattern:

```ruby
module TextContent
  module InstanceMethods
    def word_count
      pages.inject(0){|count, page| count + page.word_count}
    end
  end

  module ClassMethods
    def title_search(fragment)
      find_by_title("%?%", fragment)    
    end
  end

  def self.included(base)
    base.send(:include, InstanceMethods)
    base.send(:extend, ClassMethods)
    base.send(:has_many, :pages)
  end
end
```

The usage of the module would not change:

```ruby
class Book < ActiveRecord::Base
  include TextContent
end
```

## `ActiveSupport::Concern`

Rails 3 introduced a module named `ActiveSupport::Concern` which has the goal of simplifying the syntax of our modules.

To demonstrate it's usage, let's refactor the `TextContent` module above.

### Setup

First, just inside the module opening, we `extend` the helper:

```ruby
module TextContent
  extend ActiveSupport::Concern
  #...
end
```

Now `ActiveSupport::Concern` is activated.

### `included`

In the original, we define the method callback `self.included(base)`. With `ActiveSupport::Concern`, instead we call a class method on the module itself named `included`:

```ruby
module TextContent
  extend ActiveSupport::Concern
  included(base) do
    base.send(:include, InstanceMethods)
    base.send(:extend, ClassMethods)
    base.send(:has_many, :pages)    
  end
  #...
end
```

### Interior Modules

The original `TextContent` follows a very common pattern of using a nested module named `InstanceMethods` to contain the instance methods and `ClassMethods` to hold the class methods.

`ActiveSupport::Concern` is built to support this structure. Specifically, we can omit the calls to `extend` and `include` within `included` -- they'll be triggered automatically:

```ruby
module TextContent
  extend ActiveSupport::Concern
  included(base) do
    base.send(:has_many, :pages)    
  end
  #...
end
```

### Completed Refactoring

So, in the end, we have:

```ruby
module TextContent
  extend ActiveSupport::Concern
  
  module InstanceMethods
    def word_count
      pages.inject(0){|count, page| count + page.word_count}
    end
  end

  module ClassMethods
    def title_search(fragment)
      find_by_title("%?%", fragment)    
    end
  end

  included(base) do
    base.send(:has_many, :pages)
  end
end
```

`ActiveSupport::Concern` allowed us to save a few lines of "boilerplate" code in the module.

## Exercises

[TODO: Setup JSBlogger]

1. Define the `TextContent` module as described above.
2. Include the module into both `Comment` and `Article` models.
3. Display the `word_count` in the `articles#show` view template.
4. Define a second module named `Commentable` that, for starters, just causes the including class to run `has_many :comments`. Remove the `has_many` from `Article` and, instead, include the module.
5. Define an instance method in the `Commentable` module named `has_comments?` which returns true or false based on the existence of comments. In the `articles#show` view, use that method to show or hide the comments display based on their existence.