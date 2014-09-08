---
layout: page
title: Multi-Tenant Applications
---

<div class="note">
<p>This tutorial is a work in progress. It contains notes and a rough outline for a future tutorial.</p>
</div>

Is this alternate universe our blogger application is successful and the Open Source community is clamoring for new features. The feature with the greatest appeal is for blogger to go commercial by providing the ability to turn a single blog into a blogging platform.

* Provide unique URLs prefixes for each of the blogs
* Limit posts to a particular blog or blogs
* Limit authors ability to manage posts to particular blog or blogs
* Provide unique styles for each of the blogs with a sensible default style

<div class="note">
<p>This tutorial is open source. Please contribute fixes or additions to <a href="https://github.com/JumpstartLab/curriculum/blob/master/source/topics/decorators.markdown">the markdown source on GitHub.</a></p>
</div>

### Setup

{% terminal %}
$ git clone git://github.com/gsbhool/rails-testing.git multi-tenant-blogger
$ cd multi-tenant-blogger
$ bundle
$ bundle exec rake db:setup
{% endterminal %}

## Routing in a multi-tenat world

We want each of our blogs to be top-level sub-domains.

    /dancing-with-the-stars
    /the-kardashians
    /vampire-diaries

From what we know about Rails resource-based routing, we're not sure how to
create the url format we are after. So instead of getting stuck, lets work
with a url format we know works.

    /blogs/dancing-with-the-stars
    /blogs/the-kardashians
    /blogs/vampire-diaries

That is a more familar format pattern. One that we have experience
implementing.

* Generate scaffolding for a blog:

{% terminal %}
$ rails generate scaffold blog name:string path:string
{% endterminal %}

* Create three new blogs that we want to host.

The problem with our new blogs is that they are available at the less than
memorable urls.

    /blogs/1
    /blogs/2
    /blogs/3

When we visit **/blogs/dancing-with-the-stars** we want to find the blog.
This work is done solely through the `BlogsController#show`.

* Update `BlogsController#show` action to find the blog by path (e.g. `find_by_path`) and not by id (e.g. `find`).


* When we visit "/blogs/SHOWNAME" we want to show all the articles

We want a blog to have many articles and conversly an article to belong to
many blogs.

> **Why would an article exist on many blogs and not just one blog?**
>
> It may make sense in some Rails applications to define relationships
> this way. Imagine that one special episode of "Dancing With the Stars"
> has a special guest appearance from one of the stars from "Vampire
> Diaries". The article we write could exist on both of our blogs.

* Generate a model `BlogArticle`:

{% terminal %}
$ rails generate model BlogArticle blog:references article:references
$ rake db:migrate
{% endterminal %}

* Update the relationships within the `Blog` model and `Article` model.

```ruby
class Blog < ActiveRecord::Base
  # ...
  has_many :blog_articles
  has_many :articles, through: :blog_articles
end
```

```ruby
class Article < ActiveRecord::Base
  # ...
  has_many :blog_articles
  has_many :blogs, through: :blog_articles
end
```

Within `BlogsController#show` we need to now find all the articles
specific to this blog and then display an index of them. This means we
would be duplicating the work of the `ArticlesController#index`.

We should stop our implementation. Instead of duplicating all the work
in our Articles controller, we should instead be routing to our `ArticlesController#index`.

How do we do that?

We need to override our show route within our resource and specify the
`ArticlesController#index` to handle the action.

```ruby
resources :blogs do
  match "/" => "articles#index"
end
```

Now when you visit `http://localhost:3000/blogs/SHOWNAME` you are
no longer taken to the `BlogsController#show`.

However, right now all we are seeing is a list of all articles across
the whole site. This is where the hard work begins as we will need to
update all of our `ArticlesController` actions and views to take into
account the new blog association.

We also cannot stop simply with the initial re-direct we need to define
the nested resource that we have now defined with our routes.

```ruby
resources :blogs do
  match "/" => "articles#index"

  resources :articles do
    resources :comments
  end
end
```

Converting the `ArticlesController` to now be a nested resource of the
blogs requires the following steps:

* Remove the existing resources within the **routes.rb** file
* Update all `ArticlesController` actions to have the articles scoped
  through the current blog that they are being viewed. A controller
  helper method would be useful to load the blog based on the blog id
* Update all the link helpers that were previously generated (i.e. `blog_articles_path`, `blog_article_path(current_blog,@article)`).

By default replacing all the helper methods is not extremely painful. It
is a little ugly when you look at the paths that do get generated. An
example:

```ruby
blog_articles_path(current_blog)
```

This will generate the path */1/articles*. What we had hoped for was to
generate */SHOWPATH/articles*. We can accomplish that by giving the path
helper the path instead of the entire object

```ruby
blog_articles_path(current_blog.path)
```

In one instance this is fine, however, we will need to repeat this pattern
every time we use the helper. Fortunately we can save ourselves the work
and add a single method to our `Blog` model that will make this the default:

```ruby
class Blog < ActiveRecord::Base
  attr_accessible :name, :path
  has_many :blog_articles
  has_many :articles, through: :blog_articles

  def to_param
    path
  end
end
```

* Update the forms so that they accept the form (i.e. `form_for [current_blog,@article])


<hr/>
... Time Passes ...
<hr/>

With all that work done it is time to get the routes looking like what
we wanted to create. That is done similarly to how we did the resources
except we want to use a scope.

```ruby

resources :blogs

scope "/:blog_id" do
  match "/" => "articles#index", as: "home"

  resources :articles do
    resources :comments, only: [ :create ]
  end
end
```

The scoped route and the resources routes looks very similar. In face, they
should not act at all different from your normal routes, you simply are
able to access them at a top-level. This is assuming that another route
does not supercede them (e.g. */blogs* will still be handled as normal
not treated as a blog name). Remember the order within your **routes.rb**
file is important. Routes which are more flexible need to be placed at
the bottom so they do not override existing valid routes.
