---
layout: page
title: Render and Redirect
section: Controllers
---

The normal controller/view flow is to display a view template corresponding to the current controller action, but sometimes we want to change that. We use `render` in a controller when we want to respond within the current request, and `redirect_to` when we want to spawn a new request.

## Render

The `render` method is very overloaded in Rails. Most developers encounter it within the view template, using `render partial: 'form'` or `render @post.comments`, but here we'll focus on usage within the controller.

### `:action`

We can give `render` the name of an action to cause the corresponding view template to be rendered. 

For instance, if you're in an action named `update`, Rails will attempt to display an `update.html.erb` view template. If you want it to display the edit form, associated with the `edit` action, then `render` can override the template selection.

This is often used when the model fails validation:

```ruby
def update
  @book = Book.find(params[:id])
  if @book.update_attributes(params[:book])
    redirect_to(@book)
  else
    render action: :edit
  end
end
```

When `render action: :edit` is executed it *only* causes the `edit.html.erb` view template to be displayed. The actual `edit` action in the controller will *not* be executed.

As of Rails 3, the same effect can be had by abbreviating to `render :edit`.

#### In Another Controller

Most commonly you want to render the template for an action in the same controller. Occasionally, you might want to render an action from another controller. Use a string parameter and prefix it with the other controller's name:

```ruby
render 'articles/new'
```

If this were executed in the `CommentsController` it would pull the view template corresponding to `ArticlesController#new`.

### Content Without a View Template

You can use `render` to display content directly from the controller without using a view template.

#### Text

You can render plain text with the `:text` parameter:

```ruby
render text: "Hello, World!"
```

This can be useful for debugging but is otherwise rarely used.

#### XML and JSON

You can render XML or JSON version of an object:

```ruby
render xml: @article
render json: @article
```

Rails will automatically call `.to_json` or `.to_xml` on the passed object for you.

### `:layout`

When using `render` you can override the default layout with the `:layout` option:

```ruby
render :show, layout: 'top_story'
```

Or, maybe in response to an AJAX request, you might want to render the view template with no layout: 

```ruby
render :show, layout: false
```

## Redirect

Use `redirect_to` to spawn a new request.

Why care about a new request? When a user submits data it comes in as a `POST` request. If we successfully process that data we likely show them the data they just created. If they wrote an article and click *SAVE*, then we'd show them that article. We could display the article using `render` in the same `POST` that sent us the data.

But, what's going to happen if they hit refresh? Or click a link, then use their browser's *BACK* button? They'll get a pop-up from the browser: "Submit form data again?" Do they push yes? No? Will clicking *yes* create a duplicate article? Will clicking *no* somehow mess up the old article? It's confusing for the user.

Instead, when you successfully store data you want to respond with an HTML redirect. That will force the browser to start a new request. In our scenario, we'd redirect to the `show` action for the new article. They could refresh this page, navigate forward then back, and it would all be normal `GET` requests -- no warning from the browser.

### `redirect_to`

The `redirect_to` method is typically used with a named route helper:

```ruby
redirect_to articles_path
```

If you're linking to a specific resource outside your application, you might use a full URL string:

```ruby
redirect_to 'http://rubyonrails.org'
```

#### Status Code

By default Rails will use the HTTP status code for "temporary redirect." If you wanted to respond with some other status code, you can add the `:status` parameter:

```ruby
redirect_to 'http://rubyonrails.org', status: 301
```

The request would be marked with status code 301, indicating a permanent relocation.

#### With Flash

You can set a flash message within your call to `redirect_to`. It will accept the keys `:notice` or `:alert`:

```ruby
redirect_to articles_path, notice: "Article Created"
redirect_to login_path, alert: "You must be logged in!"
```

## `redirect_to` and `render` do not `return` 

Keep in mind that `redirect_to` and `render` do not cause the action to stop executing. It is *not* like calling `return` in a Ruby method.

Here's how that could go wrong. Imagine you have a `delete` action like this:

```ruby
def destroy
  article = Article.destroy(params[:id])
  redirect_to articles_path, notice: "Article '#{article.title}' was deleted."
end
```

Then you begin adding security to your application. You've seen "guard clauses" used in Ruby code, where a `return` statement cuts a method off early. You decide to imitate that here:

```ruby
def destroy
  redirect_to login_path unless current_user.admin?
  article = Article.destroy(params[:id])
  redirect_to articles_path, notice: "Article '#{article.title}' was deleted."
end
```

When an admin triggers `destroy`, here's what happens:

1. The `unless` condition is `true`, so the first `redirect_to` is skipped
2. The article is destroyed
3. The browser is redirected the the index

Then some *non-admin* user comes and triggers the `destroy` action:

1. The `unless` condition is `false`, so the `redirect_to` runs, a redirect response is set, *and execution continues*
2. The article is destroyed
3. The second `redirect_to` runs, it sees that a redirect has already been set, and raises an exception (`AbstractController::DoubleRenderError`)

The article gets destroyed either way. The `redirect_to` does not stop execution of the method, it just sets information in the response. The correct way to achieve this protection would be:

```ruby
def destroy
  if current_user.admin?
    article = Article.destroy(params[:id])
    redirect_to articles_path, notice: "Article '#{article.title}' was deleted."
  else
    redirect_to login_path, notice: "Only admins can delete articles."
  end
end
```

## Exercises

{% include custom/sample_project.html %}

1. `ArticlesController` uses the common `save`/`redirect_to`/`render` pattern in `create` and `update`. Change the `redirect_to` to a `render` and recreate the problem of refreshing the page after a successful save. The browser should prompt you about resubmitting the form data.
2. Comment Validation and Correction
  * Comments get created in `CommentsController`, but what if they fail validation? 
  * Add a validation to the `Comment` model. 
  * In the `create` action of `CommentsController`, cause the article's `show` action to render so the comment can be fixed.
  * Add a flash message about the comment failing validation
  * Display the validation error in the comment form
  * If the `create` succeeds, redirect to the `show` for the article
  * Add a flash message to the `redirect_to`
  * Test it out in the interface!
3. Try to create a "double render error" by incorrectly using a guard clause with `redirect_to` in the `delete` action of `ArticlesController`.

## Reference

* RailsGuide on Layouts and Rendering: http://guides.rubyonrails.org/layouts_and_rendering.html
