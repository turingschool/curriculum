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
