## Iteration 5 - Supporting Feature #1

Do at least one of the following. Additional supporting features will be considered extensions.

### Adding variables to markdown

Use this to set variables that are used in your ERB layouts. This way, each page can have a slightly different layout. Implement a pattern similar to the YAML frontmatter:

[https://middlemanapp.com/basics/frontmatter/](https://middlemanapp.com/basics/frontmatter/)

Then, if you have something like this in your `default.html.erb`:

```
<title>Sweet Blog - <%= current_page.title =></title>
```

And this at the top of one of your source posts:

```
---
title: "Sweet Post"
---
```

The resulting output HTML for that post will be:

```
<title>Sweet Blog - Sweet Post</title>
```

### Watch for file changes

Add a script that will watch for changes in source files, and rebuild them when source files are changed.

```
bin/hyde watchfs
```

### Support Partials

Create partial layout files to keep your layout from getting out of control. Then render those partials in your layout.

TK
