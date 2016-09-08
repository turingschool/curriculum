## Iteration 2 -- Generating New Blog Files

For Hyde to become a viable blogging platform, we should add some commands to make common operations easy for our users. One of these is generating new posts for the blog. Add a hyde subcommand `post` which generates a new blog post file.

The command will be used like this:

```
bin/hyde post /path/to/my/blog_directory Post Title
```

Where `"Hyde Project Directory"` gives the path to the root of the user's Hyde project and `Post Title` takes any remaining text provided and uses it as the post's title.


**Example:**

```
bin/hyde post ~/my-sweet-blog Juicy Post
Created a new post file at ~/my-sweet-blog/source/posts/2016-02-20-juicy-post.markdown
```

And inside of `~/my-sweet-blog/source/posts/2016-02-20-juicy-post.markdown`, Hyde should pre-populate some basic content:

```plain
# Juicy Post

Your content here
```
