---
layout: tutorial
title: Pagination
---

## Pagination

As our application data grows we frequently need pagination. In Rails 2 everyone used a gem named `will_paginate` also referred to as `mislav-will_paginate` from the brief time we built RubyGems directly off GitHub.

Rails 3 brought a totally new model architecture under the hood of ActiveRecord, and the way `will_paginate` hacked itself into the system doesn't fit anymore. Thankfully there's a new pagination library named Kaminari (<https://github.com/amatsuda/kaminari>) built from scratch for Rails 3 that fits in with the new ARel syntax.

### Basics

There are three components to implementing pagination:

* Processing parameters to specify page and quantity-per-page
* Scoping the data queries based on those parameters
* Displaying page links

#### Processing Parameters

Typically applications will just use a parameter named "page" in the request URL like this:

```
http://localhost:3000/articles?page=2
```

The Rails router will parse that URL parameter and make it available in `params[:page]`.

#### Scoping Queries

Normally we'd query our articles like this:

```
@articles = Article.all
```

Or we could build an ActiveRelation object with:

```
@articles = Article.scoped
```

Kaminari adds two important methods that we can mix into ActiveRelation queries. The first is `page` method to specify which page we want:

```
@articles = Article.scoped.page(2)
```

By default it'll limit each page to 25 elements. But to customize that, we can add `per` which specifies how many objects should appear on each page:

```
@articles = Article.scoped.page(2).per(5)
```

Or, more commonly, feed that page in from `params`:

```
@articles = Article.scoped.page(params[:page]).per(5)
```

If `page` is given `nil` as a parameter, which will happen when the parameter is not present in the URL, Kaminari will return the first page.

#### Dealing with Links

Kaminari makes rendering links exceptionally easy. Assuming that we have a collection `@articles` that has been treated with `per` and `page`, in the view template we can just write:

```ruby
= paginate @articles
```

### Exercises

#### Getting Started with Kaminari

Open the `Gemfile` and express the new dependency:

```ruby
gem 'kaminari'
```

Save it and run `bundle` from the project directory.

#### Generating More Sample Data

The starter database has just a few articles. To show off the pagination, let's generate more sample data. Open up `rails console` and run this code:

```ruby
80.times{ Fabricate(:article_with_comments) }
```

Now you should have at least 80 sample articles that we can break up into clean pages.

#### Experimenting with Kaminari

Let's open `app/controllers/articles_controller.rb`. We only need to paginate the `index`. Currently it reads:

```
def index
  @articles = Article.search(params)
end
```

If you dig into the `.search` class method in `Article`, you'd find this:

```ruby
def self.search(params)
  if params[:tag].nil?
    Article.all
  else
    tag = Tag.find_by_name(params[:tag])
    tag.articles
  end
end
```

The `.search` method is going to return a set of articles. We can paginate them from the controller. As an experiment, let's rewrite our `index` method like this:

```ruby
def index
  @articles = Article.search(params).page(1).per(10)
end
```

Refresh your browser and it'll blow up! It complains that the `page` method does not exist for `Array`. What's the issue?

Kaminari is built to work with Rails 3 ARel queries, but our `.search` method is returning an actual array of `Article` objects. The fix is easy. Look in the `self.search(params)` method and change this line:

```ruby
Article.all
```

To this:

```ruby
Article.scoped
```

If you haven't used it before, the `.scoped` method creates an ARel query with no conditions, equivalent to `Article.all`. Refresh your browser and it should work!

### Pagination in the View

When you look at the browser it's cut down to 10 articles, but there are no pagination links. Let's add those now.

Open the `app/views/articles/index.html.haml` template and add this at the bottom:

```ruby
= paginate @articles
```

Refresh the view and you should see the page links show up. There are additional options available to control how many page links are rendered, but I typically just use the defaults. If you're interested in customization, check out the [Kaminari Recipes](https://github.com/amatsuda/kaminari/wiki/Kaminari-recipes) (https://github.com/amatsuda/kaminari/wiki/Kaminari-recipes).

### Respecting `page`

Click those links, though, and you'll see our controller is not respecting the `page` parameter. No matter which link we click we'll see the same articles. Go back to the `index` action in `ArticlesController` and add the `page` parameter like this:

```ruby
def index
  @articles = Article.search(params).page(params[:page]).per(10)
end
```

That should work just fine. If you want to make the demonstration more convincing, let's alphabetize the articles by title:

```ruby
def index
  @articles = Article.search(params).page(params[:page]).per(10).order(:title)
end
```

Click through the pages and you'll see the alphabetization holds up. Isn't that *odd*? Considering the method-chaining style above, it looks like we'd be ordering the listings within an individual pages because it happens *after* the `page` / `per` calls. If Kaminari worked on plain arrays, this would be a problem. Since it relies on the beauty of ARel scopes, the `.order` call can come before or after -- it doesn't matter. Together the methods build up a query and one when the data is actually needed, as the view template tries to render the objects, is the query actually kicked off.

### Kaminari Wrap-Up

That's really all there is to the normal usage of Kaminari pagination. With a little more work you can implement AJAX pagination if that's your thing or add I18n keys to control the display of your links. The documentation is straight-forward and available here: <https://github.com/amatsuda/kaminari>.