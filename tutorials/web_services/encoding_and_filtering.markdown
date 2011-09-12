# Encoding and Filtering Data

You're building an API and are rolling with `respond_to` and `respond_with`. They're automatically rendering your objects as XML and JSON.

Wait...they're automatically rendering your objects? Everything? Yep. If you're models have any sensitive data in them, and they probably do, you'll need to do some filtering.

## `to_xml` and `to_json` in the Model

Your easiest option is to override `to_xml` and `to_json` in the model. This works in scenarios where you have attributes that should *always* be hidden.

Let's look at an `Article` object, for example:

```irb
> a = Article.last
# => #<Article id: 15, title: "asdfasdf", body: "asdf", created_at: "2011-09-11 16:46:52", updated_at: "2011-09-12 20:34:42", author_name: "Stan", editor_id: 5> 
> puts a.to_json
{"article":{"author_name":"Stan","body":"asdf","created_at":"2011-09-11T16:46:52Z","editor_id":5,"id":15,"title":"asdfasdf","updated_at":"2011-09-12T20:34:42Z"}}
# => nil 
```

See that `editor_id` attribute? That's sensitive information. We don't want to expose it to our JSON api.

### Overriding `to_json` / `to_xml`

We open the `article.rb` model and add this method:

```ruby
def to_json
  super(:except => :editor_id)
end
```

That relies on the `ActiveRecord::Base` implementation of `to_json` which accepts an `:except` blacklist of attributes. It can also accept an array of keys:

```ruby
def to_json
  super(:except => [:editor_id, :updated_at])
end
```

All of the listed keys will be removed. The exact same syntax can be used for `to_xml`

#### Using a Whitelist

Using a whitelist is more secure but takes more maintenance. Create a `to_json` method that uses the `:only` parameter:

```ruby
def to_json
  super(:only => [:title, :body, :created_at])
end
```

And, again, you can use the same syntax for `to_xml`.

#### Reducing Redundancy

Using either approach you shouldn't list the visible/invisible attributes in *both* `to_xml` and `to_json`.

Option one is to define a constant and reference it twice:

```ruby
WHITELIST_ATTRIBUTES = [:title, :body, :created_at]

def to_json
  super(:only => WHITELIST_ATTRIBUTES)
end

def to_xml
  super(:only => WHITELIST_ATTRIBUTES)
end
```

Or, use a bit of metaprogramming:

```ruby
WHITELIST_ATTRIBUTES = [:title, :body, :created_at]

[:to_json, :to_xml].each do |name|
  define_method(name){ super(:only => WHITELIST_ATTRIBUTES) }
end
```

This works great as long as you want to filter the API *globally*.

## Checking Authorization

More often, though, you want to filter based on authorization rules. For instance, if the current user is an administrator, show them everything. If they are just a regular user, show them the filtered list. This is much harder.

You're working with data, which means the logic belongs in the model. But you're dealing with authorization, which really belongs in the controller. And, at the core, you're dealing with presentation which goes in the view. Ahh!

### Passing Authorization to the Model



### Using a Decorator

## References

