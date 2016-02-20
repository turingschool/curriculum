# Hyde

Writing your own blogging engine is almost a right of passage for aspiring web developers. In this project you'll build a "Static Site Generator" -- a system that allows the author to write content in a writing-friendly format (like Markdown), then the system generates HTML and puts it all together. For reference, existing systems that do this include [Jekyll](https://jekyllrb.com/), [Middleman](https://middlemanapp.com/), and many others.

## Project Overview

### Learning Goals

* Use tests to drive both the design and implementation of code
* Decompose a large application into components
* Use test fixtures instead of actual data when testing
* Connect related objects together through references
* Learn an agile approach to building software

### Getting Started

1. One team member forks the repository at https://github.com/turingschool-examples/hyde and adds the other(s) as collaborators.
2. Everyone on the team clones the repository
3. Create a [Waffle.io](http://waffle.io) account for project management.
4. Setup [CodeClimate](https://codeclimate.com/) to monitor code quality along the way
5. Setup [TravisCI](https://travis-ci.org/) to run your tests ever time you push

## Key Concepts

From a technical perspective, this project will emphasize:

* File I/O
* Parsing and Markup
* Encapsulating Responsibilities
* Light data / analytics

## Iterations / Features

### Iteration 0: Generator a New Hyde Blog
### Iteration 1: Processing Source Files Into HTML
### Iteration 2: Generating new posts
### Iteration 3: Customizing Design With Layouts
### Iteration 4: Supporting Features

## Setup -- Project Skeleton

-- Start from cloning a basic skeleton

## Iteration 0 -- Generating the Site Structure

Most static site generators include a command to generate the initial scaffolding for a new blog or site. This gives us more control and consistency around how the files and directories in our Hyde projects will be named, which keeps many of our later steps simpler.

### Interface

To generate a new Hyde project, the user will use this command:

```
bin/hyde new /path/to/the/site
```

Where `/path/to/the/site` indicates where Hyde should place the new project skeleton. For example a user might generate one in their home directory using `bin/hyde new ~/my-sweet-blog`.

### Hyde Directory Structure

Once a user requests a new Hyde project, we'll need to do 2 things

1. Create the new directory (running the `new` command with a directory that already exists should result in an error)
2. Fill the new directory with the appropriate Hyde files and directories

The starting project skeleton will look like this:

```
.
├── _output
└── source
    ├── css
    │   └── main.css
    ├── index.markdown
    ├── pages
    │   └── about.markdown
    └── posts
        └── 2016-02-20-welcome-to-hyde.markdown
```

### Hyde Directory Contents

* `_output` - This is where we'll eventually put our generated site contents. Users generally won't actually work with files in this directory. Rather, they will be generated from the other source (markdown) files in the project
* `source/` - This directory will house our "input" files. To "build" our site, we'll process all the files and subdirectories in this directory and transfer them to the `_output` directory in the appropriate format.
* `source/css` - This directory will contain stylesheets that users can use to style their sites
* `source/index.markdown` - This markdown file will eventually become our site's `index.html`. By convention a site's `index.html` is used as its root page.
* `source/pages` - Markdown files in this directory will become standalone pages at the appropriate url. For example a file at `source/pages/pizza.markdown` could be viewed at `my-site.com/pages/pizza.html`
* `source/posts` - Another "source" directory -- markown files in this directory will be used similarly to those in pages.

## Iteration 1: Building Site Files

### Interface

A user will build their site by running `hyde` with the subcommand `build` and providing the path to the Hyde project they'd like to build. For example:

```
bin/hyde build ~/my-sweet-blog
```

### Build Process

Building the site requires processing each file and directory inside of `source` and generating a corresponding output file in the appropriate place under `_output`. For starters, the only files we'll apply any special processing to are `.markdown` (or `.md`) files. Other files (`.css`, `.jpg`, etc) will simply be copied as is.

Our processing algorithm looks something like:

1. Iterate through all the files and directories in the `source` directory
2. If an element is a Markdown file, convert it to html and copy it to the appropriate place inside
of `_output`
3. If an element is any other type of File, simply copy it to the appropriate place inside `_output`
4. If an element is directory, create a matching subdirectory inside the `_output` directory, then repeat
this process for any files or folders within it.

### Why Markdown?

If this is your first time encountering Markdown, you might ask yourself "Why go to all this trouble to avoid HTML?"

According to John Gruber, the creator of [Markdown](https://daringfireball.net/projects/markdown/):

> Markdown is a text-to-HTML conversion tool for web writers. Markdown allows you to write using an easy-to-read, easy-to-write plain text format, then convert it to structurally valid XHTML (or HTML). [...] Tihe overriding design goal for Markdown’s formatting syntax is to make it as readable as possible. The idea is that a Markdown-formatted document should be publishable as-is, as plain text, without looking like it’s been marked up with tags or formatting instructions.

HTML is the dominant method for transmitting formatted textual content over the web. As far as computer languages go, HTML is fairly straightforward. Unfortunately HTML is still fundamentally designed to be read by machines, not humans. This makes things especially difficult when working with hand-written text -- formatting our content as HTML adds a layer of complex syntax which obscures the original content. Markdown is an attempt to allow us to generate HTML automatically while still keeping our content readable (for humans).

### Converting Markdown to HTML

How do we actually convert markdown (our source files) to HTML (our output files)? Fortunately there are numerous tools out there to make this process work. We'll recommend using the [kramdown](http://kramdown.gettalong.org/index.html) gem for this job. Here are some examples of how to use it.

**From the Command Line:**

```
$  gem install kramdown
Successfully installed kramdown-1.9.0
1 gem installed
$  echo "# Some Markdown\n\n* a list\n* another item" > sample.markdown
$  kramdown sample.markdown
<h1 id="some-markdown">Some Markdown</h1>

<ul>
  <li>a list</li>
  <li>another item</li>
</ul>
```

**From Ruby / Pry:**

```
$  gem install kramdown
Successfully installed kramdown-1.9.0
1 gem installed
$  pry
[1] pry(main)> require "kramdown"
=> true
[2] pry(main)> markdown = "# Some Markdown\n\n* a list\n* another item"
=> "# Some Markdown\n\n* a list\n* another item"
[3] pry(main)> Kramdown::Document.new(markdown).to_html
=> "<h1 id=\"some-markdown\">Some Markdown</h1>\n\n<ul>\n  <li>a list</li>\n  <li>another item</li>\n</ul>\n"
[4] pry(main)>
```

### Building a Hyde Project -- Full Example

As a high level example, if we built the Hyde project that we looked at in the previous step, we would end up with this resulting project structure:

```
worace @ hyde_sample ➸  tree .
.
├── _output
│   ├── css
│   │   └── main.css
│   ├── index.html
│   ├── pages
│   │   └── about.html
│   └── posts
│       └── 2016-02-20-welcome-to-hyde.html
└── source
    ├── css
    │   └── main.css
    ├── index.markdown
    ├── pages
    │   └── about.markdown
    └── posts
        └── 2016-02-20-welcome-to-hyde.markdown
```

Notice that each directory and file under `source` gets translated into the corresponding place under `_output`.

### Useful Ruby File Utilities

#### Functionality

The "application" will be run as an executable from a user's machine (gem or npm module). It needs to include several features:

* a "generator" to scaffold out a new site (eg `hyde new my-blog`)
* a "build" step which processes provided markdown files into rendered HTML templates. You'll likely want to use an existing Markdown processor for this, although if you ask nicely a module 1 student might let you use their Chisel.
* a "serve" command which boots a simple HTTP server to allow viewing the site in development.

#### File Locations and Path Conventions

Remember that by convention, the "root" file for a static HTML site is its `index.html`. This is what will be served by, for example, github pages if you ship your site to it. We'd like to also allow arbitrary path nesting based on whatever structure a user provides with their site.

So, for example, a file located in the source at:

`articles/my_article.markdown`

should get built as:

`articles/my_article.html`

and be retrievable on the server at:

`my_url.com/articles/my_article.html`

### Serving static assets

We'd like our users to be able to include static assets like Javascripts, Stylesheets, and Images.

### Extensions

* Rails-style "layouts" for extracting standard template functionality
* Partials
* CSS preprocessor (using sass or less)

## Iteration 2 -- Generating New Blog Files

For Hyde to become a viable blogging platform, we should add some commands to make common operations easy for our users. One of these is generating new posts for the blog. Add a hyde subcommand `post` which generates a new blog post file.

The command will be used like this:

```
bin/hyde post [Hyde Project Directory] [Post Title]
```

Where `[Hyde Project Directory]` gives the path to the root of the user's Hyde project and `[Post Title]` takes any remaining text provided and uses it as the post's title.


**Example:**

```
bin/hyde post ~/my-sweet-blog Juicy Post
Created a new post file at ~/my-sweet-blog/source/posts/2016-02-20-juicy-post.markdown
```

And inside of `~/my-sweet-blog/source/posts/2016-02-20-juicy-post.markdown`, Hyde should pre-populate some basic content:

```markdown
# Juicy Post

Your content here
```

## Project Iterations and Base Expectations

Because the requirements for this project are lengthy and complex, we've broken
them into Iterations in their own files:

* [Iteration 0](iteration_0.markdown) - Zero
* [Iteration 1](iteration_1.markdown) - One

## Evaluation Rubric

The project will be assessed with the following guidelines:

### 1. Functional Expectations

* 4: Application fulfills all base expectations and two extensions
* 3: Application fulfills all base expectations as tested by the spec harness
* 2: Application has some missing functionality but no crashes
* 1: Application crashes during normal usage

### 2. Test-Driven Development

* 4: Application is broken into components which are well tested in both isolation and integration using appropriate data
* 3: Application is well tested but does not balance isolation and integration tests, using only the data necessary to test the functionality
* 2: Application makes some use of tests, but the coverage is insufficient
* 1: Application does not demonstrate strong use of TDD

### 3. Encapsulation / Breaking Logic into Components

* 4: Application is expertly divided into logical components each with a clear, single responsibility
* 3: Application effectively breaks logical components apart but breaks the principle of SRP
* 2: Application shows some effort to break logic into components, but the divisions are inconsistent or unclear
* 1: Application logic shows poor decomposition with too much logic mashed together

### 4. Fundamental Ruby & Style

* 4:  Application demonstrates excellent knowledge of Ruby syntax, style, and refactoring
* 3:  Application shows strong effort towards organization, content, and refactoring
* 2:  Application runs but the code has long methods, unnecessary or poorly named variables, and needs significant refactoring
* 1:  Application generates syntax error or crashes during execution

### 5. Enumerable & Collections

* 4: Application consistently makes use of the best-choice Enumerable methods
* 3: Application demonstrates comfortable use of appropriate Enumerable methods
* 2: Application demonstrates functional knowledge of Enumerable but only uses the most basic techniques
* 1: Application demonstrates deficiencies with Enumerable and struggles with collections

### 6. Code Sanitation

The output from `rake sanitation:all` shows...

* 4: Zero complaints
* 3: Five or fewer complaints
* 2: Six to ten complaints
* 1: More than ten complaints
