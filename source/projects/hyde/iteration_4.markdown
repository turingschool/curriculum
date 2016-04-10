## Iteration 4 - Supporting Post "Tags"

Next, let's enhance our blogging engine by adding support to attach tags to our posts. Ultimately when a user tags a post, we want to accomplish 2 things:

1. The list of tags attached to a post should appear on the final rendered page for that post
2. When generating the site, it should generate individual Tag Pages for each tag that appears in a post
3. Each Tag Page should include a list of links to all the posts that are marked with that tag.

### 1. Tagging a Post

To accomplish tagging, let's add an additional "metadata" section to our post documents. The metadata will appear at the top of the post document and be separated from the actual content by a row of `---` above and below.

Inside the metadata section, we'll allow users to attach metadata to a post using a "hash-like" key-value syntax. Putting these together a final example will look like:

```
---
tags: Italian Food, flatbread
---
# My Post on Pizza

* nom
* nom, nom
```

### 2. Reading and Parsing Tag Metadata

With this structure in place, we'll want to add an additional step to our build process -- before we can render the markdown content of a post, we'll need to first extract and parse the metadata attached to it. From this section of the document, we want to extract the key and value pair(s). In this case we'd come up with something like `{"tags" => ["Italian Food", "flatbread"]}`.

### 3. Cleaning Tag Names

English tag names like `Italian Food` are great for users but will be a bit difficult for our system. Let's improve this by cleaning all user-provided tag names to be:

1. Lower-cased
2. Snake-cased (using underscores to separate multiple words)

So for example, `Italian Food` becomes `italian_food`.

### 4. Building Tag "Digest" Pages

Add an additional step to your `build` process which accomplishes the following:

1. Compile a list of all of the tags mentioned across all of the posts
2. For each of them, generate an output page at `_output/tags/my_tag.html`
3. On this page, include the name of the tag **and** a bulleted-list of links pointing to all of the posts which are labeled with that tag

For example if we consider the simple example from above with our Pizza post, we might end up with the following structure after building:

```
worace @ hyde_sample ➸  tree .
.
├── _output
│   ├── css
│   │   └── main.css
│   ├── index.html
│   ├── pages
│   │   └── about.html
│   ├── tags
│   │   └── italian_food.html
│   │   └── flatbread.html
│   └── posts
│       └── 2016-02-20-pizza.html
└── source
    ├── css
    │   └── main.css
    ├── index.markdown
    ├── pages
    │   └── about.markdown
    └── posts
        └── 2016-02-20-pizza.markdown
```

On each of these tag pages, we would expect to see a link to the appropriate pizza post `/posts/2016-02-20-pizza.html`

### 5. Linking to a post's tags from the post

Finally, let's also include a list of links on each post page pointing to each of its tags. So in our pizza example, we would want to see 2 links, one to `/tags/italian_food.html` and one to `/tags/flatbread.html`. You can arrange these within the post's rendered content however you feel is best.
