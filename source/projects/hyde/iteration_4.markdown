## Iteration 3 - Supporting Post "Tags"

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


## Requirements

For this iteration, update Hyde to allow user-defined layouts:

1. Add an additional `source/layouts/` directory to the Hyde project generator
2. Update the generator to include a standard layout `source/layouts/default.html.erb` when generating a new project
3. Update your `build` process so that each page gets its content injected into the layout using ERB. Note that you will probably first need to translate the page content from markdown to html and _then_ inject it into the layout.
