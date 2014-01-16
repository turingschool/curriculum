---
layout: page
title: Modules
section: Models
---

One of the most powerful tools in a Rubyist's toolbox is the module.

### Setup

{% include custom/sample_project_advanced.html %}

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
<p>In <code>ActiveRecord</code>, inheritance leads into <em>Single Table Inheritance</em> (STI). STI sounds like a good idea, then you end up ripping it out as the project matures. It just isn't a strong design practice.</p>

<p>Instead, we can mimic inheritance using modules and allow each model to have its own table.</p>
</div>

### Instance Methods

Let's look at a scenario where two classes could share an instance method. You'll find these methods implemented in the sample project's models:

```ruby
class Article < ActiveRecord::Base
  #...
  def word_count
    body.split.count
  end
end

class Comment < ActiveRecord::Base
  #...
  def word_count
    body.split.count
  end
end
```

The `word_count` method is obviously repeated verbatim. We could imagine that, in the future, we might want to modify the word count method so it doesn't include "a", "and", "or", etc. Or we want to pass in a word and have it tell us how many times that word appears in the document.

These changes will mean changing the same code in two places, and that's a recipe for regression bugs. Instead, we extract the common code.

#### Creating the Module

First, we define the module. It can live in `/app/models` or another subfolder if you prefer:

```ruby
# app/models/text_content.rb
module TextContent
  def word_count
    body.split.count
  end
end
```

Then make use of the module from the two classes:

```ruby
class Article < ActiveRecord::Base
  include TextContent
end

class Comment < ActiveRecord::Base
  include TextContent
end
```

The `include` method adds any methods in the module as _instance methods_ to the class. Nothing about the usage of `article.word_count` would change.

### Class Methods

You can use modules to share class methods, too. Starting with similar models:

```ruby
class Article < ActiveRecord::Base
  #...
  def self.total_word_count
    all.inject(0) {|total, a| total += a.word_count }
  end
end

class Comment < ActiveRecord::Base
  #...
  def self.total_word_count
    all.inject(0) {|total, a| total += a.word_count }
  end
end
```

We want to extract the common code into a module, but it has to add a *class* method, not an *instance* method like the module we wrote before. There are two approaches.

#### Using a Dedicated Module

```ruby
module WordCounter
  def total_word_count
    all.inject(0) {|total, a| total += a.word_count }
  end
end
```

Note that we've removed the `self.` from the method definition. Then mix it into the original classes using `extend`:

```ruby
class Article < ActiveRecord::Base
  #...
  extend WordCounter
end

class Comment < ActiveRecord::Base
  #...
  extend WordCounter
end
```

Previously we used `include` to add the module methods as *instance methods*. Here, we use `extend` to add the methods in the module as *class methods* to the extending class. Our functionality, like `Article.total_word_count` would be the same.

#### Sharing a Module

These two modules are really related to the same domain concept, so let's figure out how to implement the same functionality with just one module.

##### Class Methods in the Module

We'd be tempted to add it as a class method to the module:

```ruby
module TextContent
  def word_count
    body.split.count
  end

  def self.total_word_count
    all.inject(0) {|total, a| total += a.word_count }
  end
end
```

Then in the models...

```ruby
class Article < ActiveRecord::Base
  include TextContent
end

class Comment < ActiveRecord::Base
  include TextContent
end
```

But this *won't work*. The `self.total_word_count` is _defined on the module_, not on the including class. We need to do more in the module.

##### The `self.included` Method

Our module can define a `self.included` method which will be automatically triggered when the module is included into a class. It usually looks like this:

```ruby
module MyModule
  def self.included(including_class)

  end
end
```

The parameter `including_class` is a reference to the class which is including this module.

How does this help us? To define our class methods previously we used `extend`. With the `included` method, we have a reference to the including class so we can tell that class to `extend` our class methods.

But `extend` expects a module. We can wrap our class methods into a nested module like this:

```ruby
module TextContent
  def word_count
    body.split.count
  end

  module ClassMethods
    def total_word_count
      all.inject(0) {|total, a| total += a.word_count }
    end
  end
end
```

Then add in the `self.included` method which will tell the including class to `extend` itself with the `ClassMethods` module.

```ruby
module TextContent
  def word_count
    body.split.count
  end

  module ClassMethods
    def total_word_count
      all.inject(0) {|total, a| total += a.word_count }
    end
  end

  def self.included(including_class)
    including_class.extend ClassMethods
  end
end
```

Now, if you try this with the `Article` and `Comment`, you'll find that `word_count` is correctly added as an instance method while `total_word_count` is added as a class method -- all by just calling `include`.

### More on `self.included`

We can use `included` to share more than method definitions. Imagine that both `Article` and `Comment` share an association with one `ModeratorApproval`:

```ruby
class Article < ActiveRecord::Base
  include TextContent
  has_one :moderator_approval, as: :content
end

class Comment < ActiveRecord::Base
  include TextContent
  has_one :moderator_approval, as: :content
end
```

You decide that all objects in the system that implement `TextContent` will also have this relationship. You could then pull it into the module.

#### A First Attempt

Your first instinct might be to try this:

```ruby
module TextContent
  #...
  has_one :moderator_approval, as: :content
end
```

This won't work because it's trying to call a class method `has_one` on the module, but that method lives in `ActiveRecord`. We really want to call the method on the including class, not the module.

#### Using `self.included` and `.send`

We can modify our `self.included` like so:

```ruby
module TextContent
  #...

  def self.included(including_class)
    including_class.extend ClassMethods
    including_class.send(:has_one, :moderator_approval, {as: :content})
  end
end
```

<div class="note">
<p>Not familiar with <code>.send</code>? It allows us to trigger a private method inside another object. If we just called <code>including_class.extend</code> here, Ruby would complain. But <code>send</code> will work just fine.</p>
</div>

The `send` call is tricky to write, though. Whenever Ruby feels tricky, there must be another way.

#### Using `self.included` and `class_eval`

When `self.included` is making multiple calls or you're doing something more complex, flip over to using `.class_eval`:

```ruby
module TextContent
  #...

  def self.included(including_class)
    including_class.class_eval do
      extend ClassMethods
      has_one :moderator_approval, as: :content
    end
  end
end
```

Whatever you have inside the `class_eval` block will be executed as though it were typed right in the including class' source.

## `ActiveSupport::Concern`

Rails 3 introduced a module named `ActiveSupport::Concern` which has the goal of simplifying the syntax of our modules. Not everyone loves it, but you should at least understand how it works.

To demonstrate its usage, let's refactor the `TextContent` module above.

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

In the original, we define the method callback `self.included(including_class)`. With `ActiveSupport::Concern`, instead we call a class method on the module itself named `included`:

```ruby
module TextContent
  extend ActiveSupport::Concern
  included do
    extend ClassMethods
    has_one :moderator_approval, as: :content
  end
  #...
end
```

The block passed to `included` is executed as though it were in a `class_eval`.

### Interior Modules

If our module follows the pattern of defining class methods in an interior module named `ClassMethods`, `ActiveSupport::Concern` will automatically `extend` the including class with that module. So we can omit the call to `extend` in our `included` method:

```ruby
module TextContent
  extend ActiveSupport::Concern
  included do
    has_one :moderator_approval, as: :content
  end
  #...
end
```

Similarly, if you have an interior module named `InstanceMethods`, `included` will automatically call `include` on the including class and pass in that module.

### Completed Refactoring

So, in the end, we have:

```ruby
module TextContent
  extend ActiveSupport::Concern

  def word_count
    body.split.count
  end

  module ClassMethods
    def total_word_count
      all.inject(0) {|total, a| total += a.word_count }
    end
  end

  included do
    has_one :moderator_approval, as: :content
  end
end
```

Then, in the models:

```ruby
class Article < ActiveRecord::Base
  include TextContent
end

class Comment < ActiveRecord::Base
  include TextContent
end
```

`ActiveSupport::Concern` allowed us to save a few lines of "boilerplate" code in the module.

## Exercises

1. Define the `TextContent` module as described above.
2. Include the module into both `Comment` and `Article` models.
3. Pull the related tests out of `article_spec.rb` and `comment_spec.rb`, write a `text_content_spec.rb`, and relocate the tests. Now that you've ensured the functionality of the methods, from the `article_spec.rb` and `comment_spec.rb` you can just check that the class and instances respond to the proper methods.
4. Define a second module named `Commentable` that, for starters, just causes the including class to run `has_many :comments`. Remove the `has_many` from `Article` and, instead, include the module. Imagine that, in the future, we'd have a `Photo` object which also accepted comments.
5. Define an instance method in the `Commentable` module named `has_comments?` which returns true or false based on the existence of comments. In the `articles#show` view, use that method to show or hide the comments display based on their existence.
