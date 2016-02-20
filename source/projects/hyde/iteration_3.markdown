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

### Supporting Layouts in Hyde

For this iteration you need to do several things

1. Add an additional `source/layouts/` directory to the Hyde project generator
2. Update the generator to include a standard layout `default.html.erb` when generating a new project
3. Update your `build` process so that each page gets its content
injected into the layout (more on this below)


### Working with ERB

TK

### Injecting page content into a layout

TK
