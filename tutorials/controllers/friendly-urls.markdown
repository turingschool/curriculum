# Friendly URLs

By default, Rails applications build URLs based on the primary key -- the `id` column from the database. Imagine we have a `Person` model and associated controller. We have a person record for `Bob Martin` that has `id` number `6`. The URL for his show page would be:

```
/people/6
```

But, for aesthetic or SEO purposes, we want Bob's name in the URL. The last segment, the `6` here, is called the "slug". Let's look at a few ways to implement better slugs.

## Simple Approach

The simplest approach is to override the `to_param` method in the `Person` model. Whenever we call a route helper like this:

```
person_path(@person)
```

Rails will call `to_param` to convert the object to a slug for the URL. If your model does not define this method then it will use the implementation in `ActiveRecord::Base` which just returns the `id`.

For this method to succeed, it's critical that all links use the `ActiveRecord` object rather than calling `id`. *Don't ever do this*:

```
person_path(@person.id) # Bad!
```

Instead, always pass the object:

```
person_path(@person)
```

### Slug Generation

Instead, in the model, we can override `to_param` to include a parameterized version of the person's name:

```ruby
class Person < ActiveRecord::Base
  def to_param
    [id, name.parameterize].join("-")
  end
end
```

For our user `Bob Martin` with `id` number `6`, this will generate a slug `6-bob_martin`. The full URL would be:

```
/people/6-bob-martin
```

The `parameterize` method from `ActiveSupport` will deal with converting any characters that aren't valid for a URL.

### Object Lookup

What do we need to change about our finders? Nothing! When we call `Person.find(x)`, the parameter `x` is converted to an integer to perform the SQL lookup. Check out how `to_i` deals with strings which have a mix of letters and numbers:

```irb
> "1".to_i
# => 1 
> "1-with-words".to_i
# => 1 
> "1-2345".to_i
# => 1 
> "6-bob-martin".to_i
# => 6 
```

The `to_i` method will stop interpreting the string as soon as it hits a non-digit. Since our implementation of `to_param` always has the `id` at the front followed by a hyphen, it will always do lookups based on just the `id` and discard the rest of the slug.

### Benefits / Limitations

We've added content to the slug which will improve SEO and make our URLs more readable.

One limitation is that the users cannot manipulate the URL in any meaningful way. Knowing the url `6-bob-martin` doesn't allow you to guess the url `7-russ-olsen`, you still need to know the ID.

And the numeric ID is still in the URL. If this is something you want to obfuscate, then the simple scheme doesn't help.

## Using a Non-ID Field

Sometimes you want to get away from the ID all together and use another attribute in the database for lookup. Imagine we have a `Tag` object that has a `name` column. The name would be something like `ruby` or `rails`.

### Link Generation

Creating links can again override `to_param`:

```ruby
class Tag < ActiveRecord::Base
  validates_uniqueness_of :name
  
  def to_param
    name
  end
end
```

Now when we call `tag_path(@tag)` we'd get a URL like `/tags/ruby`.

### Object Lookup

The lookup is harder, though. When a request comes in to `/tags/ruby` the `ruby` will be stored in `params[:id]`. A typical controller will call `Tag.find(params[:id])`, essentially `Tag.find("ruby")`, and it will fail.

#### Option 1: Query Name from Controller

Instead, we can modify the controller to `Tag.find_by_name(params[:id])`. It will *work*, but it's bad object-oriented design. We're breaking the encapsulation of the `Tag` class. 

The *DRY Principle* says that a piece of knowledge should have a single representation in a system. In this implementation of tags, the idea of "A tag can be found by its name" has now been represented in the `to_param` of the model *and* the controller lookup. That's a maintenance headache.

#### Option 2: Custom Finder

In our model we could define a custom finder:

```ruby
class Tag < ActiveRecord::Base
  validates_uniqueness_of :name
  
  def to_param
    name
  end
  
  def self.find_by_param(input)
    find_by_name(input)
  end
end
```

Then in the controller call `Tag.find_by_param(params[:id])`. This layer of abstraction means that only the model knows exactly how a `Tag` is converted to and from a parameter. The encapsulation is restored.

But we have to remember to use `Tag.find_by_param` instead of `Tag.find` everywhere. Especially if you're retrofitting the friendly ID onto an existing system, this can be a significant effort.

#### Option 3: Overriding Find

Instead of implementing the custom finder, we could override the `find` method:

```ruby
class Tag < ActiveRecord::Base
  #...
  def self.find(input)
    find_by_name(input)
  end
end
```

It will work when you pass in a name slug, but will break when a numeric ID is passed in. How could we handle both?

The first temptation is to do some type switching:

```ruby
class Tag < ActiveRecord::Base
  #...
  def self.find(input)
    if input.is_a?(Integer)
      super
    else
      find_by_name(input)
    end
  end
end
```

That'll work, but checking type is very against the Ruby ethos. Writing `is_a?` should always make you ask "Is there a better way?"

Yes, based on these facts:

* Databases give the `id` of `1` to the first record
* Ruby converts strings starting with a letter to `0`

```ruby
class Tag < ActiveRecord::Base
  #...
  def self.find(input)
    if input.to_i != 0
      super
    else
      find_by_name(input)
    end
  end
end
```

Or, condensed down with a ternary:

```ruby
class Tag < ActiveRecord::Base
  #...
  def self.find(input)
    input.to_i == 0 ? find_by_name(input) : super
  end
end
```

Our goal is achieved, but we've introduced a possible bug: if a name starts with a digit it will look like an ID. If it's acceptable to our business domain, we can add a validation that names cannot start with a digit:

```ruby
class Tag < ActiveRecord::Base
  #...
  validates_format_of :name, :without => /^\d/
  def self.find(input)
    input.to_i == 0 ? find_by_name(input) : super
  end
end
```

Now everything should work great!

## Using the FriendlyID Gem

Does implementing two additional methods seem like a pain? Or, more seriously, are you going to implement this kind of functionality in multiple models of your application? Then it might be worth checking out the FriendlyID gem: https://github.com/norman/friendly_id

### Setup

The gem is just about to hit a 4.0 version. As of this writing, you want to use the beta. In your `Gemfile`:

```
gem "friendly_id", "~> 4.0.0.beta8"
```

Then run `bundle` from the command line.

#### Simple Usage

The minimum configuration in your model is:

```ruby
class Tag < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name
end
```

This will allow you to use the `name` column or the `id` for lookups using `find`, just like we did before.
 
#### Dedicated Slug

But the library does a great job of maintaining a dedicated slug column for you. If we were dealing with articles, for instance, we don't want to generate the slug over and over. More importantly, we'll want to store the slug in the database to be queried directly.

The library defaults to a `String` column named `slug`. If you have that column, you can use the `:slugged` option to automatically generate and store the slug:

```ruby
class Tag < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, :use => :slugged
end
```

### Usage

You can see it in action here:

```irb
> t = Tag.create(:name => "Ruby on Rails")
# => #<Tag id: 16, name: "Ruby on Rails", created_at: "2011-09-11 15:42:53", updated_at: "2011-09-11 15:42:53", slug: "ruby-on-rails"> 
> Tag.find 16
# => #<Tag id: 16, name: "Ruby on Rails", created_at: "2011-09-11 15:42:53", updated_at: "2011-09-11 15:42:53", slug: "ruby-on-rails"> 
> Tag.find "ruby-on-rails"
# => #<Tag id: 16, name: "Ruby on Rails", created_at: "2011-09-11 15:42:53", updated_at: "2011-09-11 15:42:53", slug: "ruby-on-rails"> 
> t.to_param
# => "ruby-on-rails" 
```

We can use `.find` with an ID or the slug transparently. When the object is converted to a parameter for links, we'll get the slug with no ID number. We get good encapsulation, easy usage, improved SEO and easy to read URLs.