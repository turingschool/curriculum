---
layout: tutorial
title: Writing Better Views
---

# {{ page.title }}

The view layer is the most ignored part of our stack. We tend to think that the "real programming" happens at the model layer, the controllers are an inconvenience, and the views are just for designers.

That's just not true. We can add in components and techniques to the Rails stack that make the views more beautiful, functional, and easier to write. 

For this tutorial, we'll make use of a version of the JSBlogger sample application. Check out the repository, switch to the `better_views` branch, and move back to the `starter` tag:

```bash
dir
git clone git://github.com/jcasimir/rails_components.git
git checkout -b better_views origin/better_views
git checkout starter
git checkout -b my_better_views
```

## Understanding the View Stack

Before we dive into our views in depth, we need to have a common understanding of the request lifecycle and the view's responsibilities. Here's a typical Rails request:

![Rails MVC](https://github.com/jcasimir/jumpstartlab_tutorials/raw/master/images/rails_mvc.png)

The view receives data from the controller and prepares output for the user. The preparation step includes both formatting that data and combining it with view templates to generate the finished product. Let's look at templating first.

## Rails Templating with ERB and HAML

The "golden path" in Rails still uses *Embedded Ruby* or ERB. The template files live in `app/views/` and are named after the controller and action they're attached to.

### Reviewing ERB

In ERB we have three main markup elements:

* Plain HTML and text use no markers and just appear plainly on the page
* `<%=` and `%>` wrap Ruby code whose return value will be output in place of the marker
* `<%` and `%>` wrap Ruby code whose return value will *NOT* be output
* `<%-` and `%>` wrap Ruby code whose return value will *NOT* be output and no blank lines will be generated

The last of those, using `<%-`, has become much less significant as modern browsers restructure the DOM into a browsable tree where whitespace doesn't matter.

### Why Hate ERB?

The great thing about the ERB system itself is that it's totally generalized. In Rails applications we use it to create HTML files, but there's no reason we couldn't use ERB to output JavaScript, configuration files, or even form letters. ERB doesn't know anything about the surrounding text, it's just for injecting printing or non-printing Ruby code.

But that's a downside, too. ERB is very general, and a more specialized solution can help reduce our workload.

### Enter HAML

ERB vs. HAML has the fervor of a religious debate in the Rails community. According to surveys, about 46% of the community prefers HAML. Expert teams almost always prefer HAML except in situations where designers need to be completely "plug and play." Long story short, use HAML unless you have a strong reason not to.

### HAML Setup

Open the project's `Gemfile` and add this dependency:

```ruby
gem "haml"
```

Save it and run `bundle`

Once your dependencies are setup, start the server with `rails server`

### HAML Prototype

HAML was developed by Hampton Caitlin as pushback against the "heavy" nature of HTML and, by extension, XML. He started HAML by taking an ERB template and making one assumption: white space should be significant. With that assumption, he started deleting all the characters that could possibly be inferred by the template processor engine.

### A First Refactoring

Start by visiting http://127.0.0.1:3000/ and you'll see the article listing page for JSBlogger. Open the view template in `app/views/articles/index.html.erb`

On line 1 you'll see this H1:

```html
<h1>All Articles</h1>
```

It could have been written like this:

```html
<h1>
  All Articles
</h1>
```

And if we assume that whitespace is significant, the close tag would become unnecessary here. The parser could know that the H1 ends when there's an element at the same indentation level as the opening H1 tag. Cut the closing tag and we have:

```html
<h1
  All Articles
```

With the H1 tag itself, the `>` seem unnecessary. Leaving just `<h1` as the HTML marker could have worked, but Hampton decided that HTML elementes would be created with `%` like this:

```html
%h1
  All Articles
```

Lastly, when an HTML element just has one line of content, we'll conventionally put it on a single line:

```html
%h1 All Articles
```

Flip over to your browser, refresh the index page, and you'll see the plain `%h1 All Articles` output on the page. HAML is loaded, but it isn't parsing the document because it's still named `index.html.erb`

*Rename* the template to `index.html.haml` and refresh your page. Then you should get an error about illegal nesting. In your text editor, move all the lines so they're flush against the left edge, save, and refresh. The template should render without error, but it will look ridiculous.

### Outputting Ruby in HAML

On line 3 you should have:

```html
<p class='flash'><%= flash[:notice] %></p>
```

Given what you've seen from the H1, you would imagine the `<p></p>` becomes `%p`. But what about the Ruby injection?

HAML's approach is to reduce `<%= %>` to just `=`. The benefit is many fewer characters to type, but the cost is that with this syntax a single line must either be plain text or Ruby code -- no mixing.

```html
%p= flash[:notice]
```

Note that the `=` must be touching the `%p`

But what about the class? There are two options. The most robust syntax using the Ruby 1.9 hash style is like this:

```html
%p{class: 'flash'}= flash[:notice]
```

But when we just have a single class, we can also use a CSS-like syntax:

```html
%p.flash= flash[:notice]
```

I'd recommend the last one wherever possible.

### Mixing Plain Text and Ruby

Fix up the new article link yourself. It doesn't have an HTML tag, so just start the line with the `=`

The sidebar has a DIV with content and Ruby injection:

```ruby
<div id="sidebar">
Filter by Tag: <%= tag_links(Tag.all) %>
</div>
```

You'd be tempted to go this direction. Note that the ID is using a CSS-style syntax:

```ruby
%div#sidebar Filter by Tag: = tag_links(Tag.all)
```

But HAML won't recognize the Ruby code there. It'll just output the code as plain text. The traditional solution is to put the plain text and the Ruby on their own lines indented under the DIV:

```ruby
%div#sidebar
  Filter by Tag: 
  = tag_links(Tag.all)
```

Since HAML 3, though, there's an interpolation-like syntax for situations like this where you're mixing plain text and Ruby: 

```ruby
%div#sidebar
  Filter by Tag: #{tag_links(Tag.all)}
```

Now it can be pushed up to one line:

```ruby
%div#sidebar Filter by Tag: #{tag_links(Tag.all)}
```

And finally, DIV is considered the "default" HTML tag. If you just use a CSS-style ID or Class with no explicit HTML element, HAML will assume a DIV:

```ruby
#sidebar Filter by Tag: #{tag_links(Tag.all)}
```

### Non-Printing Ruby

Now you're left with the UL. The two challenges here are that you have some non-printing Ruby and elements within other elements.

On the outside, start the UL with `%ul#articles` and the other lines will all be indented two spaces below it. Delete its closing tag.

Next you have the `each` loop which uses non-printing Ruby lines. In HAML, these lines begin with a minus `-` like this:

```ruby
%ul#articles
  - @articles.each do |article|
  <li>
  <%= link_to article.title, article_path(article) %>
  <span class='tag_list'><%= article.tag_list %></span>
  <span class='actions'>
  <%= edit_icon(article) %>
  <%= delete_icon(article) %>
  </span>
  </li>
  - end
```

Refresh your browser and it'll show you an error -- the `end` is unnecessary in HAML. The same whitespace respect that simplifies HTML can simplify our Ruby! Delete the `- end` line, refresh, and your rendering will still break. All those lines formerly inside the `do` / `end` need to be indented two spaces inside the `do` line:

```ruby
%ul#articles
  - @articles.each do |article|
    <li>
    <%= link_to article.title, article_path(article) %>
    <span class='tag_list'><%= article.tag_list %></span>
    <span class='actions'>
    <%= edit_icon(article) %>
    <%= delete_icon(article) %>
    </span>
    </li>
```

Now your rendering should succeed.

### The Child Elements

* Convert the LI element to the HAML syntax, indent the content lines two spaces, and delete the closing tag.
* Change the `<%=` lines to just `=` and remove the closing tags.
* Rebuild the SPAN elements using the HAML style for the tag and the CSS class
* Make sure to indent the edit and delete icons so they live inside the actions SPAN

### Completed Template

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

### A Few Things to Try on Your Own

Try to rebuild the `show.html.erb` into `show.html.haml`. Remember you can push everything over to the left edge, allowing you to refactor it one element at a time. When you're struggling to represent the structure, try separating parts into their own lines, then reduce them down as you see fit.

## Utilizing Partials

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

As our application data grows we frequently need pagination. In Rails 2 everyone used a gem named `will_paginate` otherwise referred to as `mislav-will_paginate` from the brief time we built RubyGems directly off GitHub.

Rails 3 brought a totally new model architecture under the hood of ActiveRecord, and the way `will_paginate` hacked itself into the system doesn't fit anymore. Thankfully there's a new pagination library built from scratch for Rails 3 that fits in with the new ARel syntax.

Let's install Kaminari (<https://github.com/amatsuda/kaminari>) and use it to paginate our articles.

### Getting Started with Kaminari

Open the `Gemfile` and express the new dependency:

```ruby
gem 'kaminari'
```

Save it and run `bundle` from the project directory.

### Generating More Sample Data

The starter database has just five articles. To show off the pagination, let's generate more sample data. Open up `rails console` and run this code:

```ruby
80.times{ Fabricate(:article_with_comments) }
```

Now you should have at least 80 sample articles that we can break up into clean pages.

### Experimenting with Kaminari

There are methods available for handling pagination in the model, but I don't think that's appropriate separation of MVC concerns.

Instead, I'd prefer to handle the query setup in the controller. Let's open `app/controllers/articles_controller.rb`. We only need to paginate the `index`. Currently it reads:

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

Refresh the view and you should see the page links show up. There are additional options available to control how many page links are rendered, but I typically just use the defaults.

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