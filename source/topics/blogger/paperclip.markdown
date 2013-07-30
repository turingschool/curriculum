---
layout: page
title: Blogger - Paperclip
section: Blogger
---

Pictures help tell a story. It would be great to include a photo or image for
each article.

The goal of this tutorial is to add the ability to upload an image to an article
for our blog.

<div class="note">
<p>This tutorial is open source. Please contribute fixes or additions to <a href="https://github.com/JumpstartLab/curriculum/blob/master/source/topics/blogger/paperclip.markdown">the markdown source on Github.</a></p>
</div>

{% include custom/sample_project_blogger.html %}


## Paperclip

There is a gem called [paperclip](https://github.com/thoughtbot/paperclip)
that allows us to easily upload images to our blog.

### Adding the Paperclip gem to Your *Gemfile*

All Rails addons are **gems**. [RubyGems](http://rubygems.org/) is a package
management system for Ruby. There are central servers that host libraries, and
we can install those libraries on our machine with a single command. RubyGems
takes care of any dependencies, allows us to pick an options if necessary, and
installs the library.

We manage our **gems** in the project's **Gemfile**.  The Gemfile is a list of
all the gems required to run your rails project. Even Rails itself is listed
within the Gemfile.

* Open the `Gemfile` in your application and add the following gem:

```ruby
gem "paperclip"
```

We only specified the name of the gem. That means when we install the gem it
will use the latest gem.

We could provide a version, if we knew one we wanted, alongside the gem
declaration. This is useful if for some reason we needed a specific version
because we had a particular feature we wanted or played nicely with our other
gems.

### Installing the Gem

With that config line declared, go back to your terminal and run `rails server`
to start the application again. You should get an error like this:

{% terminal %}
$ rails server
Could not find gem 'paperclip (>= 0, runtime)' in any of the gem sources listed in your Gemfile.
Try running `bundle install`.
{% endterminal %}

The last line is key -- since our config file is specifying which gems it needs,
the `bundle` command can help us install those gems. Go to your terminal and:

{% terminal %}
$ bundle install
{% endterminal %}

It should then install the paperclip RubyGem with a version like 2.3.8. In some
projects I work on, the config file specifies upwards of 18 gems. With that one
`bundle` command the app will check that all required gems are installed with
the right version, and if not, install them.

Now we can start using the library in our application!

### Setting up the Database for Paperclip

We want to add images to our articles. To keep it simple, we'll say that a
single article could have zero or one images. In later versions of the app
maybe we'd add the ability to upload multiple images and appear at different
places in the article, but for now the one will show us how to work with
paperclip.

First we need to add some fields to the Article model that will hold the
information about the uploaded image. Any time we want to make a change to the
database we'll need a migration. Go to your terminal and execute this:

{% terminal %}
$ rails generate migration add_paperclip_fields_to_article
{% endterminal %}

That will create a file in your `db/migrate/` folder that ends in
`_add_paperclip_fields_to_article.rb`. Open that file now.

Remember that the code inside the `change` method is to migrate the database
forward, and Rails should automatically figure out how to undo those changes.
We'll use the `add_column` and `remove_column` methods to setup the fields
paperclip is expecting:

```ruby
class AddPaperclipFieldsToArticle < ActiveRecord::Migration
  def change
    add_column :articles, :image_file_name,    :string
    add_column :articles, :image_content_type, :string
    add_column :articles, :image_file_size,    :integer
    add_column :articles, :image_updated_at,   :datetime
  end
end
```

The go to your terminal and run `rake db:migrate`. The rake command should show
you that the migration ran and added columns to the database.

### Adding to the Model

The gem is loaded, the database is ready, but we need to tell our Rails
application about the image attachment we want to add. Open `app/models/article.rb`
and just below the existing `has_many` lines, add this line:

```ruby
has_attached_file :image
```

This `has_attached_file` method is part of the paperclip library. With that
declaration, paperclip will understand that this model should accept a file
attachment and that there are fields to store information about that file which
start with `image_` in this model's database table.

We also have to deal with mass assignment! Add this too:

```ruby
attr_accessible :image
```

You could also add it to the end of the list:

```ruby
attr_accessible :title, :body, :tag_list, :image
```

### Modifying the Form Template

First we'll add the ability to upload the file when editing the article, then
we'll add the image display to the article show template. Open your
`app/views/articles/_form.html.erb` view template. We need to make two
changes...

In the very first line, we need to specify that this form needs to accept
"multipart" data. This is an instruction to the browser about how to submit
the form. Change your top line so it looks like this:

```erb
<%= form_for(@article, html: {multipart: true}) do |f| %>
```

Then further down the form, right before the paragraph with the save button,
let's add a label and field for the file uploading:

```erb
<p>
  <%= f.label :image, "Attach an Image" %><br />
  <%= f.file_field :image %>
</p>
```

### Trying it Out

If your server isn't running, start it up (`rails server` in your terminal).
Then go to `http://localhost:3000/articles/` and click EDIT for your first
article. The file field should show up towards the bottom. Click the
`Choose a File` and select a small image file (a suitable sample image can be
found at http://hungryacademy.com/images/beast.png). Click SAVE and you'll
return to the article index. Click the title of the article you just modified.
What do you see?  Did the image attach to the article?

When I first did this, I wasn't sure it worked. Here's how I checked:

1. Open a console session (`rails console` from terminal)
2. Find the ID number of the article by looking at the URL. In my case, the url
   was `http://localhost:3000/articles/1` so the ID number is just `1`
3. In console, enter `a = Article.find(1)`
3. Right away I see that the article has data in the `image_file_name` and other
   fields, so I think it worked.
4. Enter `a.image` to see even more data about the file

Ok, it's in there, but we need it to actually show up in the article. Open the
`app/views/articles/show.html.erb` view template. Before the line that displays
the body, let's add this line:

```erb
<p><%= image_tag @article.image.url %></p>
```

Then refresh the article in your browser. Tada!

### Improving the Form

When first working with the edit form I wasn't sure the upload was working
because I expected the `file_field` to display the name of the file that I had
already uploaded. Go back to the edit screen in your browser for the article
you've been working with. See how it just says "Choose File, no file selected"
-- nothing tells the user that a file already exists for this article. Let's
add that information in now.

So open that `app/views/articles/_form.html.erb` and look at the paragraph
where we added the image upload field. We'll add in some new logic that works
like this:

* If the article has an image filename
  *Display the image
* Then display the `file_field` button with the label "Attach a New Image"

So, turning that into code...

```erb
<p>
  <% if @article.image.exists? %>
      <%= image_tag @article.image.url %><br/>
  <% end %>
  <%= f.label :image, "Attach a New Image" %><br />
  <%= f.file_field :image %>
</p>
```

Test how that looks both for articles that already have an image and ones that
don't.

When you "show" an article that doesn't have an image attached it'll have an
ugly broken link. Go into your `app/views/articles/show.html.erb` and add a
condition like we did in the form so the image is only displayed if it actually
exists.

Now our articles can have an image and all the hard work was handled by
paperclip!

### Further Notes about Paperclip

Yes, a model (in our case an article) could have many attachments instead of
just one. To accomplish this you'd create a new model, let's call it
"Attachment", where each instance of the model can have one file using the
same fields we put into Article above as well as an `article_id` field. The
Attachment would then `belong_to` an article, and an article would `have_many`
attachments.

Paperclip supports automatic image resizing and it's easy. In your model, you'd
add an option like this:

```ruby
has_attached_file :image, styles: { medium: "300x300>", thumb: "100x100>" }
```

This would automatically create a "medium" size where the largest dimension
is 300 pixels and a "thumb" size where the largest dimension is 100 pixels.
Then in your view, to display a specific version, you just pass in an extra
parameter like this:

```erb
<%= image_tag @article.image.url(:medium) %>
```

If it's so easy, why don't we do it right now?  The catch is that paperclip
doesn't do the image manipulation itself, it relies on a package called
*imagemagick*. Image processing libraries like this are notoriously difficult
to install. If you're on Linux, it might be as simple as `sudo apt-get install
imagemagick`. On OS X, if you have Homebrew installed, it'd be `brew install
imagemagick`. On windows you need to download an copy some EXEs and DLLs. It
can be a hassle, which is why we won't do it during this tutorial.

Now that you've tried out a plugin library (Paperclip), Iteration 4 is complete!