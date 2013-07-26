---
layout: page
title: Blogger - Sass
section: Blogger
---

An ugly blog is an unread blog. It is important to know the various ways you
can quickly style a Rails project.

The goal of this tutorial is to give you a view quick introduction to using
SASS within your blog.

<div class="note">
<p>This tutorial is open source. Please contribute fixes or additions to <a href="https://github.com/JumpstartLab/curriculum/blob/master/source/topics/blogger/blogger_sass.markdown">the markdown source on Github.</a></p>
</div>

{% include custom/sample_project_blogger.html %}

## A Few Sass Examples

All the details about Sass can be found here: http://sass-lang.com/

We're not focusing on CSS development, so here are a few styles that you can
copy & paste and modify to your heart's content:

```sass
$primary_color: #AAA;

body {
  background-color: $primary_color;
  font: {
    family: Verdana, Helvetica, Arial;
    size: 14px;
  }
}

a {
  color: #0000FF;
  img: {
    border: none;
  }
}

.clear {
  clear: both;
  height: 0;
  overflow: hidden;
}

#container {
  width: 75%;
  margin: 0 auto;
  background: #fff;
  padding: 20px 40px;
  border: solid 1px black;
  margin-top: 20px;
}

#content {
  clear: both;
  padding-top: 20px;
}
```

If you refresh the page, it should look slightly different! But we didn't add
a reference to this stylesheet in our HTML; how did Rails know how to use it?
The answer lies in Rails' default layout.

### Working with Layouts

We've created about a dozen view templates between our different models.
Imagine that Rails _didn't_ just figure it out. How would we add this new
stylesheet to all of our pages? We _could_ go into each of those templates and
add a line like this at the top:

```erb
<%= stylesheet_link_tag 'styles' %>
```

Which would find the Sass file we just wrote. That's a lame job, imagine if
we had 100 view templates. What if we want to change the name of the
stylesheet later?  Ugh.

Rails and Ruby both emphasize the idea of "D.R.Y." -- Don't Repeat Yourself.
In the area of view templates, we can achieve this by creating a *layout*.
A layout is a special view template that wraps other views. Rails has given us
one already: `app/views/layouts/application.html.erb`.

Check out your `app/views/layouts/application.html.erb`:

```html+erb
<!DOCTYPE html>
<html>
<head>
  <title>Blogger</title>
  <%= stylesheet_link_tag    "application", media: "all", "data-turbolinks-track" => true %>
  <%= javascript_include_tag "application", "data-turbolinks-track" => true %>
  <%= csrf_meta_tags %>
</head>
<body>

<p class="flash">
  <%= flash.notice %>
</p>
<%= yield %>

</body>
</html>
```

Whatever code is in the individual view template gets inserted into the layout
where you see the `yield`. Using layouts makes it easy to add site-wide
elements like navigation, sidebars, and so forth.

See the `stylesheet_link_tag` line? It mentions 'application.' That means it
should load up `app/assets/stylesheets/application.css`... Check out what's
in that file:

```plain
/*
 * This is a manifest file that'll be compiled into application.css, which will include all the files
 * listed below.
 *
 * Any CSS and SCSS file within this directory, lib/assets/stylesheets, vendor/assets/stylesheets,
 * or vendor/assets/stylesheets of plugins, if any, can be referenced here using a relative path.
 *
 * You're free to add application-wide styles to this file and they'll appear at the top of the
 * compiled file, but it's generally better to create a new file per style scope.
 *
 *= require_self
 *= require_tree .
*/
```

There's that huge comment there that explains it: the `require_tree .` line
automatically loads all of the stylesheets in the current directory, and
includes them in `application.css`. Fun! This feature is called the
`asset pipeline`, and it's pretty new to Rails. It's quite powerful.