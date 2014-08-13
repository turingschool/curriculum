---
layout: page
title: Introduction to REST
---

## Big Picture

### History

* In 2000, Roy Fielding's doctoral thesis: http://www.ics.uci.edu/~fielding/pubs/dissertation/top.htm
* In 2007, Rails releases 2.0 with REST support: http://weblog.rubyonrails.org/2007/12/7/rails-2-0-it-s-done/
* Since 2007, most Rails apps strive for REST

### REST Uses More of HTTP

* GET - retrieve a resource
* POST - create a new resource
* DELETE - remove a resource
* PUT - update an existing resource in whole
* (PATCH) - update an existing resource in part

### Concepts of Resources

* A "resource" is typically a domain object
* A "resource" does not *necessarily* relate to a database table (ex: dashboard, session)
* Resources may be nested

## Applied in Rails

### Displaying a Single Resource

A `GET` with a resource identifier is used to display that resource. For instance:

```plain
GET http://example.com/articles/1
GET http://example.com/articles/1.json
```

In Rails this verb/path combo is mapped to the `show` action. The `show` action typically only accesses the parameter for the identifier (like `params[:id]`).

### Displaying Multiple Records

A `GET` request to the root of a resource should return a list of the resources, like this:

```plain
GET http://example.com/articles/
GET http://example.com/articles/2/comments/
```

These requests would be expected to return multiple records. In Rails, this verb/path combo triggers the `index` action.

The `index` action often does not need a parameter. But parameters can be used to display only a certain "page" of the results like this:

```plain
GET http://example.com/articles?page=2
```

Or parameters to `index` can search or filter the records:

```plain
GET http://example.com/articles?page=2&show_drafts=true
```

You should feel free to makeup whatever parameters you'd like for your `index` action, but keep in mind that:

* A) By the nature of `GET` requests, the parameters are embedded in the URL. The more parameters you have, the uglier your URLS.
* B) URL parameters are incredibly easy to modify, so (as always) expect that the user **will** modify them. Be cautious about SQL injection attacks here.

### Creating a Resource

The process of creating a record in a typical web application is three steps:

* 1) Display the form where the user enters the data
* 2) Process the data from that form to create the resource
* 3) Redirect the user

#### Displaying the Form

The fact that we typically dedicate a page/path to the form is not essential to the design of HTTP and REST, it's just convenient. Instead, we could choose to:

* A) Display the form on the listing (`index`) page
* B) Expect the user to formulate and submit their own `POST` request outside the browser (like we're building an API)

In a typical Rails app, we choose to display the form on it's own page using a URL pattern like this:

```plain
GET http://example.com/articles/new
GET http://example.com/articles/2/comments/new
```

Then the user fills in the form and clicks the submit button.

#### Processing the Form

For a new record, the form is setup to submit a request like this:

```plain
POST http://example.com/articles
POST http://example.com/articles/2/comments
```

That `POST` will include the data from the form in the body of the request. Unlike a `GET` action, they're not visible in the URL itself.

**However**, you must always keep in mind that the user could formulate and submit their own `POST` request *without* your form. So data coming is **untrusted**. *Assume* that the user can and will maliciously modify the data in that request.

Within Rails that `POST` request will get mapped to the `create` action. The `create` action typically makes significant use of the `params` which have been passed in from the request. Each form element will have it's own custom-named key in the hash returned by `params`. The key name is controlled by the markup you used in the HTML form.

For example, if your form ERB looked like this:

```erb
<%= form_for @article do |f| %>
  <% f.text_field :title %>
  <% f.text_area :body %>
<% end %>
```

Then when those parameters are received by the `create` action they'd be accessible by the following:

```ruby
params[:article][:title]
params[:article][:body]
```

When the `create` action completes, the convention is to redirect the user elsewhere. You might choose to send them to the listing/`index` page or the `show` for the resource they just created.

### Editing a Resource

Editing an existing resource follows a similar pattern to creating new resources.

* 1) Display the edit form
* 2) Process the data from that form to modify the resource
* 3) Redirect the user

#### Displaying the Form

In a typical Rails app, we display an edit form on its own page like this:

```plain
GET http://example.com/articles/1/edit
GET http://example.com/articles/2/comments/6/edit
```

Then the user fills in the form and clicks the submit button.

#### Processing the Form

When the user submits the form it'll generate a `PUT` request:

```plain
PUT http://example.com/articles/1
PUT http://example.com/articles/2/comments/6
```

The exact same processes and considerations from processing a `create` apply to processing this form data. You'll typically...

* Find the identifier from the URL (like `params[:id]`)
* Use that to find the existing record in your database
* Use the other parameters passed in (like `params[:article][:title]` and `params[:article][:body]`) to update the record
* Redirect the user someplace else

Typically applications will redirect the user to the `show` action for the resource that they just updated.

### Deleting a Resource

Delete requests look like:

```plain
DELETE http://example.com/articles/1
DELETE http://example.com/articles/2/comments/6
```

The router will map this verb/path combo to the `destroy` action in a Rails controller. The `destroy` action typically only pulls the `id` from the URL and removes that record from the system.

You might wonder, "why call the action `destroy` instead of just `delete`?" It's mainly for backwards compatibility -- Rails was using `destroy` to remove records before REST became a big thing.

## Quick Hits

### Search

One of the things that confuses developers new to REST is "how do I handle search?" You have three primary options:

#### Searching is a Filter

You can implement search as a "filter" on your index action, so you'd use URLs like this:

```plain
GET http://example.com/articles?author_id=6
```

To find all the articles by the author with identifier `6`.

#### Saved Searches

Option two is to promote the concept of search to a domain object. You display a search form and it submits a request like:

```plain
POST http://example.com/searches
```

Where the request body contains the various search parameters. 

*However*, don't just find the records and display them as a response to the `POST`. Since the `POST` parameters are invisible, the URL is not sharable or bookmark-able. Instead, you want to validate the parameters and redirect the user to a `show` page for that search like:

```plain
GET http://example.com/searches/12
```

Which would necessitate you storing the search parameters in your datastore/database so you could later find the search with `id` of `12`.

#### Cheating REST

If you don't want to store the search and don't like the filter appraoch, then you're left with cheating on the RESTful model with something like

```plain
GET http://example.com/search?looking_for=articles&author_id=6
```

While this can work just fine, it doesn't follow the concept of resources. Instead, you're using more of an Remote Procedure Call (RPC) style to call a `search` procedure.
