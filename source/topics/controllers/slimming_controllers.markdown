---
layout: page
title: Slimming Controllers
section: Controllers
---

Controllers are supposed to be stupid. They're just a connector between the model and the view layers, handling information about the request and send it where it needs to go.

<div class="note">
<p>This tutorial is open source. Please contribute fixes or additions to <a href="https://github.com/JumpstartLab/curriculum/blob/master/source/topics/controllers/slimming_controllers.markdown">the markdown source on GitHub.</a></p>
</div>

{% include custom/sample_project_advanced.html %}

## Pushing Responsibility Down the Stack

In reality, most controllers do way more than simple request dispatch. They shepherd data, they react to many failure conditions, and they represent business logic. That's bad.

Why is it bad? Because controllers trap logic. They're more difficult to test than models, and the logic is almost impossible to reuse. Placing business logic inside a controller immediately violates the Single Responsibility Principlce.

So let's look at ways to reduce complexity in the controller. One method is to push domain logic down into the model layer.

### Limiting Logical Switching

The way many controllers get crazy is through parameter switching. "If this parameter is present, do one thing, otherwise, look for this other parameter, if it's there, do another thing" and so on.

Just because Rails structures REST into seven methods doesn't mean your controller is constrained to those. If you find an action growing beyond about 8 lines of code, use the extract method refactoring to pull it into another controller method.

But don't stop there. This is a sign that you have logic to push down to the model. Don't have an appropriate model? Make one! Maybe it's a facade, maybe it's more of a worker. Whatever the need, push that logic down to the model layer and activate it from the controller.

Then get rid of your custom method. As we've said, Rails doesn't restrict your controllers to the seven RESTful ones. But it's a darn good idea to strive for.

### Looking at `index`

In the implementation of the `index` action, we've pushed all the logic down to the model. In this case, we might want to further refactor the model, which might be too complex, but it's good enough to illustrate the process we're talking about.

In the controller, we have:

```ruby
  def index
    @articles, @tag = Article.search_by_tag_name(params[:tag])
  end
```

Our goal here is to find the articles to list by the provided tag name. Down in the model we've defined:

```ruby
  def self.search_by_tag_name(tag_name)
    if tag_name.blank?
      [Article.scoped, nil]
    else
      tag = Tag.find_by_name(tag_name)
      tag ? [tag.articles, tag] : [[], nil]
    end
  end
```

If the tag name passed is `nil` or the empty string, the method will return `Article.scoped`, which is a lazy query version of `Article.all`. If a name is provided, it will find the tag with that name and return both the tag's articles and the tag. If the name was not found, it will return an empty array and nil.

This isn't the most complex logic ever, but testing it in the controller would be a bit of work. Check out `article_spec.rb` to see how easy the unit tests are.

## Interfaces

Good object-oriented design relies on loose coupling -- having distinct roles and responsibilities tied together with as few strings as possible.

Rails controllers and Rails views are, according to the premise of MVC, distinct responsibilities. They should be separate objects who communicate by just a few well-defined connection points.

But that's not how Rails works.

How do you get data from inside a controller action to the view template? Instance variables. Look at a familiar form of controller action inside a controller, `ArticlesController`:

```ruby
class ArticlesController < ApplicationController
  def show
    @article = Article.find(params[:id])
  end

  #...
end
```

When Rails renders the view for the `show` action, it copies instance variables from the controller into the rendered view, clearly coupling together those two components.

<div class="opinion">
<p>Any time you use an instance variable in Ruby, ask yourself: "Is there a better way?" The answer is almost always "yes."</p>
</div>

### Limiting Instance Variables

A normal controller action is going to have one instance variable. Many actions will use two or three variables, but if you're getting up above that it's a sign that you're missing a domain abstraction.

What is the essential "link" between these objects? Why do they all belong on the same page? Whatever the reason, that should probably be a domain object. Check out the [Facade pattern]({% page_url /topics/models/facade_pattern %}).

### A Better Interface

Can we do without instance variables all together? How do we normally get data from an object?

Frequently we use accessor methods. How do we write accessors for a controller? It's actually quite easy. Let's look again at this controller and action:

```ruby
class ArticlesController < ApplicationController
  def show
    @article = Article.find(params[:id])
  end

  #...
end
```

#### View Template Usage

In the view template, we access that object like this:

```erb
<h1><%= @article.title %></h1>
```	

If we weren't using an instance variable, what would we *want* it to look like? How about this:

```erb
<h1><%= article.title %></h1>
```

How can we make that work? Rails is going to look for a helper method named `article`. No problem.

#### Implementing a Helper Method

Let's go back to the controller. We can add an `article` method like this:

```ruby
class ArticlesController < ApplicationController
  def show
    @article = Article.find(params[:id])
  end

  def article
    Article.find(params[:id])
  end

  #...
end
```

We don't have to pass in `params` to our new method, since it's still in the controller context and can access the normal `params` just as any action can.

Load the view and it won't work. Just defining the method on the controller isn't enough, we have to expose it to the view as a helper:

```ruby
class ArticlesController < ApplicationController
  def show
    @article = Article.find(params[:id])
  end

  def article
    Article.find(params[:id])
  end

  helper_method :article

  #...
end
```

Now the view will work. But what about that `show` action? If the view is accessing the `article` helper, let's get rid of the instance variable all together:

```ruby
class ArticlesController < ApplicationController
  def show
  end

  def article
    Article.find(params[:id])
  end

  helper_method :article

  #...
end
```

You can even remove the `show` method, if you like. Change the references in the view template from `@article` to `article` and you'll be good to go.

#### The `new` Action

The `show` was straightforward, what about the `new`?

```ruby
  def new
    @article = Article.new
  end
```

In the view template we expect `@article` to be our new, blank object. If we use the existing helper, it will try to do a lookup based on `params[:id]`.

No problem. Just add logic that reacts to `params[:id]` in the helper method:

```ruby
class ArticlesController < ApplicationController
  def new
  end

  def article
    if params[:id]
      Article.find(params[:id])
    else
      Article.new
    end
  end

  helper_method :article

  #...
end
```

We eliminate the code from the `new` method and change the view template to use the helper instead of the instance variable.

#### Performance Considerations

Whoah, did you notice the console log when looking at the `show` view? If you haven't, take a look. It seems we're kicking off a bunch of queries, one for each call to our helper.

Not a problem: we'll use an instance variable to memoize the object after the first request.

<div class="note">
<p>Memoization is an optimization technique that avoids expensive recomputation by storing the result of an operation. It is related to caching.</p>
</div>

Here's an example:

```ruby
class ArticlesController < ApplicationController
  def article
    @cached_article ||= if params[:id]
      Article.find(params[:id])
    else
      Article.new
    end
  end

  # ...
end
```

Why is the variable called `@cached_article`? I don't want to use `@article`, or _someone_ will come along and start using the instance variable in the views. If you want to talk to my article, you should use the accessor method I've defined and I want to strongly encourage you to do that.

But maybe you want to make the code even cleaner. You see lookup logic and you want to press it down to the model. Great idea! You could build something like this:

```ruby
class Article < ActiveRecord::Base

  def find_or_build(input_id = nil)
    if input_id.present?
      Article.find(params[:id])
    else
      Article.new
    end
  end
end
```

But that's *unnecessary*. You can take advantage of the built in `find_or_initialize_by` in `ActiveRecord`:

```ruby
class ArticlesController < ApplicationController
  def article
    @cached_article ||= Article.find_or_initialize_by_id(params[:id])
  end

  # ...
end
```

The `find_or_initialize_by` method will return the record with the given id if it's found and otherwise will return a new instance of the class, which in this case is `Article`.

<div class="opinion">
<p>Some people will choose to wrap that finder with a method in their model to hide `ActiveRecord`, but I believe that's silly for such a simple case.</p>
</div>

#### Exercises

* Rewrite the `edit` action and view so they use the `article` method
* Rewrite the `destroy` action so it uses the method
* Rework `create` and `update` to minimize the code repetition and instance variables
  * `update` is not too tricky because you can call `.update_attributes` on the return value of `article`
  * For `create`, using the same style as `update` but, instead of calling `.update_attributes`, use `.attributes=` which does not trigger the save implicitly. For example:

{% irb %}
$ a = Article.new
 => #<Article id: nil, title: nil, body: nil, created_at: nil, updated_at: nil>
$ a.attributes = {title: "Hello"}
 => {title:"Hello"}
$ a.inspect
 => "#<Article id: nil, title: \"Hello\", body: nil, created_at: nil, updated_at: nil>"
$ a.attributes = {body: "World"}
 => {body:"World"}
$ a
 => #<Article id: nil, title: "Hello", body: "World", created_at: nil, updated_at: nil>
{% endirb %}

* Try integrating this approach with the decorator pattern. It's probably best to write a wrapper method in the `Article` model that's similar to `find_or_initialize_by_id`, but handles the decoration.

#### Reflections

By adding just a little bit of code to your controller, you have:

* Eliminated a lot of duplicated logic
* Cut down the total code in your controller
* Improved the interface between controller and view template

#### Next Steps

Should you rewrite this in every controller? Probably not! What would it take to write more general forms which could be reused across controllers? You would probably define a method that's called from each controller which generates the helper methods on the fly.

That's exactly what Basic Assumption (https://github.com/mattyoho/basic_assumption) does. It's a very helpful but simple gem I strongly recommend you try out.
