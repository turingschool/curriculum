---
layout: page
title: Encoding and Filtering Data
section: Web Services
---

You are building an API and are rolling with `respond_to` and `respond_with`. They are automatically rendering your objects as XML and JSON.

Wait, they are automatically rendering your objects? **Everything**? Yes! If your models have any sensitive data in them, and they probably do, you'll need to do some filtering.

## `as_xml` and `as_json` in the Model

Your easiest option is to override `as_xml` and `as_json` in the model. This works in scenarios where you have attributes that should *always* be hidden.

Let's look at an `Article` object, for example:

```irb
> a = Article.last
# => #<Article id: 15, title: "asdfasdf", body: "asdf", created_at: "2011-09-11 16:46:52", updated_at: "2011-09-12 20:34:42", author_name: "Stan", editor_id: 5> 
> puts a.as_json
{"article":{"author_name":"Stan","body":"asdf","created_at":"2011-09-11T16:46:52Z","editor_id":5,"id":15,"title":"asdfasdf","updated_at":"2011-09-12T20:34:42Z"}}
# => nil 
```

In this case, the `editor_id` attribute is sensitive information. We do not want to expose it to our JSON api.

### Overriding `as_json` / `as_xml`

We open the `article.rb` model and add this method:

```ruby
def as_json(*args)
  super(except: :editor_id)
end
```

This method relies on the `ActiveRecord::Base` implementation of `as_json` which accepts an `:except` blacklist of attributes. It can also accept an array of keys:

```ruby
def as_json(*args)
  super(except: [:editor_id, :updated_at])
end
```

All of the listed keys will be removed. The exact same syntax can be used for `as_xml`

#### Using a Whitelist

Using a whitelist is more secure but takes more maintenance. Create a `as_json` method that uses the `:only` parameter:

```ruby
def as_json(*args)
  super(only: [:title, :body, :created_at])
end
```

And, again, you can use the same syntax for `as_xml`.

#### Reducing Redundancy

Using either approach you should not list the visible/invisible attributes in *both* `as_xml` and `as_json`.

```ruby
WHITELIST_ATTRIBUTES = [:title, :body, :created_at]

def as_json(*args)
  super(only: WHITELIST_ATTRIBUTES)
end

def as_xml(*args)
  super(only: WHITELIST_ATTRIBUTES)
end
```

## Checking Authorization

More often you want to filter based on authorization rules. For instance, if the current user is an administrator then show them everything. If the current user is just a regular user then show them the filtered list. This is much harder.

You are working with data, which means the logic belongs in the model. But you're dealing with authorization, which really belongs in the controller. And, at the core, you're dealing with presentation which goes in the view. It's tricky!

### Using a Decorator

The best way to handle this situation is to use a decorator with the Draper gem.

<div class="note">
<p>For this approach to work properly, comment out any work done to override or filter <em>as_json</em> at the model level.</p>
</div>

#### Setup

Add the `draper` gem to your `Gemfile` and run `bundle`.

#### Generate the Decorator

Then generate the decorator object:

```
rails generate decorator Article
```

Which will create `app/decorators/article_decorator.rb`

#### Use the Decorator

Before we look at implementing the actual decorator, let's set it up for use in `ArticlesController`. Presume we're interested in converting a single `Article` into JSON using the `show` action.

It should, so far, look like this:

```ruby
class ArticlesController < ApplicationController
  respond_to :json, :html

  def show
    @article = Article.find(params[:id])
    @comment = @article.comments.new
    respond_with(@article)
  end
#...
end
```

Using the decorator is just a one-line change:

```ruby
@article = Article.find(params[:id])
#becomes
@article = Article.find(params[:id]).decorate
```

The decorator class will handle the lookup with the `Article` class and wrap the result.

#### Decorator with Context

But our purpose was to handle the authentication status in the decorator. In Draper, this is called the context. Since we don't have an authentication system, let's pass in a symbol representing the current user's "role", `:admin`.

```ruby
@article = Article.find(params[:id]).decorate(context: {role: :admin})
```

Within the decorator, that `:admin` will be stored under the `:role` key in the `context`.

#### Implement the `as_json` Method

Now we're ready to actually implement the `as_json` in the decorator. We open `app/decorators/article_decorator.rb` and find this frame:

```ruby
class ArticleDecorator < Draper::Decorator
  delegate_all
end
```

Then we add a `as_json` method which proxies the call to the wrapped `model`:

```ruby
class ArticleDecorator < Draper::Decorator
  delegate_all

  def as_json(*args)
    object.as_json
  end
end
```

You could test that it works in your console:

```irb
> a = Article.find(15).decorate
# => #<ArticleDecorator:0x007fa2ca1b6a10 @object=#<Article id: 15, title: "asdfasdf", body: "asdf", created_at: "2011-09-11 16:46:52", updated_at: "2011-09-12 20:34:42", author_name: "Stan", editor_id: 5>, @context=nil> 
> a.as_json
# => "{\"article\":{\"author_name\":\"Stan\",\"body\":\"asdf\",\"created_at\":\"2011-09-11T16:46:52Z\",\"editor_id\":5,\"id\":15,\"title\":\"asdfasdf\",\"updated_at\":\"2011-09-12T20:34:42Z\"}}" 
```

Then, in the `as_json`, handle the switching based on `context`:

```ruby
def as_json(*args)
  if context[:role] == :admin
    object.as_json
  else
    object.as_json(only: :title)
  end
end
```

And test it in console:

```irb
> a = Article.find(15).decorate
# => #<ArticleDecorator:0x007fe8f5361f60 @object=#<Article id: 15, title: "asdfasdf", body: "asdf", created_at: "2011-09-11 16:46:52", updated_at: "2011-09-12 20:34:42", author_name: "Stan", editor_id: 5>, @context=nil> 
> a.as_json
# => "{\"article\":{\"title\":\"asdfasdf\"}}" 
> a.context = {:role => :admin}
# => {:role => :admin}
> a.as_json
# => "{\"article\":{\"author_name\":\"Stan\",\"body\":\"asdf\",\"created_at\":\"2011-09-11T16:46:52Z\",\"editor_id\":5,\"id\":15,\"title\":\"asdfasdf\",\"updated_at\":\"2011-09-12T20:34:42Z\"}}" 
```

Success! When context is blank you see the filtered output. When the context is setup for an admin, you get the full output.

## Exercises

{% include custom/sample_project.html %}

1. Implement a filtering `as_json` method in the `Article` model so only the `title` is returned.
2. Use a blacklist constant to generate `as_json` and `as_xml` methods in `Article` so they do *not* display the timestamps.
3. Setup the Draper gem, create an `ArticleDecorator`, and use it in the controller. Verify it works from the console.
4. Implement a `as_xml` method in the decorator which outputs only the `title` and `body` attributes.
5. Add switching to your `as_xml` so:
  * when the `context` is `:admin`, all attributes are output
  * when the context is `:trusted`, everything *except* the timestamps are output
  * when the context is empty, only the `title` and `body` are output.

## References

* Rails Serialization: http://api.rubyonrails.org/classes/ActiveRecord/Serialization.html
* Rails `as_json` API: http://api.rubyonrails.org/classes/ActiveModel/Serializers/JSON.html
* Draper decorators: https://github.com/jcasimir/draper
