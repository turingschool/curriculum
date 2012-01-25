---
layout: page
title: Utilizing View Partials
section: Better Views
---

When writing Ruby we break up complex methods into multiple, smaller methods. When writing view templates, partials are the means of encapsulating view components.

### Setup

{% include custom/sample_project_advanced.html %}

## Simple Partials

Open `views/articles/show.html.haml` and look for the H3 that starts the comments section. The H3 line and everything below it are about comments. They are related to the article, but are not intrinsic to *showing* an article. They are a perfect candidate for a simple partial extraction.

We create partials by adding a file to the views folder and beginning the filename with an underscore.

As an example, create `views/articles/_comments.html.haml` and move the H3 and everything below it into that file. Save both files and look at an article's `show` in the browser. The comments should vanish.

Now, to render the partial we utilize the `render` method. At the bottom of `show.html.haml`, add:

```haml
= render :partial => 'comments'
```

Refresh your browser and the comments will be back. 

## Relocating Partials

`render`, by default, looks for the partial in the same directory as the current view template. In this case, that means `app/views/articles`.

Let's imagine that, as this application grows, we want to reuse the comment partial on other pages. Maybe our user can post images that are not articles. We would like readers to be able to comment on them, too! We can build in that flexibility now.

Create a directory `app/views/common` and move the `_comments.html.haml` into it.

Go to an article's `show` page in your browser, and it will crash because it cannot find the partial `app/views/articles/_comments.html.haml`

Open `app/views/articles/show.html.haml` and change this:

```haml
= render :partial => 'comments'
```

to this:

```haml
= render :partial => 'common/comments'
```

When render sees a `/` in the partial name, it interprets the first part as the folder name and the second as the file name.

### Passing In a Variable

Sending variables into a partial is a little tricky.

To see how it works, first go into your partial and change all references from `@article` to the local variable `article`. The rendering will now break because it doesn't have a local variable named `article`.

Then, in the `show` template, modify the `render` call to this:

```haml
= render :partial => 'common/comments', :locals => {:article => @article}
```

The `locals` option takes a hash. Each key will be setup as a local variable and the value stored into the variable. So, in the context of the partial, we'll now have an `article` variable holding `@article`.

Refresh the `show` page in your browser and it should render correctly.

To make the partial truly reusable, we should edit it to refer to a local variable named `subject` then, when rendering it, pass in `:subject => @article`.

## Rendering Collections

The `render` method is incredibly overloaded. Let's see how it can work with collections of objects. Open `views/articles/index.html.haml`.

See the `@article.each` line? Whenever we have an iteration loop in a view template, it is a candidate for extraction to a collection partial. 

To see how it works:

* Cut the `%li` and everything beneath it to your clipboard
* Delete the `- @articles.each` line
* Create a file `app/views/articles/_article_item.html.haml` and paste it in

Refresh your index page and the articles will disappear.

We want to render the LIs inside the `%ul#articles`. Let's try it in one line:

```haml
%ul#articles= render :partial => 'article_item'
```

That's a good start, but we don't want to render it *once*, we need to render it *once for each article*. Add the `:collection` parameter like this:

```haml
%ul#articles= render :partial => 'article_item', :collection => @articles
```

Refresh your browser and it still crashes. The partial is looking for a variable named `article` but can't find one. 

When you call `render` using a collection, it will process the partial once for each element of the collection. While the partial is being rendered, Rails will provide the element being rendered and store it into a local variable *based on the filename of the partial*.

So in this case, our `_article_item.html.haml` partial will have a local variable named `article_item`.

To make our view work, we have two options.

1. Open the partial and change all references from `article` to `article_item` to match the filename.
2. Rename the partial to `_article.html.haml` so it'll have a local `article` variable.

Implement the second option, renaming the file. Then update the `render` call like this:

```haml
%ul#articles= render :partial => 'article', :collection => @articles
```

Refresh your browser and the view should display correctly.

## Magical Partial Selection

When we first rendered the comments partial, you might have known that instead of:

```haml
= render :partial => 'comments'
```

We could have just written this:

```haml
= render 'comments'
```

If you give `render` a string, it will attempt to render a partial with that name. But, due to implementation details of the `render` method, you *cannot* leave off the `:partial` and still use `:locals`:

```haml
= render 'comments', :locals => {:article => @article}
```

Nor can you leave off `:partial` when rendering a collection. This *will not work*:

```haml
%ul#articles= render 'article', :collection => @articles
```

There is a shortened syntax that *will* work. You can do this:

```haml
%ul#articles= render @articles
```

`render` accepts an object or a collection of objects. `render` will iterate through the objects and call the `.class_name` method on each one, convert the class name to `snake_case`, and will render a partial with that name. The individual object sent will still be named after the partial.

`render @articles` will render the `_article.html.haml` partial once for each article in `@articles`, assigning each one to the local variable `article`.

## Closing Words on View Partials

A few last thoughts on view partials:

* For consistency, use the syntax `render :partial => x` and `render :partial => x, :collection => y`
* An `app/views/common` folder is helpful on most projects to hold reusable partials
* Generally, don't next partials more than two levels deep: 
  Example:
  * `show.html.haml` can render `_comments.html.haml`
  * `_comments.html.haml` can render `_comment_form.html.haml`
  * Don't make `_comment_form.html.haml` render `_comment_form_elements.html.haml`, otherwise it gets too difficult to understand the template structure
