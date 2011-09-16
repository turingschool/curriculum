## Utilizing View Partials

When we write Ruby code, a method should be capped at about 8 lines by breaking functionality into encapsulated methods. When writing view templates, partials are the means of encapsulating view components.

### Simple Partials

Open `views/articles/show.html.haml` and look for the H3 that starts the comments section. The H3 line and everything below it are about comments. They are related to the article, but are not intrinsic to *showing* an article. They are a perfect candidate for a simple partial extraction.

Create `views/articles/_comments.html.haml` and move everything from the H3 line and below into that file. Save both files and look at an article's `show` in the browser. The comments should vanish.

Now, to render the partial we utilize the `render` method. At the bottom of `show.html.haml`, add:

```haml
= render :partial => 'comments'
```

Refresh your browser and the comments will be back. 

### Relocating Partials

`render` looks in the same directory as the view template by default. In this case, `render` looks in `app/views/articles`.

Let's imagine that, as this application grows, we will want to reuse the comment partial on other pages. Maybe our user can post images that are not articles. We would like readers to be able to comment on them, too! We can build in that flexibility now.

Create a directory `app/views/common` and move the `_comments.html.haml` into it.

Go to a `show` page in your browser, and it will crash because it cannot find the partial `app/views/articles/_comments.html.haml`

Open `app/views/articles/show.html.haml` and change this:

```haml
= render :partial => 'comments', :locals => {:article => @article}
```

to this:

```haml
= render :partial => 'common/comments', :locals => {:article => @article}
```

When render sees a `/` in the partial name, it interprets the first part as the folder name and the second as the file name.

To make it truly reusable, we should edit the partial to refer to a local variable named `subject` then, when rendering it, pass in `:subject => @article`.

If you're wondering, you can nest folders of partials like `common/commentable/comments`, but I generally would not recommend it. The Rails folder structure is nested enough as it is!

### Dealing with Scope & Local Variables

The parent view template and the partial exist in different scopes -- they don't share local variables. In this case, they both have access to the `@article` instance variable. But to make our partial more reusable, we shouldn't have it rely on an instance variable. Instead we can pass in a local variable.

Start by editing `_comments.html.haml` to reference the local `article` instead of `@article`. Refresh the view in your browser and it will crash looking for the local variable.

Now, go over to the `render` call and add on the `locals` option like this:

```haml
= render :partial => 'comments', :locals => {:article => @article}
```

If you pass in a hash to `locals`, `render` will create a local variable for each key in the hash with the value specified. Refresh your view and it will work.

### Rendering Collections

The `render` method is incredibly overloaded. Let's see how it can work with collections of objects. Open `views/articles/index.html.haml`.

See the `@article.each` line? Whenever we have an iteration loop in a view template, it is a candidate for extraction to a collection partial. Cut the `%li` and everything beneath it and paste it into `app/views/articles/_article_item.html.haml`. Then delete the `- @articles.each` line.

[TODO: I think this "delete the" is an artifact and is not necessary. ]

Refresh your index page and the articles will disappear. Delete the 

We want to render the LIs inside the `%ul#articles`, let's try it in one line:

```haml
%ul#articles= render :partial => 'article_item'
```

That's a good start, but we don't want to render it *once*, we need to render it *once for each article*. Add the `:collection` parameter like this:

```haml
%ul#articles= render :partial => 'article_item', :collection => @articles
```

Refresh your browser and it still crashes. The partial is looking for a variable named `article` but can't find one. When you call `render` using a collection, it will process the partial once for each element of the collection. While the partial is being rendered, Rails will provide the element being rendered and store it into a local variable *based on the filename of the partial*.

So in this case, our `_article_item.html.haml` partial will have a local variable named `article_item`.

To make our view work, we have two options.

1. Open the partial and change all references from `article` to `article_item` to match the filename.
2. Rename the partial to `_article.html.haml` so it'll have a local `article` variable.

I'd recommend the second option where possible. Implement that now. Then update the `render` call:

```haml
%ul#articles= render :partial => 'article', :collection => @articles
```

Refresh your browser and the view should display correctly.

### Magical Partial Selection

When we first rendered the comments partial, you might have been thinking that instead of:

```haml
= render :partial => 'comments'
```

We could have just written this:

```haml
= render 'comments'
```

And that's true. If you give `render` a string, it will attempt to render a partial with that name. But, due to implementation details of the `render` method, you *cannot* leave off the `:partial` and still use `:locals`:

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

[TODO: "that name" what? the partial will have the snake_case name? the class name? it's not clear]

`render` accepts an object or a collection of objects. `render` will iterate through the objects and call the `.class_name` method on each one, convert the class name to `snake_case`, and will then render a partial with that name and the object sent in as a local variable named after the file.

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
