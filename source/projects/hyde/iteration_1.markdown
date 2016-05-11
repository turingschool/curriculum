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
$  echo -e "# Some Markdown\n\n* a list\n* another item" > sample.markdown
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
