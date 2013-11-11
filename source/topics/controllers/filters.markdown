---
layout: page
title: Filters
section: Controllers
---

The Rails REST implementation dictates the default seven actions for your controllers, but frequently we want to share functionality across multiple actions or even across controllers. Controller filters are one way to do that.

## Before, After, and Around

There are three types of filters implemented in Rails:

* `before_filter` runs before the controller action
* `after_filter` runs after the controller action
* `around_filter` yields to the controller action wherever it chooses

### Basic Usage

`before_filter` is, by far, the most common. There are two ways to invoke a before filter. First, as an anonymous block:

```ruby
class ArticlesController < ApplicationController
  before_filter do
    @article = Article.find(params[:id]) if params[:id]
  end
  #...
```

As written, this `before_filter` will execute before every action in the controller. We'll look at options to scope this behavior later.

While the anonymous block style works, it's usually cleaner to implement a named method:

```ruby
class ArticlesController < ApplicationController
  before_filter :load_article
  
  # Actions...
  
private  
  def load_article
    @article = Article.find(params[:id]) if params[:id]
  end
end
```

Since the filter is only going to be used within the controller, and won't be accessed directly by the router, it's good form to make the method private.

#### `after_filter`

An `after_filter` works exactly the same, just executing _after_ the controller action.

#### `around_filter`

The most rare is the `around_filter`. Here is the common example of its usage:

```ruby
around_filter :wrap_actions

def wrap_actions
  begin
    yield
  rescue
    render text: "It broke!"
  end
end
```

Wherever `yield` is called, the action will be executed. So the functionality here could recover from any exception that occurs in the yielded action.

### `only` and `except`

All three filters accept the options `:only` and `:except`:

* `:only`: a whitelist of actions for which the filter should run
* `:except`: a blacklist of actions for which the filter should *not* run.

For example, we could remove the condition from the `before_filter` sample above if we scope to only those actions which will have a `params[:id]`:

```ruby
class ArticlesController < ApplicationController
  before_filter :load_article, only: [:show, :edit, :update, :destroy]
  
  # Actions...
  
private  
  def load_article
    @article = Article.find(params[:id])
  end
end
```

Or get the same effect using `:except`:

```ruby
class ArticlesController < ApplicationController
  before_filter :load_article, except: [:index, :new, :create]
  #...
```

## Sharing Filters

Filters are most often about sharing code across actions in a single controller, but we can also share them across controllers.

### Sharing through `ApplicationController`

The most common way to reuse filters across controllers is to move them to `ApplicationController`. Since all controllers inherit from `ApplicationController`, they'll have access to those methods. For example:

```ruby
class ApplicationController < ActionController::Base
  protect_from_forgery
  
private
  def load_article
    @article = Article.find(params[:id])
  end
end

class ArticlesController < ApplicationController
  before_filter :load_article, only: [:show, :edit, :update, :destroy]
  
  # Actions...
end
```

But how useful will it be to look up an `Article` in other controllers?

#### Generalizing to `find_resource`

With a bit of object introspection and mixing in some metaprogramming, we can write a generalized `find_resource` method that will infer the model name from the current controller:

```ruby
class ApplicationController < ActionController::Base
  protect_from_forgery
  
private
  def find_resource
    class_name = params[:controller].singularize
    klass = class_name.camelize.constantize
    self.instance_variable_set "@" + class_name, klass.find(params[:id])
  end
end

class ArticlesController < ApplicationController
  before_filter :find_resource, only: [:show, :edit, :update, :destroy]
  
  # Actions...
end
```

## Exercises

{% include custom/sample_project_advanced.html %}

1. Implement a `before_filter` in `ArticlesController` to remove all calls to `find` in the actions.
2. Implement an `after_filter` that turns the article titles to all uppercase, but does not change the data in the database.
3. Implement a `before_filter` for just the `create` action on `CommentsController` that replaces the word `"sad"` with `"happy"` in the incoming comment body.
4. Implement an `around_filter` that catches an exception, writes an apology into the `flash[:notice]`, and redirects to the articles `index`. If the exception was raised in `articles#index`, render the message as plain text (`render text: "xyz"`). Cause an exception and make sure it works.

## References

* Rails Guide on Controller Filters: http://guides.rubyonrails.org/action_controller_overview.html#filters
