---
layout: page
title: Exposing an API
section: Web Services
---

APIs are becoming an essential feature of modern web applications. Rails does a good job of helping your application provide an API using the same MVC structure you are accustomed to.

{% include custom/sample_project.html %}

## In the Controller

Here is an example controller:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def create
    @article = Article.new(params[:article])
    if @article.save
      redirect_to article_path(@article), notice: "Your article was created."
    else
      flash[:notice] = "Article failed to save."
      render action: :new
    end
  end
  #...
end
```

We decide to service JSON and XML requests from these two actions. The `index` will be triggered by a `GET` request to `/articles.json` or `/articles.xml`. The `create` will be triggered by a `POST` request to the same paths.

### `respond_to`

The first step is to call `respond_to` and list the formats our controller will respond to. This is typically done at the beginning of the controller:

```ruby
class ArticlesController < ApplicationController
  respond_to :html, :json, :xml
  #...
end
```

Our controller will now attempt to respond to requests for HTML, JSON, or XML.

<div class="opinion">
<p>When starting out with an API, I often forget the <code>:html</code> in the <code>respond_to</code>. The application will work at first because it will match an existing view template for the rendering. But, once you start using <code>respond_with</code>, your responses will be blank unless you include <code>:html</code> here.</p>
</div>

If you request `/articles.json` you will find that the application is still unsuccessfully trying to render `articles.json.erb`.

### `respond_with`

You could write a view template for JSON and one for XML, but doing so is a tremendous pain. Instead, we would like to render the data directly from the controller.

#### Simple Rendering

In the past, we broke down each format response using `respond_to` in the controller action:

```ruby
def index
  @articles = Article.all
  respond_to do |format|
    format.html
    format.xml { render xml: @articles }
    format.json { render json: @articles }
  end
end
```

It led to a lot of repetition. In Rails 3, we can instead use `respond_with`:

```ruby
def index
  @articles = Article.all
  respond_with(@articles)
end
```

The `respond_with` method will first attempt to render a matching view template for the response type, like `index.json.erb` or `index.html.erb`. If that template is *not* found, then the method will call `.to_xml` or `.to_json` on the object and render the result.

By combining `respond_to` and `respond_with` we can save a lot of boilerplate code that was prevalent in Rails 2.

#### Object Validation

But how is this technique used when we write a `create` action that checks object validation? We started with this:

```ruby
def create
  @article = Article.new(params[:article])
  if @article.save
    redirect_to article_path(@article), notice: "Your article was created."
  else
    flash[:notice] = "Article failed to save."
    render action: :new
  end
end
```

We can achieve the same functionality using `respond_with`:

```ruby
def create
  @article = Article.new(params[:article])
  if @article.save
    flash[:notice] = "Your article was created."
  else
    flash[:notice] = "Article failed to save."
  end
  respond_with @article
end
```

Then refactoring the branch into a ternary:

```ruby
def create
  @article = Article.new(params[:article])
  flash[:notice] = @article.save ? "Your article was created." : "Article failed to save."
  respond_with @article
end
```

When we pass `@article` to `respond_with`, it will actually check if the object is `valid?` first. If the object is *not valid*, then it will call `render :new` when in a `create` or `render :edit` when in an `update`. 

If the object *is valid*, it will automatically redirect to the `show` action for that object.

#### Controlling the Redirect

Maybe you would rather redirect to the `index` after successful creation. You can override the redirect by adding the `:location` option to `respond_with`:

```ruby
def create
  @article = Article.new(params[:article])
  flash[:notice] = @article.save ? "Your article was created." : "Article failed to save."
  respond_with @article, location: articles_path
end
```

#### Overriding by Format

Does that action feel too simple? Would you like to bring back some of the heavy syntax from Rails 2? Then specify the response by output format:

```ruby
def create
  @article = Article.new(params[:article])
  flash[:notice] = @article.save ? "Your article was created." : "Article failed to save."
  respond_with @article do |format|
    format.html { @article.valid? ? redirect_to(@article) : render(:new) }
    format.json { render json: @article }
    format.xml  { render xml: @article }
  end
end
```

#### Filtering Data

When you use `respond_with` to output JSON or XML, it will, by default, dump all the attributes. Next we will look at how to filter these attributes from the model layer.

## Exercises

1. Modify `ArticlesController` so **all** actions use `respond_with` and can speak JSON and HTML.
2. Make similar changes to `CommentsController` so comments can be read and written via JSON.
3. CHALLENGE: Use http-console (https://github.com/cloudhead/http-console) to interact with the application using JSON

## Resources

* `ActionController::Responder` API: http://api.rubyonrails.org/classes/ActionController/Responder.html
* AsciiCast on Rails 3 Controllers: http://asciicasts.com/episodes/224-controllers-in-rails-3
* PlatformaTec posts on `respond_with`: http://blog.plataformatec.com.br/tag/respond_with/
