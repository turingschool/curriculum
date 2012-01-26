---
layout: page
title: Pagination
section: Better Views
---

As our application data grows we frequently need pagination. In Rails 2 everyone used a gem named `will_paginate` also referred to as `mislav-will_paginate`.

Rails 3 brought a totally new model architecture under the hood of ActiveRecord, and the way `will_paginate` hacked itself into the system doesn't fit anymore. Thankfully there's a new pagination library named Kaminari (<https://github.com/amatsuda/kaminari>) built from scratch for Rails 3 that fits in with the new ARel syntax.

## Basics

There are three components to implementing pagination:

* Processing parameters to specify page and quantity-per-page
* Scoping the data queries based on those parameters
* Displaying page links

### Processing Parameters

Typically applications will use a parameter named "page" in the request URL like this:

```
http://localhost:3000/articles?page=2
```

The Rails router will parse that URL parameter and make it available in `params[:page]`.

### Scoping Queries

Normally we would query our articles like this:

```ruby
@articles = Article.all
```

But when we call `.all`, we get back an `Array`. The query has already happened.

#### Using `ActiveRelation` Delayed Queries

To use Kaminari's pagination, we need to create an ActiveRelation object with:

```ruby
@articles = Article.scoped
```

This scope would find the same articles as `Article.all`, but it delays running the query until we actually need the data. Since the query has not been run, Kaminari can still change it.

#### Kaminari's `page` Method

Kaminari adds two important methods that we can mix into ActiveRelation queries. The first is a `page` method to specify which page we want:

```ruby
@articles = Article.scoped.page(2)
```

By default it will limit each page to 25 elements. 

#### Kaminari's `per` Method

To customize the number of items per page, we can add `per`:

```ruby
@articles = Article.scoped.page(2).per(5)
```

Or, more commonly, feed that page in from `params`:

```ruby
@articles = Article.scoped.page(params[:page]).per(5)
```

If `page` is given `nil` as a parameter, which will happen when the parameter is not present in the URL, Kaminari will return the first page.

### Dealing with Links

Assuming that we have a collection `@articles` that has been treated with `per` and `page`, in the view template we can write:

```erb
<%= paginate @articles %>
```

## Exercises

{% include custom/sample_project_advanced.html %}

### Getting Started with Kaminari

Open the `Gemfile` and express the new dependency:

```ruby
gem 'kaminari'
```

Save it and run `bundle` from the project directory.

### Generating More Sample Data

To flex the pagination, you might need to generate more sample data. Open up `rails console` and run this code:

```ruby
80.times{ Fabricate(:article_with_comments) }
```

Now you should have at least 80 sample articles in the database.

### Experimenting with Kaminari

Open `app/controllers/articles_controller.rb`. We only need to paginate the `index`. Currently it reads:

```ruby
def index
  @articles, @tag = Article.search_by_tag_name(params[:tag])
end
```

If you dig into the `.search` class method in `Article`, you'd find this:

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

The `.search_by_tag_name` method is going to return a set of articles. We should be able to paginate them from the controller. 

#### Paginating in the Controller

Let's rewrite our `index` method like this:

```ruby
def index
  all_articles, @tag = Article.search_by_tag_name(params[:tag])
  @articles = all_articles.page(1).per(10)
end
```

Refresh your browser and you should see just one page of articles.

### Pagination in the View

When you look at the browser it is cut down to 10 articles, but there are no pagination links. Let's add those now.

Open the `app/views/articles/index.html.erb` template and add this at the bottom:

```ruby
<%= paginate @articles %>
```

Refresh the view and you should see the page links show up. 

#### Tweaking the Links

There are additional options available to control how many page links are rendered. If you are interested in customization, check out the Kaminari Recipes at https://github.com/amatsuda/kaminari/wiki/Kaminari-recipes

### Respecting `page`

Click those links, though, and you'll see our controller is not respecting the `page` parameter. No matter which link we click we will see the same articles. Go back to the `index` action in `ArticlesController` and add the `page` parameter like this:

```ruby
def index
  all_articles, @tag = Article.search_by_tag_name(params[:tag])
  @articles = all_articles.page(params[:page]).per(10)
end
```

### Kaminari Wrap-Up

With a little more work you can implement AJAX pagination or even add I18n keys to control the display of your links. The documentation is available at https://github.com/amatsuda/kaminari
