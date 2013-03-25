---
layout: page
title: REST Fundamentals
sidebar: true
---

## Before REST

Before REST, there was RPC (Remote Procedure Call), or CRUD (Create/Read/Update/Delete) in Rails.

RPC means, basically, there are no rules or guidelines. Construct whatever URLs you think sound good at the time. For example:

* `/articles/new` or `/articles/write` ?
* `/articles/create` or `/articles/save` ?
* `/articles/1/edit` or `/articles/edit/1` ?
* `/articles/1/destroy` or `/articles/destroy_article&id=1`?

## Introduction to REST

### Respect for Verbs

* The growth of web applications as an industry
* Defined HTTP Verbs: 
  * `GET` - retrieve data
  * `POST` - add new data
  * `PUT` - modify data
  * `DELETE` - delete data
* `GET` and `POST` used recklessly
* Google Web Accelerator

### Roy Fielding

[Dissertation featuring REST by Fielding](http://www.ics.uci.edu/~fielding/pubs/dissertation/rest_arch_style.htm), 2000.

### Key Terms

* `resource`: the "intended conceptual target", aka the *nouns* or actors in the business domain.
* `resource identifier`: the URL used to reach the resource
* `representation`: the response to the user in a given format, like HTML or JSON

### Argument

Applications should be constructed as `resources` with one or more `representations`. Using a small number of URLs in combination with several HTTP verbs, we can fully manipulate these resources.

## REST in Rails

There is a lot of debate about Rails' implementation of REST. Consider it an incomplete implementation that's good enough, but not perfect.

### URL Structure + Verb

Typical Rails RESTful routes make use of the HTTP verb and a URL:

* `GET /articles` would fetch the list of all articles
* `GET /articles/1` would fetch the single article with ID of 1
* `POST /articles` would create a new article
* `DELETE /articles/1` would delete the article with ID of 1

What about editing? The Rails standard is to use:

* `GET /articles/1/edit` to fetch the edit form
* `PUT /articles/1` would update the data for existing article with ID of 1

The `/edit` url is really an RPC-style URL, but there isn't an easy replacement with better REST style.

### CRUD Actions

Inside Rails, these routes are translated to controller actions. The typical actions are:

* `new`: display the form for entering data about a new object
* `create`: actually create the object from the form
* `edit`: display the form for modifying data about an existing object
* `update`: actually modify the data about an existing object
* `destroy`: remove an object from the system
* `index`: list the available objects
* `show`: display a representation of the object

### Multiple Representations

A single Rails controller action can represent the same object in multiple formats if you so choose. The most common are:

* HTML
* JSON
* XML

## RESTful Routing

### Experimentation Notes

While experimenting with routes, you can use `rake routes` from the application directory to display a table of the defined routes.

To try out the "route helpers", load `rails console` and call them on the `app` object like this:

{% irb %}
> app.article_path(1)
=> "/articles/1" 
{% endirb %}

### `resources`

The most common routing method, `resources`, represents a collection of a given noun in the system. In the router:

```ruby
resources :articles
```

#### Routing Table

Generates the following routes:

{% terminal %}
$ bundle exec rake routes
    articles GET    /articles(.:format)          articles#index
             POST   /articles(.:format)          articles#create
 new_article GET    /articles/new(.:format)      articles#new
edit_article GET    /articles/:id/edit(.:format) articles#edit
     article GET    /articles/:id(.:format)      articles#show
             PUT    /articles/:id(.:format)      articles#update
             DELETE /articles/:id(.:format)      articles#destroy
{% endterminal %}

Note that the folder is `articles` and there is an `index` action because they are a collection.

#### In Rails Console

{% irb %}
> app.articles_path
 => "/articles" 
> app.article_path(1)
 => "/articles/1" 
> app.edit_article_path(2)
 => "/articles/2/edit" 
{% endirb %}

### `resource`

Often appropriate but too-rarely used, the `resource` method is useful when there's only one of a given thing:

```ruby
resource :dashboard
```

#### Routing Table

{% terminal %}
$ bundle exec rake routes
     dashboard POST   /dashboard(.:format)      dashboards#create
 new_dashboard GET    /dashboard/new(.:format)  dashboards#new
edit_dashboard GET    /dashboard/edit(.:format) dashboards#edit
               GET    /dashboard(.:format)      dashboards#show
               PUT    /dashboard(.:format)      dashboards#update
               DELETE /dashboard(.:format)      dashboards#destroy
{% endterminal %}

The generated paths do not use an `:id` because there is only one resource. There's also no `index` action.

#### In Rails Console

{% irb %}
> app.dashboard_path
 => "/dashboard" 
> app.edit_dashboard_path
 => "/dashboard/edit" 
{% endirb %}

### Nested Resources

Nested resources express a hierarchy of belonging

```ruby
resources :articles do
  resources :comments
end
```

This is useful when the child resource is useful only in the context of the parent. Like a comment for an article, a page from a book, etc.

#### Routing Table

{% terminal %}
$ bundle exec rake routes
    article_comments GET    /articles/:article_id/comments(.:format)          comments#index
                     POST   /articles/:article_id/comments(.:format)          comments#create
 new_article_comment GET    /articles/:article_id/comments/new(.:format)      comments#new
edit_article_comment GET    /articles/:article_id/comments/:id/edit(.:format) comments#edit
     article_comment GET    /articles/:article_id/comments/:id(.:format)      comments#show
                     PUT    /articles/:article_id/comments/:id(.:format)      comments#update
                     DELETE /articles/:article_id/comments/:id(.:format)      comments#destroy
            articles GET    /articles(.:format)                               articles#index
                     POST   /articles(.:format)                               articles#create
         new_article GET    /articles/new(.:format)                           articles#new
        edit_article GET    /articles/:id/edit(.:format)                      articles#edit
             article GET    /articles/:id(.:format)                           articles#show
                     PUT    /articles/:id(.:format)                           articles#update
                     DELETE /articles/:id(.:format)                           articles#destroy
{% endterminal %}

Notice the nested paths like `/articles/:article_id/comments/:id`. To generate URLs with both IDs you'd need to pass both into the path helper:

```ruby
edit_article_comment_path(article_id, comment_path)
```

#### In Rails Console

{% irb %}
> app.dashboard_path
 => "/dashboard" 
> app.edit_dashboard_path
 => "/dashboard/edit" 
> app.article_path(1)
 => "/articles/1" 
> app.article_comments_path(1)
 => "/articles/1/comments" 
> app.article_comment_path(1, 5)
 => "/articles/1/comments/5" 
> app.edit_article_comment_path(1, 5)
 => "/articles/1/comments/5/edit"
{% endirb %}

### Other Routing Techniques

* Limiting the available verbs with `:only` or `:except`
* Adding custom actions
* Namespacing

