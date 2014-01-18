---
layout: page
title: Static Pages
section: Blogger
---

Blogs often have more than Articles. They often have a page or pages dedicated
to static content. Pages that give a summary of the blog (e.g. "about") or more
information about the author (e.g. "author"). This is familar to most people
that may have used popular blogging platforms like Wordpress.

The goal of this tutorial is to add these "static pages" to an existing blog.

<div class="note">
<p>This tutorial is open source. Please contribute fixes or additions to <a href="https://github.com/JumpstartLab/curriculum/blob/master/source/topics/blogger/static_pages.markdown">the markdown source on GitHub.</a></p>
</div>

{% include custom/sample_project_advanced.html %}

## I0: Adding the Pages Resources

A static page on our blog is much like an article. A page should have at
least a title and a body and we need to be able to create, show, update and
delete them.

### Generating Scaffolding

So we use rails scaffold generator to do most of the hard work in creating all
our model, controller, and views.

{% terminal %}
$ rails g scaffold page title:string body:text
$ rake db:migrate
$ rails server
{% endterminal %}

### Creating an About Page

The most common static page on blogs that I have seen are ones that tell a story
about the author and the reason for the blog. They often call it the **about**
page. Let's create a similar about page.

* Visit **http://localhost:3000/pages**
* Create a new page with the title "About" and a body filled with a little story
  that would help people get to know you.
* View your new about page that you created **http://localhost:3000/pages/1**

### Fixing the Style of Our Pages

Our **about** page is created but it does not fit in with the rest of our blog.
Ideally it would look more like an article page. So let's apply a similar
formatting that we used on our articles' show page.

* Open `app/views/pages/show.html.erb` and change it to the following:

```erb
<h1><%= @page.title %></h1>

<p><%= @page.body %></p>
```

* Visit **http://localhost:3000/pages/1** or refresh the page in your browser.

### Adding Our Pages to the Articles Index

Our "About" page is complete and now we need to add it to our articles index
page to make sure people that visit our blog are able to learn more about us.

* Open `app/controllers/articles_controller.rb` and update the index action:

```ruby
class ArticlesController < ApplicationController

  # ... other actions ...

  def index
    @articles, @tag = Article.search_by_tag_name(params[:tag])
    @pages = Page.all
  end

  # ... other actions ...

end
```

* Open `app/views/articles/index.html.erb` and update the sidebar to include links
  to our pages:

```erb
<div id="sidebar">
  <div>
    <% @pages.each do |page| %>
      <%= link_to page.title, page_path(page) %><br/>
    <% end %>
  </div>
</div>
```

## I1: Pages with a Better URL

Our page visually is not going to win any awards but it is definitely passable.
Instead of spending focused on the layout we want to spend some time on making
the url itself more attractive to potential users. The format of the url itself
is important and often times a page itself will be judged on it.

Currently our **about** page is named "/pages/1" which if we shared with a
person they might disregard it. It would be great if we could have a page
named "/pages/about".

In the blogging world, using a more descriptive, human-readable value to
represent the id of the page is often times referred to as a
[slug](http://en.wikipedia.org/wiki/Slug_\(web_publishing\)#Slug).

### Implementing our Page Slug

Each page should have it's own slug. So lets add a new slug field to our pages
table and thus our `Page` model.

* Create a migration

{% terminal %}
$ rails g migration AddSlugToPages
  invoke  active_record
  create    db/migrate/20130722220739_add_slug_to_pages.rb
{% endterminal %}

* Open `db/migrate/TIMESTAMP_add_slug_to_pages.rb`

```ruby
class AddSlugToPages < ActiveRecord::Migration
  def change
    add_column :pages, :slug, :string
  end
end
```

Then go to your terminal and run `rake db:migrate`

* Open `app/models/page.rb` and update our page model to allow the
  `slug` attribute to be accessible (allowing it to be assigned
  through the controller):

```ruby
class Page < ActiveRecord::Base
  attr_accessible :body, :title, :slug
end
```

* Open `app/views/pages/_form.html.erb` and add the new slug field to the form:

```erb
  <div class="field">
    <%= f.label :slug %><br />
    <%= f.text_field :slug %>
  </div>
```

* Edit our existing about page to add the slug "about".

We now have a slug but we need to now use it by default throughout our entire
application. First, we need to change the way that the page is represented when
a link is created. Second, we need to change the default way we find our pages.

### Finding Pages by Their Slug

By default when we use our path and url helpers we pass an object as a parameter.

```ruby
page_path(@page)
```

When creating a url these helpers ask the model to return the value of its
`to_param` function. Looking at our `Page` model we do not have any method
defined named `to_param`. However, because we are a child class of
`ActiveRecord::Base` we already have a default `to_param` method which returns
our id. So we need to define a new `to_param` method and return our new slug.

* Open `app/models/page.rb` and update our page model:

```ruby
class Page < ActiveRecord::Base
  attr_accessible :body, :title, :slug

  def to_param
    slug
  end
end
```

* Visit **http://localhost:3000/pages** and click on "Show" for our about page

Currently when we attempt to visit our application shows us an error.
We changed the way our urls are defined, but still need to change the way that
we find our pages.

For instance, in `app/controllers/pages_controller.rb` our show action uses the
`Page` model to find based on the parameter specified:

```ruby
def show
  @page = Page.find(params[:id])

  respond_to do |format|
    format.html # show.html.erb
    format.json { render json: @page }
  end
end
```

A model's `find` method by default is searching the databaes by the id. We could
change that to instead search by **slug**.

```ruby
def show
  @page = Page.find_by_slug(params[:id])

  respond_to do |format|
    format.html # show.html.erb
    format.json { render json: @page }
  end
end
```

This is not the only time we use `Page.find(params[:id])` within our controller.
We would need to change all four times we wrote this in our controller.

Making these four changes are rather trivial. The problem is that later we will
have to remember to always use `find_by_slug` instead of `find`. A more ideal
situation in this case is to change the default way that we find pages.

### Changing the Default Way We Find Pages

We wish our find method used the slug instead of the id. Similar to how we
overrode the `to_param` method we can do the same for the find method.

`ActiveRecord::Base` models define a **class method** named `find` which takes an
id parameter. We want to re-define this **class method** to instead take the
parameter and search for a page based on the slug (i.e. `find_by_slug`).

* Open `app/models/page.rb` and update our page model:

```ruby
class Page < ActiveRecord::Base
  attr_accessible :body, :title, :slug

  def self.find(slug)
    find_by_slug(slug)
  end

  def to_param
    slug
  end
end
```

* Visit **http://localhost:3000/pages/about**

## I2: Pages with an Even Better URL

<div class="note">
<p>This portion of the tutorial is under construction.</p>
</div>

Our "about" page url, "/pages/about", is much better. Visitors of our site and
people that share the link to our pages will have more confidence about the
content on the page.

We could make our url even simplier for potential visitors. Why should our
"about" page url contain the "/pages" url prefix. Why couldn't a user type in
"/about" and be shown the about page.

* Open `config/routes.rb` and add the following line **after the last route**:

```ruby
JsbloggerCodemash::Application.routes.draw do

  # ... all other routes ...

  get '/:id' => 'pages#show'

end
```

## I3: Managing What Pages to Show

<div class="note">
<p>This portion of the tutorial is under construction.</p>
</div>

It is great that we can now create all these static pages and include them on
our index page. However, we have no control over the order of the pages and
we may decide in the future that we want to show or hide different pages based
on different criteria. The only way we currently can accomplish this is by
deleting and re-creating all of our pages any time we would like to re-order
them.

* Allow the ability to hide / show pages
* Allow the ability to order pages

## I4: Providing an Alternative Layout

<div class="note">
<p>This portion of the tutorial is under construction.</p>
</div>

It would be great if we could define some special HTML within the body of our
static pages. Having that flexibility would allow us to let those pages be
more expressive by providing links to other pages within our blog or to our
profiles on various other social networks.

* Allow a page to contain HTML in the body.
* Allow a page to contain markdown in the body.
