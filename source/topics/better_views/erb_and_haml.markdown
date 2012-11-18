---
layout: page
title: Templating with ERB & HAML
section: Better Views
---

The default templating language in Rails is *Embedded Ruby* or ERB. The template files live in `/app/views/` and are named after the controller and action they're attached to. Everything you need to use ERB is already set up for you within Rails.

### Reviewing ERB

In ERB we have three main markup elements:

* HTML and text use no markers and appear plainly on the page
* `<%=` and `%>` wrap Ruby code whose return value will be output in place of the marker
* `<%` and `%>` wrap Ruby code whose return value will *NOT* be output
* `<%-` and `%>` wrap Ruby code whose return value will *NOT* be output and no blank lines will be generated

The last of those, using `<%-`, has become much less significant as modern browsers restructure the DOM into a browseable tree where whitespace doesn't matter.

### Why Hate ERB?

The upside of the ERB system is that it works with any text format. In Rails applications, we use the ERB system to create HTML files. There's no reason that we couldn't use ERB to output JavaScript, configuration files, form letters, or any other type of document. ERB doesn't know anything about the surrounding text. It just injects printing or non-printing Ruby fragments into plaintext.

But those aspects of ERB are the downside, too. ERB is very general, and a more specialized solution can help reduce our workload.

## Enter HAML

ERB vs. HAML has the fervor of a religious debate in the Rails community. According to surveys, about 46% of the community prefers HAML. 

<div class="opinion">
<p>We love HAML and use it on every project. It encourages stringent formatting of your view templates, lightens the content significantly, and draws clear lines between markup and code.</p>
</div>

### History Lesson

HAML was developed by Hampton Caitlin as pushback against the "heavy" nature of HTML and, by extension, ERB. He started HAML by taking an ERB template and making one assumption: _white space will be significant_. With that assumption, he started deleting all the characters that could possibly be inferred by the template processor engine.

### Developing HAML

In a typical template we'd have plain HTML like this:

```html
<h1>All Articles</h1>
```

Using whitespace to reflect the nested structure, we could reformat it like this:

```html
<h1>
  All Articles
</h1>
```

And, if we assume that whitespace is significant, the close tag would become unnecessary here. The parser could know that the H1 ends when there's an element at the *same* indentation level as the opening H1 tag. Cut the closing tag and we have:

```html
<h1>
  All Articles
```

The H1 tag itself is heave with both open and close brackets. Leaving just `<h1` as the HTML marker could have worked, but Hampton decided that HTML elements would be created with `%` like this:

```html
%h1
  All Articles
```

Lastly, when an HTML element just has one line of content, we will conventionally put it on a single line:

```html
%h1 All Articles
```

The `%` followed by the tag name will output any HTML tag. The content of that tag can be on the same line or indented on the following lines. Note that content can't _both_ be inline with the tag _and_ on the following lines.

### Outputting Ruby in HAML

So how do we embed Ruby in our HAML? In ERB we might have:

```html
<p class='flash'><%= flash[:notice] %></p>
```

Given what you've seen from the H1, you would imagine the `<p></p>` becomes `%p`. But what about the Ruby injection?

#### Ruby Injections

HAML's approach is to reduce `<%= %>` to just `=`. The HAML engine assumes that if the content starts with an `=`, that the entire rest of the line is Ruby. For example, the flash paragraph above would be rewritten like this:

```html
%p= flash[:notice]
```

Note that the `=` must be flush against the `%p` tag.

#### Adding a CSS Class

But what about the class? There are two options. The verbose syntax uses a hash-like format:

```html
%p{class: 'flash'}= flash[:notice]
```

But we can also use a CSS-like shorthand syntax:

```html
%p.flash= flash[:notice]
```

The latter is easier and more commonly used.

### Mixing Plain Text and Ruby

Consider a chunk of content that has both plain text and Ruby like this:

```ruby
<div id="sidebar">
Filter by Tag: <%= tag_links(Tag.all) %>
</div>
```

Given what we've seen so far, you might imagine it goes like this:

```haml
%div#sidebar Filter by Tag: = tag_links(Tag.all)
```

But HAML won't recognize the Ruby code there. Since the element's content _starts_ with plain text, it will assume the whole line is plain text. 

#### Breaking Ruby and Text into Separate Lines

One solution in HAML is to put the plain text and the Ruby on their own lines, each indented under the DIV:

```haml
%div#sidebar
  Filter by Tag: 
  = tag_links(Tag.all)
```

Since version 3, HAML supports an interpolation syntax for mixing plain text and Ruby: 

```haml
%div#sidebar
  Filter by Tag: #{tag_links(Tag.all)}
```

And it can be pushed back up to one line:

```haml
%div#sidebar Filter by Tag: #{tag_links(Tag.all)}
```

#### Implicit `DIV` Tags

DIV is considered the "default" HTML tag. If you just use a CSS-style ID or Class with no explicit HTML element, HAML will assume a DIV:

```haml
#sidebar Filter by Tag: #{tag_links(Tag.all)}
```

### Non-Printing Ruby

We've seen plain text, HTML elements, and printing Ruby. Now let's focus on non-printing Ruby.

One of the most common uses of non-printing Ruby in a view template is iterating through a collection. In ERB we might have:

```haml
<ul id='articles'>
  <% @articles.each do |article| %>
    <li><%= article.title %></li>
  <% end %>
</ul>
```

The second and fourth lines are non-printing because they omit the equals sign. HAML's done away with the `<%`. So you might be tempted to write this:

```ruby
%ul#articles
  @articles.each do |article|
    %li= article.title
```

Content with no marker is interpreted as plain text, so the `@articles` line will be output as plain text and the third line would _cause a parse error_. 

#### Marking Non-Printing Lines

We need a new symbol to mark non-printing lines. In HAML these lines begin with a hyphen (`-`):

```ruby
%ul#articles
  - @articles.each do |article|
    %li= article.title
```

#### The `end`

Wait a minute, what about the `end`? HAML uses that significant whitespace to reduce the syntax of HTML _and_ Ruby. The `end` for the `do` is not only unnecessary, it will raise an exception if you try to use it!

## Review

The key ideas of HAML include:

* Whitespace is significant, indent using two spaces
* HTML elements are created with `%` and the tag name, _ex:_ `%p`
* HTML elements can specify a CSS class (`%p.my_class`) or ID (`%p#my_id`) using a short-hand syntax
* Content starting with an `=` is interpreted as printing Ruby, _ex:_ `%p= article.title`
* Content starting with a `-` is interpreted as non-printing Ruby, _ex:_ `- @articles.each do |article|`
* Content can contain interpolation-style injections like `%p Articles Available:#{@articles.count}`

## Exercises

{% include custom/sample_project_advanced.html %}

1. Open the project's `Gemfile`, add a dependency on `haml` and run `bundle`. Restart your server.
2. *Basic Refactorings*: Following the examples above, complete each of these steps:

  * Open the view template in `app/views/articles/index.html.erb`
  * Rename the template to `index.html.haml` to trigger HAML parsing
  * Cut everything except the H1 to a temporary file so that you can bring back one chunk at a time and rewrite each of them in HAML
  * Rewrite the H1 using HAML syntax for plain text
  * Rewrite the flash using HAML syntax for printing Ruby
  * Output the New Article link without a containing HTML element
  * Rebuild the Sidebar using the HAML interpolation syntax to mix plain text and Ruby on one line

3. *Deep Nesting*: You've worked through the basics. Now, combine the techniques to rebuild the Articles UL:

  * Convert the UL to HAML and indent child elements two spaces
  * Rewrite the loop to use HAML's non-printing Ruby syntax
  * Change the LI to use a HAML content tag
  * Rewrite the child elements using printing Ruby and interpolation as you see fit
  * Review the generated HTML to make sure that the nesting relationships are preserved

4. *Further Practice*: Rebuild the `show.html.erb` into `show.html.haml`. When you are struggling to represent the structure, try separating the parts into their own lines, and then reduce them down as you see fit.

### Solution for `index.html.haml`

```ruby
    %h1 All Articles

    %p.flash= flash[:notice]

    = link_to "New Article", new_article_path, class: 'new_article'

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
