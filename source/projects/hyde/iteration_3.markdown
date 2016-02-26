## Iteration 3 - Customizing site design with layouts and CSS

After completing iterations 0-2, we should have a basic Hyde blog system that can handle the following workflow:

1. Create a new Hyde project with `bin/hyde new ~/my-blog`
2. Generate a new blog post with `bin/hyde post ~/my-blog Pizza Rules`
3. Build the project source into output HTML and CSS files with `bin/hyde build ~/my-blog`

However if we look at the content we're generating so far, we'll see something is missing. The default post content we generated should look like:

```markdown
# Pizza Rules

Your content here
```

And when we process this content with kramdown, we'll get the equivalent HTML:

```html
<h1 id="pizza-rules">Pizza Rules</h1>

<p>Your content here</p>
```

But we know that a valid HTML document requires a bit more structure -- specifically it should include the standard `<html>`, `<head>`, `<title>`, and `<body>` tags.

Additionally, we so far haven't made any use of the starting CSS files we generated with our new project. We'd ideally like to use some additional html tags to link these files into our pages. Finally, we'd prefer to set this up _once_ so that it applies to all our pages and posts.

### Layouts

In the context of web design a "layout" is a special template that extracts some of the common formatting for a document or collection of documents. The point of a layout is to pull out commonly repeated markup so that we don't have to directly copy it into all of our files. For example many sites will put all of the common content for their header, sidebar, and footer into a layout, since these contents appear the same on every page.

For Hyde, we'd like to define a standard layout file which contains all of the "boilerplate" markup for our pages. Then, when we build the site, each individual page (or post) should have its rendered content injected into the appropriate place in the layout.

### Supporting Layouts in Hyde

For this iteration you need to do several things

1. Add an additional `source/layouts/` directory to the Hyde project generator
2. Update the generator to include a standard layout `source/layouts/default.html.erb` when generating a new project
3. Update your `build` process so that each page gets its content injected into the layout (more on this below)

### Dynamic Templating with ERB

Ruby ships with a built-in templating system called [ERB](http://ruby-doc.org/stdlib-2.3.0/libdoc/erb/rdoc/ERB.html). You can think of ERB as string interpolation on steroids -- it allows us to take pre-defined template strings and then make them dynamic by inserting ruby code.

Nothing about ERB makes it specific to HTML, however that is a common use case. Especially in the context of web applications (e.g. Rails) you'll frequently see ERB used to make HTML templates dynamic.

### ERB Template Crash Course

ERB is part of Ruby's standard library, so we can access it simply by requiring it. To make an ERB template, we simply pass it a string (this could be defined in code, or read from a file). Within an ERB template string, we use 2 special templating tags: `<% %>` to indicate ruby code that should be evaluated but not output into the template, and `<%= %>` to indicate ruby code that should be evaluated _and_ printed to the template.

For example:

```ruby
require "erb"
template_string = "No equal sign (not printed): <% 'ruby code -- not printed to the template' %> -- Equal sign (printed): <%= 1 + 1 %>"
ERB.new(template_string).result
"No equal sign (not printed):  -- Equal sign (printed): 2"
```

#### ERB With Local Bindings

Sometimes we'd like to inject specifically named variables into our ERB when we render it. For example rendering a template string that uses a variable `pizza_toppings`:

```
"Your 'Za features: <%= pizza_toppings %>"
```

ERB supports this by allowing us to provide a `binding` value when generating a `result`. The `binding` conveys local variable references that can be accessed inside of the template string when it gets evaluated.

```ruby
require "erb"

template_string = "Your 'Za features: <%= pizza_toppings %>"
pizza_toppings = "anchovies, mushrooms, and salami"

ERB.new(template_string).result(binding)
"Your 'Za features: anchovies, mushrooms, and salami"
```

### Layouts with ERB

With this tool at our disposal, we should be able to define a simple HTML layout that can house the surrounding document structure for our pages, but allow the actual page "body" to be injected in dynamically. A simple structure might look like:

```html
<html>
  <head><title>Our Site</title></head>
  <body>
    <%= content_goes_here %>
  </body>
</html>
```

Note that ERB files always end with `.erb` but can also have the file extension they would have had anyway. So HTML files with ERB tags added to them often end with `.html.erb`. After they get processed, it's common to name the resulting file with just `.html`.

## Requirements

For this iteration, update Hyde to allow user-defined layouts:

1. Add an additional `source/layouts/` directory to the Hyde project generator
2. Update the generator to include a standard layout `default.html.erb` when generating a new project
3. Update your `build` process so that each page gets its content injected into the layout using ERB. Note that you will probably first need to translate the page content from markdown to html and _then_ inject it into the layout.
