---
layout: tutorial
title: Writing Better Views
---

The view layer is the most ignored part of our stack. We tend to think that the "real programming" happens at the model layer, the controllers are an inconvenience, and the views are just for designers.

That's just not true. We can add in components and techniques to the Rails stack that make the views more beautiful, functional, and easier to write. 

Before we dive into our views in depth, we need to have a common understanding of the request lifecycle and the view's responsibilities. Here's a typical Rails request:

![Rails MVC](https://github.com/jcasimir/jumpstartlab_tutorials/raw/master/images/rails_mvc.png)

The view receives data from the controller and prepares output for the user. The preparation step includes both formatting that data and combining it with view templates to generate the finished product. Let's look at templating first.

## Rails Templating with ERB and HAML

### Background

The default templating language in Rails is *Embedded Ruby* or ERB. The template files live in `app/views/` and are named after the controller and action they're attached to. Everything you need to use ERB is already setup for you within Rails.

#### Reviewing ERB

In ERB we have three main markup elements:

* HTML and text use no markers and just appear plainly on the page
* `<%=` and `%>` wrap Ruby code whose return value will be output in place of the marker
* `<%` and `%>` wrap Ruby code whose return value will *NOT* be output
* `<%-` and `%>` wrap Ruby code whose return value will *NOT* be output and no blank lines will be generated

The last of those, using `<%-`, has become much less significant as modern browsers restructure the DOM into a browsable tree where whitespace doesn't matter.

#### Why Hate ERB?

The great thing about the ERB system itself is that it's totally generalized. In Rails applications we use it to create HTML files, but there's no reason we couldn't use ERB to output JavaScript, configuration files, form letters, or any other type of document. ERB doesn't know anything about the surrounding text, it just injects printing or non-printing Ruby code.

But that's a downside, too. ERB is very general, and a more specialized solution can help reduce our workload.

#### Enter HAML

ERB vs. HAML has the fervor of a religious debate in the Rails community. According to surveys, about 46% of the community prefers HAML. Expert teams almost always prefer HAML except in situations where designers need to be completely "plug and play." Long story short, use HAML unless you have a strong reason not to.

HAML was developed by Hampton Caitlin as pushback against the "heavy" nature of HTML and, by extension, ERB. He started HAML by taking an ERB template and making one assumption: white space will be significant. With that assumption, he started deleting all the characters that could possibly be inferred by the template processor engine.

### Developing HAML

In a typical template we'd have plain HTML like this:

```html
<h1>All Articles</h1>
```

Using whitespace to reflect the structure, we could reformat it like this:

```html
<h1>
  All Articles
</h1>
```

And if we assume that whitespace is significant, the close tag would become unnecessary here. The parser could know that the H1 ends when there's an element at the *same* indentation level as the opening H1 tag. Cut the closing tag and we have:

```html
<h1>
  All Articles
```

With the H1 tag itself, the `>` seem unnecessary. Leaving just `<h1` as the HTML marker could have worked, but Hampton decided that HTML elements would be created with `%` like this:

```html
%h1
  All Articles
```

Lastly, when an HTML element just has one line of content, we'll conventionally put it on a single line:

```html
%h1 All Articles
```

#### Outputting Ruby in HAML

With plain HTML dealt with, let's explore outputting Ruby within HAML. In ERB we might have:

```html
<p class='flash'><%= flash[:notice] %></p>
```

Given what you've seen from the H1, you would imagine the `<p></p>` becomes `%p`. But what about the Ruby injection?

HAML's approach is to reduce `<%= %>` to just `=`. The HAML engine assumes that if the content starts with an `=`, that the entire rest of the line is Ruby. For example, the flash paragraph above would be rewritten like this:

```html
%p= flash[:notice]
```

Note that the `=` must be touching the `%p`

But what about the class? There are two options. The verbose syntax is like this:

```html
%p{class: 'flash'}= flash[:notice]
```

But we can also use a CSS-like syntax:

```html
%p.flash= flash[:notice]
```

I'd recommend the last one wherever possible.

#### Mixing Plain Text and Ruby


Consider a chunk of content that has both plain text and Ruby like this:

```ruby
    <div id="sidebar">
    Filter by Tag: <%= tag_links(Tag.all) %>
    </div>
```

Given what we've seen so far, you might imagine it goes like this:

```ruby
%div#sidebar Filter by Tag: = tag_links(Tag.all)
```

But HAML won't recognize the Ruby code there. Since the element's content starts with plain text, it'll assume the whole line is plain text. One solution in HAML is to put the plain text and the Ruby on their own lines indented under the DIV:

```ruby
%div#sidebar
  Filter by Tag: 
  = tag_links(Tag.all)
```

Since version 3, though, HAML supports an interpolation-like syntax for mixing plain text and Ruby: 

```ruby
%div#sidebar
  Filter by Tag: #{tag_links(Tag.all)}
```

And it can be pushed up to one line:

```ruby
%div#sidebar Filter by Tag: #{tag_links(Tag.all)}
```

Finally, DIV is considered the "default" HTML tag. If you just use a CSS-style ID or Class with no explicit HTML element, HAML will assume a DIV:

```ruby
    #sidebar Filter by Tag: #{tag_links(Tag.all)}
```

#### Non-Printing Ruby

We've looked at plain text and HTML elements, injected printing Ruby, now let's focus on non-printing Ruby.

One of the most common uses of non-printing Ruby in a view template is iterating through a collection. In ERB we might have:

```ruby
<ul id='articles'>
  <% @articles.each do |article| %>
    <li><%= article.title %></li>
  <% end %>
</ul>
```

The second and fourth lines are non-printing because they omit the equals sign. HAML's done away with the `<%`, and content with no marker is interpreted as plain text. Therefore we need a new symbol to mark non-printing lines. In HAML, these lines begin with a minus `-` like this:

```ruby
%ul#articles
  - @articles.each do |article|
    %li= article.title
```

Wait a minute, what about the `end`? HAML uses that significant whitespace to reduce the syntax of HTML, and it applies that method to Ruby as well. The `end` for the `do` is not only unnecessary, it'll raise an exception if you try to use it!

#### Review

The key ideas of HAML include:

* Whitespace is significant, indent using two spaces
* HTML elements are created with `%` and the tag name, _ex:_ `%p`
* HTML elements can specify a CSS class (`%p.my_class`) or ID (`%p#my_id`) using a short-hand syntax
* Content starting with an `=` is interpreted as printing Ruby, _ex:_ `%p= article.title`
* Content starting with a `-` is interpreted as non-printing Ruby, _ex:_ `- @articles.each do |article|`
* Content can contain interpolation-style injections like `%p Articles Available:#{@articles.count}`

### Exercises

#### Fetch the Starter Code

For this tutorial, we'll make use of a version of the JSBlogger sample application. Check out the repository, switch to the `better_views` branch, and move back to the `starter` tag:

```bash
git clone git://github.com/jcasimir/rails_components.git
git checkout -b better_views origin/better_views
git checkout starter
git checkout -b my_better_views
```

Start by visiting http://127.0.0.1:3000/ and you'll see the article listing page for JSBlogger.

#### Add the HAML Dependency

Open the project's `Gemfile` and add this dependency:

```ruby
gem "haml"
```

Save it and run `bundle`

Once your dependencies are setup, start the server with `rails server`


#### Basic Refactorings

Following the examples above, complete each of these steps:

* Open the view template in `app/views/articles/index.html.erb`
* Rename the template to `index.html.haml` to trigger HAML parsing
* Cut everything except the H1 to a temporary file so you can bring back one chunk at a time and rewrite it in HAML
* Rewrite the H1 using HAML syntax for plain text
* Rewrite the flash using HAML syntax for printing Ruby
* Output the New Article link without a containing HTML element
* Rebuild the Sidebar using the HAML interpolation syntax to mix plain text and Ruby on one line

#### Deep Nesting

You've worked through the basics, now combine the techniques to rebuild the Articles UL.

* Convert the UL to HAML and indent child elements two spaces
* Rewrite the loop to use HAML's non-printing Ruby syntax
* Change the LI to use a HAML content tag
* Rewrite the child elements using printing Ruby and interpolation as you see fit
* Review the generated HTML to make sure the nesting relationships are preserved!

#### Extensions on Your Own

Rebuild the `show.html.erb` into `show.html.haml`. When you're struggling to represent the structure, try separating parts into their own lines, then reduce them down as you see fit.

#### Completed `index.html.haml` Template

```ruby
    %h1 All Articles

    %p.flash= flash[:notice]

    = link_to "New Article", new_article_path, :class => 'new_article'

    #sidebar Filter by Tag: #{tag_links(Tag.all)}

    %ul#articles
      - @articles.each do |article|
        %li
          = link_to article.title, article_path(article)
          %span.tag_list= article.tag_list
          %span.actions
            = edit_icon(article)
            = delete_icon(article)
```

## Utilizing View Partials

When we write Ruby code a method should be capped at about 8 lines by breaking functionality into encapsulated methods. When writing view templates, partials are the means of encapsulating view components.

### Simple Partials

Open `views/articles/show.html.haml` and look for the H3 starting the comments section. That line and everything below it is about comments. It's related to the article, but not intrinsic to *showing* and article. It's a perfect candidate for a simple partial extraction.

Create `views/articles/_comments.html.haml` and move everything from the H3 down into that file. Save both files, look at an article's `show` in the browser, and the comments should vanish.

Now to render the partial we utilize the `render` method. At the bottom of `show.html.haml`, add:

```ruby
= render :partial => 'comments'
```

Refresh your browser and the comments will be back. 

### Relocating Partials

By default `render` looked in the same directory as the view template, in this case `app/views/articles`.

Let's imagine that, as this application grows, we want to reuse the comment partial on other pages. Maybe our user can post images that aren't articles. We'd like readers to be able to comment on them too! We can build in that flexibility now.

Create a directory `app/views/common` and move the `_comments.html.haml` into it.

Go to a `show` page in your browser, and it'll crash because it can't find the partial `app/views/articles/_comments.html.haml`

Open `app/views/articles/show.html.haml` and change this:

```ruby
= render :partial => 'comments', :locals => {:article => @article}
```

to this:

```ruby
= render :partial => 'common/comments', :locals => {:article => @article}
```

When render sees a `/` in the partial name, it interprets the first part as the folder name and the second as the file name.

To make it truly reusable, we should edit the partial to refer to a local variable named `subject` then, when rendering it, pass in `:subject => @article`.

If you're wondering, you can nest folders of partials like `common/commentable/comments`, but I generally wouldn't recommend it. The folder structure is nested enough as it is!

### Dealing with Scope & Local Variables

The parent view template and the partial exist in different scopes -- they don't share local variables. In this case they both have access to the `@article` instance variable. But to make our partial more reusable, we shouldn't have it rely on an instance variable. Instead we can pass in a local variable.

Start by editing `_comments.html.haml` to reference the local `article` instead of `@article`. Refresh the view in your browser and it'll crash looking for the local variable.

Now go over to the `render` call and add on the `locals` option like this:

```ruby
= render :partial => 'comments', :locals => {:article => @article}
```

If you pass in a hash to `locals`, render will create a local variable for each key in the hash with the value specified. Refresh your view and it'll work.

### Rendering Collections

The `render` method is incredibly overloaded. Let's see how it can work with collections of objects. Open `views/articles/index.html.haml`.

See the `@article.each` line? Whenever we have an iteration loop in a view template it's a candidate for extraction to a collection partial. Cut the `%li` and everything beneath it and paste it into `app/views/articles/_article_item.html.haml`. Then delete the `- @articles.each` line.

Refresh your index page and the articles will disappear. Delete the 

We want to render the LIs inside the `%ul#articles`, let's try it in one line:

```ruby
%ul#articles= render :partial => 'article_item'
```

That's a good start, but we don't want to render it *once*, we need to render it *once for each article*. Add the `:collection` parameter like this:

```ruby
%ul#articles= render :partial => 'article_item', :collection => @articles
```

Refresh your browser and it still crashes. The partial is looking for a variable named `article` but can't find one. When you call `render` using a collection, it will process the partial once for each element of the collection. While the partial is being rendered, Rails will provide the element being rendered and store it into a local variable *based on the filename of the partial*.

So in this case, our `_article_item.html.haml` partial will have a local variable named `article_item`.

To make our view work, we have two options.

1. Open the partial and change all references from `article` to `article_item` to match the filename.
2. Rename the partial to `_article.html.haml` so it'll have a local `article` variable.

I'd recommend the second option where possible. Implement that now. Then update the `render` call:

```ruby
%ul#articles= render :partial => 'article', :collection => @articles
```

Refresh your browser and the view should display correctly.

### Magical Partial Selection

When we first rendered the comments partial, you might have been thinking that instead of:

```ruby
= render :partial => 'comments'
```

We could have just written this:

```ruby
= render 'comments'
```

And that's true. If you give `render` a string it will attempt to render a partial with that name. But due to implementation details of the method, you *cannot* leave off the `:partial` but still use `:locals` like this:

```ruby
= render 'comments', :locals => {:article => @article}
```

Nor can you leave off `:partial` when rendering a collection. This *will not work*:

```ruby
%ul#articles= render 'article', :collection => @articles
```

But there is a shortened syntax that *will* work. You can do this:

```ruby
%ul#articles= render @articles
```

`render` accepts an object or a collection of objects. It will iterate through the objects and call the `.class_name` method on each one, convert the class name to `snake_case`, then render a partial with that name and the object sent in as a local variable named after the file.

Complicated? Yes. Magical? Yes. Cool? I think so. `render @articles` will, basically, render the `_article.html.haml` partial once for each article in `@articles`.

### Closing Words on View Partials

A few last thoughts on view partials:

* For consistency, I always write `render :partial => x` and `render :partial => x, :collection => y`
* I use an `app/views/common` folder on every project to hold reusable partials
* I won't nest partials more than two levels deep. 
  Example:
  * `show.html.haml` can render `_comments.html.haml`
  * `_comments.html.haml` can render `_comment_form.html.haml`
  * I wouldn't let `_comment_form.html.haml` render `_comment_form_elements.html.haml` because it gets too difficult to understand the structure
  
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

Kaminari adds two important methods that we can mix into ActiveRelation queries. The first is `per` which specifies how many objects should appear on each page:

```
@articles = Article.scoped.per(5)
```

Then we can add the `page` method to specify which page we want:

```
@articles = Article.scoped.per(5).page(2)
```

Or, more commonly, feed that page in from `params`:

```
@articles = Article.scoped.per(5).page(params[:page])
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