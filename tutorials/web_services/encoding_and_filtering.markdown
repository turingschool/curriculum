# Encoding and Filtering Data

You are building an API and are rolling with `respond_to` and `respond_with`. They are automatically rendering your objects as XML and JSON.

Wait, they are automatically rendering your objects? Everything? Yes! If your models have any sensitive data in them, and they probably do, you'll need to do some filtering.

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

In this case, the `editor_id` attribute is sensitive information. We do not want to expose it to our JSON api.

### Overriding `to_json` / `to_xml`

We open the `article.rb` model and add this method:

```ruby
def to_json
  super(:except => :editor_id)
end
```

This method relies on the `ActiveRecord::Base` implementation of `to_json` which accepts an `:except` blacklist of attributes. It can also accept an array of keys:

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

Using either approach you should not list the visible/invisible attributes in *both* `to_xml` and `to_json`.

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

Option two is to use a bit of metaprogramming:

```ruby
WHITELIST_ATTRIBUTES = [:title, :body, :created_at]

[:to_json, :to_xml].each do |name|
  define_method(name){ super(:only => WHITELIST_ATTRIBUTES) }
end
```

This works well as long as you want to filter the API *globally*.

## Checking Authorization

More often you want to filter based on authorization rules. For instance, if the current user is an administrator then show them everything. If the current user is just a regular user then show them the filtered list. This is much harder.

You are working with data, which means the logic belongs in the model. But you're dealing with authorization, which really belongs in the controller. And, at the core, you're dealing with presentation which goes in the view. It's tricky!

### Using a Decorator

## References

