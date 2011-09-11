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
person_path(@person.id)
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

One limitation is that the users cannot manipulate the URL in any meaningful way.

## Using a Non-ID Field

### Link Generation

### Object Lookup

## Using the FriendlyID Gem

### Setup

#### Dependency

#### In the Model

### Usage