---
layout: page
title: Flash
section: Controllers
---

HTTP is a stateless protocol. The server, generally speaking, has no idea if request number 243 came from the same user as request number 236. That's beautiful and, at the same time, annoying.

Web applications frequently need to persist state between requests. That might mean a shopping cart that follows a user through the online store, but it can be as simple as a status message.

In modern applications users expect feedback. After clicking a delete link, a user expects not just to see the item disappear, but also some "Item Deleted" message. In Rails we handle these messages using the `flash`.
 
## Flash as a Hash

Developers often refer to the flash as a hash. Is it? As an experiment, within a controller action, you could try this:

```ruby
def index
  raise flash.class.to_s
  #...
end
```

Trigger that method from a browser and you'll find that the flash is an instance of `ActionDispatch::Flash::FlashHash`. When you use `flash`, you're calling a helper method which returns this ActiveDispatch object to you. It acts a lot like a Ruby `Hash`, yes, but adds more functionality under the hood.

For our purposes, though, we can think of it as a hash-like object.

## Flash Messages

The flash will be our message storage object. Let's look at how, where, and when to set messages.

### The Normal Way

The easiest and most common way to set a message explicitly is in the controller. For instance, in a `destroy` action:

```ruby
class ArticlesController < ApplicationController
  def destroy
    article = Article.find(params[:id])
    article.destroy
    flash[:notice] = "Article '#{article.title}' was deleted."
    redirect_to articles_path                
  end
end
```

### Common Keys

In this example we used the `:notice` key, but you can use any key you want within the flash to hold your messages. It's just a matter of matching up the setting in the controller with the display in the view template. But a few keys are commonly used based on their implications for the user:

* `:notice`: _"Everything is cool, just letting you know."_
* `:alert`: _"Something is wrong, but it can probably be fixed."_
* `:error`: _"Something is really wrong and is probably irrecoverable"_

If those don't feel like a good fit for your application you can make up your own

### In the Redirect

The actions where we want to set a flash message are often the same ones that necessitate a redirect. In Rails 3 the `redirect_to` helper added options to specify the flash message in the redirect call itself.

Instead of this:

```ruby
class ArticlesController < ApplicationController
  def destroy
    article = Article.find(params[:id])
    article.destroy
    flash[:notice] = "Article '#{article.title}' was deleted."
    redirect_to articles_path                
  end
end
```

We can pass a `notice:` argument to `redirect_to` like this:

```ruby
class ArticlesController < ApplicationController
  def destroy
    article = Article.find(params[:id])
    article.destroy
    redirect_to articles_path, notice: "Article '#{article.title}' was deleted."
  end
end
```

`redirect_to` will accept `:notice` and/or `:alert` keys. If you want to set a custom key, like `:error`, you could do it like this:

```ruby
class ArticlesController < ApplicationController
  def destroy
    article = Article.find(params[:id])
    article.destroy
    redirect_to articles_path, flash: {error: "Article '#{article.title}' was deleted."}
  end
end
```

But, then, what's really the point? If you're using custom keys, it's easier to just set the flash in its own line.

## Displaying the Flash

You *set* the flash message in the controller then you have to *display* it in the view layer. 

It's generally a good idea to display the flash in your application layout. That way it's available on every page and you don't have to remember it in individual view templates.

### Specific Keys

The `flash` helper method is available in the view just like it was in the controller. A simple ERB injection and hash-style lookup will fetch the data:

```erb
<p class='flash notice'>
  <%= flash[:notice] %>
</p>
```

That will display a message stored under the `:notice` key.

#### Adding Conditions

But what about when there is no `flash[:notice]`? You'll get a set of empty `<p>` tags, which could look strange in your layout.
  
In Ruby, if you ask a hash for a key that doesn't exist you'll get back `nil`. Since Ruby considers `nil` to be "falsey", we can write a condition like this:

```erb
<% if flash[:notice] %>
  <p class='flash notice'>
    <%= flash[:notice] %>
  </p>
<% end %>
```

5 lines to display one message? We can refactor it by using the `content_tag` helper and an inline condition:

```erb
<%= content_tag :p, flash[:notice], class: "flash notice" if flash[:notice] %>
```

### Iterating

If our application uses multiple keys, like `:notice`, `:alert`, and `:error`, then we'd need to do that three times:

```erb
<%= content_tag :p, flash[:notice], class: "flash notice" if flash[:notice] %>
<%= content_tag :p, flash[:alert], class: "flash alert" if flash[:alert] %>
<%= content_tag :p, flash[:error], class: "flash error" if flash[:error] %>
```

Iteration allows us to reduce the redundancy:

```erb
<% flash.each do |key, message| %>
  <%= content_tag :p, message, class: "flash #{key}" %>
<% end %>
```

The condition is no longer necessary because if there aren't keys in the flash, the iteration will just never run.

## Exercises

{% include custom/sample_project.html %}

The Blogger project already uses flash messages, but we can try a few experiments with `ArticlesController`:

1. Refactor `update`, `destroy`, and `create` to set the `:notice` message in the `redirect_to`
2. Add a message under the `:validation` key when an article fails to validate, then display this key in a dedicated paragraph within the form partial.
3. Refactor the flash display in the application layout to iterate through all keys.
  * CHALLENGE: make it so the `:validation` key is skipped in the top display, allowing it to only show up in the form.
4. Move the body of your flash messages into the `en.yml` locale file and load them using the `t` helper
