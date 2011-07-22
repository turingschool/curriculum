## ERB and HAML

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
