---
layout: page
title: Handling Parameters
section: Controllers
---

The controller's jobs include:

* work with the request parameters
* determine how to activate the domain logic and data
* respond to requests

The parameters give the controller the information it needs.

At the same time, parameters are often the cause of confusion and complication in a controller. A controller method should be about eight lines of Ruby. But many actions spiral out of control with all kinds of switching based on the input parameters.

## `params` Helper

Developers commonly refer to `params` as a variable, but it isn't -- it is a helper method provided by `ActionController` which returns a hash containing the request parameters.

### Hash Structure

Developers new to Rails often struggle with the nested hashes inside `params`. When processing a form, `params` might look like this:

```ruby
{"utf8"=>"✓", "authenticity_token"=>"id7z1vIP1N2e0I8QtXQjflsNwcWdBwcyUuOrywEV52c=", 
"article"=>{"title"=>"Hello", "body"=>"World"}, "commit"=>"Create Article"}
```

It's a little easier to understand the structure by converting to YAML (using `.to_yaml`):

```
---
utf8: "✓"
authenticity_token: id7z1vIP1N2e0I8QtXQjflsNwcWdBwcyUuOrywEV52c=
article:
  title: Hello
  body: World
commit: Create Article
action: create
controller: articles
```

The outer hash has these keys:

* `utf8` - this marker is in all form submissions to force Internet Explorer to properly encode UTF-8 data
* `authenticity_token` - a security mechanism used by the `protect_from_forgery` method called in `ApplicationController`
* `article` - the sub-hash containing the data from our HTML form
* `commit` - the label text of the button that was clicked
* `action` - which action is being executed
* `controller` - which controller is being executed

## Implementation Patterns

Given those parameters, asking for `params[:article]` will return the nested hash:

```ruby
{"title"=>"Hello", "body"=>"World"}
```

The `create` action can use those values to build the `Article`

### `ActiveSupport::HashWithIndifferentAccess`

The original hash had a key `"article"`, but the example accessed it by calling `params[:article]` with a symbol. How?

{% irb %}
$ params1 = {"article" => {"title"=>"Hello", "body"=>"World"}}
 => {"article"=>{"title"=>"Hello", "body"=>"World"}} 
$ params1.class
 => Hash 
$ params1["article"]
 => {"title"=>"Hello"} 
$ params1[:article]
 => nil
{% endirb %}

A Ruby `Hash` with key `"article"` will not respond to `:article`.

Within the Rails internals there are almost no hashes. Instead, what look like hashes are actually instances of `ActiveSupport::HashWithIndifferentAccess`:

{% irb %}
$ params2 = ActiveSupport::HashWithIndifferentAccess.new({"article" => {"title"=>"Hello", "body"=>"World"}})
 => {"article"=>{"title"=>"Hello"}} 
$ params2.class
 => ActiveSupport::HashWithIndifferentAccess 
$ params2["article"]
 => {"title"=>"Hello"} 
$ params2[:article]
 => {"title"=>"Hello"} 
{% endirb %}

It's named *IndifferentAccess* because it allows us to do lookups with either string or symbol versions of the keys. Most often we'll access them using the symbol version.

#### Symbols vs. Strings

If we can use either symbols or strings, why prefer symbols?

* It's one fewer character to type
* Strings are for *users*. They're things we take in from the form, data we store in the database, output we show in the view.
* Symbols are for *programs*. They're used for internal messaging and data structures like traversing a hash
* Symbols use significantly less memory, saving Garbage Collection cycles 

Use symbols when you can, strings when you have to.

### `params` in a Simple Action 

The most straightforward usage of `params` is to lookup a single key and do something with the retrieved value:

```
def show
  @article = Article.find(params[:id])
end
```

### `params` with Mass Assignment

Typically in a `create` action we'll make use of mass-assignment:

```ruby
def create
  @article = Article.new(params[:article])
  #...
```

That is equivalent, given our example `params`, to this:

```ruby
@article = Article.new(title: params[:article][:title],
                       body: params[:article][:body])
```

In this long form, we're building up a hash with keys `:title` and `:body`, but it's pointless! When we query for `params[:article]` we get back the nested hash. That hash has keys `:title`, `:body` -- exactly as we're building up here. So when we use this form:

```ruby
def create
  @article = Article.new(params[:article])
  #...
```

We're passing in a hash of data. This method is preferred because it is shorter to read/write and, more importantly, it doesn't need alteration if we add new attributes to the model and form.

### `params` Gone Wrong

Here's one of the common ways that developers abuse parameters and controller actions:

```ruby
def index
  if params[:order_by] == 'title'
    @articles = Article.order('title')
  elsif params[:order_by] == 'published'
    @articles = Article.order('created_at DESC')
  else
    @articles = Article.all
  end
end
``` 

We're anticipating a parameter named `:order_by` and want to sort based on that. Here's a cleanup of just the Ruby syntax to use a `case` statement:

```ruby
def index
  @articles = case params[:order_by]
    when 'title'     then Article.order('title')
    when 'published' then Article.order('created_at DESC')
    else                  Article.all
  end
end
```

Whenever you're tempted to write `variable = case #...` or `variable = if #...`, you should really encapsulate the right side into a method. In the "Mass Assignment" section, we said that sending the parameters down to the model in bulk was a maintenance win because the controller won't have to change when the model adds attributes.

If changes to one component of the system necessitate changes in another then those objects are *coupled*. By having this logic for sorting in the controller, we increase the coupling between controller and model which, in the long run, hurts. What if we emulated the idea of proxying to the model?

```ruby
def index
  @articles = Article.ordered_by(params[:order_by])
end
```

Imagine we have a class method on `Article` named `ordered_by`. We send the parameter down to the model and let it figure out what that string means in the context of our domain and data -- which is exactly the job of the model. The implementation there looks familiar:

```ruby
class Article < ActiveRecord::Base
  #...
  
  def self.ordered_by(param)
    case param
    when 'title'     then Article.order('title')
    when 'published' then Article.order('created_at DESC')
    else                  Article.all
  end
end
```

This isn't about writing less code, it's about writing code in the right place. The model is responsible for logic and working with data. Don't let it leak up into your controllers!
 
## Exercises

{% include custom/sample_project.html %}

1. Open the `ArticlesController` in Blogger and find the `create` action. As an experiment, rewrite it setting each form value individually rather than using mass-assignment.
2. In the `index` action, implement handling for an `order_by` parameter as modeled in the text. Add an option to sort by `"word_count"`
3. Add links to the index page which, when clicked, change the sorting to `"title"`, `"word count"`, or `"published"`. *CHALLENGE*: Add links and handling so each of these can be _inverted_.
4. In the `index` action of `ArticlesController`, handle a parameter named `"limit"` which will limit how many articles are displayed. If there is no `"limit"`, display all the articles.
5. Push the logic from exercise 4 down to the model, creating a method named `only` in `Article`.

## References

* Rails Guide on Parameters: http://guides.rubyonrails.org/action_controller_overview.html#parameters
* `ActiveSupport::HashWithIndifferentAccess`: http://as.rubyonrails.org/classes/HashWithIndifferentAccess.html
* UTF-8 Hacks for Internet Explorer: http://stackoverflow.com/questions/3222013/what-is-the-snowman-param-in-rails-3-forms-for/3348524#3348524
