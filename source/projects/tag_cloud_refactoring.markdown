---
layout: page
title: Tag Cloud Refactoring
sidebar: true
---

In this project you'll refactor a method in a Rails controller. You will learn
about

* The Single Responsibility Principle
* Using lockdown tests to refactor safely
* Taking very, very small steps
* Extracting methods

This project uses a long-lived open source rails application named
[Tracks](http://codeclimate.com/github/JumpstartLab/tracks).

It is a todo list application inspired by David Allen's [Getting Things Done](http://www.amazon.com/Getting-Things-Done-Stress-Free-Productivity/dp/0142000280).

The first commit on the application was made in 2006. It currently has
well over 200 forks, and is still under active development. The version you
will be working on is a snapshot from March 2013.

The project will be developed in 11 iterations.

<div class="note">
<p>This tutorial is open source. If you notice errors, typos, or have questions/suggestions, please <a href="https://github.com/JumpstartLab/curriculum/blob/master/source/projects/tag_cloud_refactoring.markdown">submit them to the project on GitHub</a>.</p>
</div>

## Setup

### Prerequisites

* [Ruby 1.9.3](https://rvm.io/)
* [Bundler](http://gembundler.com/)
* [Firefox](http://www.mozilla.org/en-US/firefox/new/)

Firefox is necessary to run some Cucumber features.

### Code Base

You want to create your own fork of the code on GitHub and prepare it for work:

* [Create a fork of our repository at this URL](https://github.com/JumpstartLab/tracks/fork)
* Hop over to [Code Climate's Registration Page](https://codeclimate.com/github/signup) where you'll add your repository name (like `jcasimir/tracks`) and an email address

We'll use the feedback from Code Climate to assess the progress you make through refactoring.

#### Run It Locally

To do any actual work you'll need to clone your new fork to your local machine.

{% terminal %}
$ git clone git@github.com:YOURNAME/tracks.git
$ cd tracks
$ cp config/site.yml.tmpl config/site.yml
$ cp config/database.yml.tmpl config/database.yml
$ bundle install
$ bundle exec rake db:create db:migrate db:test:prepare
$ bundle exec rake wip
{% endterminal %}

<div class="note">
<p><code>wip</code> stands for <em>work in progress</em>.</p>
</div>

If the tests run correctly when you run `bundle exec rake wip`, then
you're all set.

## I0: Exploration

Take a look at our project's [Code Climate report](http://codeclimate.com/github/JumpstartLab/tracks) for this code base.

* Which parts of the code base have the worst ratings?
* What seems the scariest to you?
  You don't need to be able to articulate why it seems scary.
* What does Code Climate tell us about the code quality in the views?

### `StatsController`

We will be working on a small portion of the `StatsController`.

* What does Code Climate say is the `complexity` metric for this file?
* How about the `duplication` metric?
* What do these metrics actually mean?
* How long is the `index` action in the `StatsController`?
* What methods are being called?
* Where are they defined?
* How long are they?
* How many instance variables get assigned?
* Do all the assigned instance variables get used in the view and
  partials that get rendered?

## I1: Test Coverage

Let's run those `wip` tests and look at the coverage:

{% terminal %}
$ bundle exec rake wip
$ open coverage/index.html
{% endterminal %}

This *will not* represent the full coverage of the entire project, only
the coverage when running the handful of tests in the `wip` task.

### `StatsController`

Find the `StatsController` in this list.

* What is the code coverage for this file?
* How good do you think the coverage is for the `get_stats_tags` method?

### Changing the View Template

Open `app/views/stats/index.html.erb` and delete the line
that looks like this:

```erb
<%= render partial: 'tags' -%>
```

Run the tests again

{% terminal %}
$ bundle exec rake wip
{% endterminal %}

* How many tests fail?
* Does that seem **ok**?

Now, restore the view template to its original state using git:

{% terminal %}
$ git checkout .
{% endterminal %}

### Experimenting with `get_stats_tags`

The tag cloud appears to have 100% code coverage, but it turns out that
there are no assertions regarding this part of the code, it just runs
without raising any exceptions.

We need a test that will fail if we change anything in the `get_stats_tags` method or the corresponding `tags` partial.

Run the following command to create a branch:

{% terminal %}
$ git checkout -b iteration1 cloud.i1
{% endterminal %}

This creates a new branch named `iteration1` based off of the git tag
named `cloud.i1`.

By checking out this tag from git, you're getting new code that we've added. Specifically, there's a new test file `test/functional/lockdown_test.rb` and an additional rake task in `lib/tasks/wip.rake` to run this test.

{% terminal %}
$ bundle exec rake test:lockdown
{% endterminal %}

Go ahead and run the test, which will fail.

### Understanding the Lockdown Test

Let's take a look at the output from the test which is stored in the `.lockdown` folder:

{% terminal %}
$ open .lockdown/received.html
$ open .lockdown/approved.html
{% endterminal %}

* The `received.html` is the actual HTML that was generated by the application when the `index` action was called within `StatsController`
* The `approved.html` is **blank**

The idea here is that the two files should be identical. Imagine the `approved.html` contains markup that was created by hand, maybe by our designer or product manager, which defines the *expected output* of the method. In the test we compare the *expected* output, `approved.html`, with the generated output, `received.html`, and they should be identical.

If and only if they match, then we know the implementation is correct.

The `approved.html` file is empty, because this is the first time the
test has been run on this system -- and we're not sure what the output should look like.

### Defining the Expected Output

Since we're refactoring, we expect that the code we're working with is actually *working correctly*. So let's assume that the
`StatsController#index` action is rendering exactly what it should.

Approve the test by copying the *received* file over the *approved* file:

{% terminal %}
$ cp .lockdown/received.html .lockdown/approved.html
{% endterminal %}

Run the test again (it should pass):

{% terminal %}
$ bundle exec rake test:lockdown
{% endterminal %}

### Testing the Test

Open up the `app/views/stats/index.html.erb` file and delete the line that
looks like this again:

```erb
<%= render partial: 'tags' -%>
```

Run the test again and see it **fail**:

{% terminal %}
$ bundle exec rake test:lockdown
{% endterminal %}

When you are done reset the code so we're ready to refactor:

{% terminal %}
$ git checkout .
{% endterminal %}

The folder `.lockdown` is *ignored* by git because it's in the `.gitignore` file, so your `approved.html` will not be affected by this `checkout`.

## I2: Cordonning Off Some Code

Check out a new branch based on the current state of your code:

{% terminal %}
$ git checkout -b iteration2
{% endterminal %}

We're going to be refactoring `StatsController#get_stats_tags`.

* How long is the method?
* How many instance variables does it assign?
* How many SQL queries does it execute?
* Where does it get called from? (HINT: `git grep get_stats_tags`)
* What does it actually do?

### What it Actually Does

The `get_stats_tags` method does all the calculations to create two separate
tag clouds on the stats page.

The first tag cloud consists of all the tags for all todos for the current
user since the beginning of time.

The second tag cloud consists of all the tags for all the todos for the
current user in the past 90 days.

### Preparing a new Model

These calculations belong in the model layer, so let's move them.

We're going to create a ruby class that doesn't inherit from `ActiveRecord::Base`.

Create a new directory called `stats` inside of `app/models/`.

{% terminal %}
mkdir app/models/stats
{% endterminal %}

Then, create a file `app/models/stats/tag_cloud.rb`

{% terminal %}
touch app/models/stats/tag_cloud.rb
{% endterminal %}

Put the following code in the `tag_cloud.rb` file:

```ruby
class TagCloud
  def compute
  end
end
```

Now _copy_ (do NOT _cut_) the contents of the `get_stats_tags` method from the
controller into the compute method of the new `TagCloud` class.

### Sanity Checking the Extraction

Go back to the controller, and add this line of code to the top of the
`get_stats_tags` method:

```ruby
TagCloud.new.compute
```

Notice that we aren't using the line of code yet. We're just calling it. All
the old code is still in the `get_stats_tags` method.

Run the `bundle exec rake test:lockdown` task again.

We get the following error:

```text
1) Error:
  test_page_does_not_change_while_refactoring(LockdownTest):
    NameError: undefined local variable or method `current_user' for #<TagCloud:0x007f9dfd70ea20>
```

We can fix that by giving the tag cloud object a `current_user`:

```ruby
class TagCloud

  attr_reader :current_user
  def initialize(current_user)
    @current_user = current_user
  end

  def compute
    # ...
  end
end
```

And then pass the `current_user` to the tag cloud in the `StatsController#get_stats_tags` method:

```ruby
TagCloud.new(current_user).compute
```

Rerun the `test:lockdown` rake task. The test should be passing.

Commit your changes.

## I3: Using the TagCloud

If you've gotten confused and want a clean slate, go ahead and checkout a new branch based on the `cloud.i2` tag.


{% terminal %}
$ git checkout -b iteration3 cloud.i2
{% endterminal %}

Otherwise just create a new branch based on the current state of your code:

{% terminal %}
$ git checkout -b iteration3
{% endterminal %}

### Replacing an Instance Variable

First, let's assign the `TagCloud` object that we're creating in the `StatsController#get_stats_tags` method:

```ruby
def get_stats_tags
  cloud = TagCloud.new(current_user)
  cloud.compute
  # ...
end
```

Then find the first instance variable assignment in `get_stats_tags` method.

The first one I find is `@tags_for_cloud`.

We want to expose this instance variable in the TagCloud object. Add an `attr_reader` for it.

```ruby
class TagCloud

   attr_reader :current_user, :tags_for_cloud

   # ...

end
```

Then, back in the controller, find the place where `@tags_for_cloud` is being assigned, and add a new line underneath it:

```ruby
@tags_for_cloud = Tag.find_by_sql(query).sort_by { |tag| tag.name.downcase }
@tags_for_cloud = cloud.tags_for_cloud
```

Run the `lockdown` test. It should be passing.

Now you can delete the original `@tags_for_cloud` assignment, along with the big SQL `query` string, because it is only used in that line of code.

Run the `lockdown` test again to make sure you didn't delete too much.

### Replacing Another Instance Variable

The next assignment is `@tags_min`, which is first assigned and then changed:

```ruby
max, @tags_min = 0, 0
@tags_for_cloud.each { |t|
  max = [t.count.to_i, max].max
  @tags_min = [t.count.to_i, @tags_min].min
}
```

Create an `attr_reader` in the `TagCloud` model for `:tags_min`, and then go back to the controller and add a new assignment below the section that deals with `@tags_min`:

```ruby
max, @tags_min = 0, 0
@tags_for_cloud.each { |t|
  max = [t.count.to_i, max].max
  @tags_min = [t.count.to_i, @tags_min].min
}
@tags_min = cloud.tags_min
```

Run the `lockdown` test again. It should still be passing.

Delete the code that we've just replaced and re-run the `lockdown` test to make sure that you didn't delete too much.

Ouch! That failed. We're missing a local variable named `max`. Let's put back the code we just deleted. The `@tags_divisor` assignment needs `max`.

Go ahead and expose `:tags_divisor` in the `TagCloud` object as well, and assign it in the controller:

```ruby
@tags_divisor = ((max - @tags_min) / levels) + 1
@tags_divisor = cloud.tags_divisor
```

Run the `lockdown` test. It should be passing.

Now we can delete the old code for `@tags_min` and `@tags_divisor`. Do that, and then run the `lockdown` test again.

### Progress So Far

The `get_stats_tags` method should now look something like this:

```ruby
def get_stats_tags
  cloud = TagCloud.new(current_user)
  cloud.compute
  # tag cloud code inspired by this article
  #  http://www.juixe.com/techknow/index.php/2006/07/15/acts-as-taggable-tag-cloud/

  levels=10
  # TODO: parameterize limit

  @tags_for_cloud = cloud.tags_for_cloud
  @tags_min = cloud.tags_min
  @tags_divisor = cloud.tags_divisor

  # A lot more code here...
end
```

### Yet Another Instance Variable

The next instance variable that gets assigned is `@tags_for_cloud_90_days`.

```ruby
@tags_for_cloud_90days = Tag.find_by_sql(
  [query, current_user.id, @cut_off_3months, @cut_off_3months]
).sort_by { |tag| tag.name.downcase }
```

Expose this in the `TagCloud` using an attr_reader, and then put a new declaration below it using the exposed value:

```ruby
@tags_for_cloud_90days = Tag.find_by_sql(
  [query, current_user.id, @cut_off_3months, @cut_off_3months]
).sort_by { |tag| tag.name.downcase }
@tags_for_cloud_90days = cloud.tags_for_cloud_90_days
```

The tests are failing. What happened?

### A `nil` what, now?

Let's look at the diff:

```text
diff .lockdown/approved.html .lockdown/received.html
```

It looks like the whole tag cloud disappeared. What the heck?

If you take a good look at the query for `@tags_for_cloud_90_days` it references an instance variable named `@cut_off_3months`. Where is that instance variable defined?

It looks like it comes from a helper method in the controller called `init`. Let's pass it to the `TagCloud` object when we initialize it:

```ruby
cloud = TagCloud.new(current_user, @cut_off_3months)
```

We need to make sure that we save this new variable in the `TagCloud`:

```ruby
class TagCloud

  attr_reader :current_user, :tags_for_cloud, :tags_min, :tags_divisor,
    :tags_for_cloud_90days
  def initialize(current_user, cut_off_3months)
    @current_user = current_user
    @cut_off_3months = cut_off_3months
  end

  def compute
    # ...
  end
end
```

Run the `lockdown` test again. It should be passing.

Now we can delete that second big sql `query` string, along with the old `@tags_for_cloud_90days` assignment.

The test still passes.

### More Instance Variables

The next instance variable that is being assigned is `@tags_min_90days`.

Expose the variable in the `TagCloud`, and add the new assignment below the old one in the controller.

Run the `lockdown` test. It should be passing.

### Déjà Vu

We won't try to delete this, because it looks eerily familiar: the `@tags_divisor_90days` needs the `max_90days` local variable that gets defined in that section of the code.

Expose the `@tags_divisor_90days` and add the new assignment below the old one.

This section of the controller should now look like this:

```ruby
max_90days, @tags_min_90days = 0, 0
@tags_for_cloud_90days.each { |t|
  max_90days = [t.count.to_i, max_90days].max
  @tags_min_90days = [t.count.to_i, @tags_min_90days].min
}
@tags_min_90days = cloud.tags_min_90days

@tags_divisor_90days = ((max_90days - @tags_min_90days) / levels) + 1
@tags_divisor_90days = cloud.tags_divisor_90days
```

The `lockdown` test should be passing, and we can delete both of the old
sections defining `@tags_min_90days` and `@tags_divisor_90days`.

Run the `lockdown` test.

### Tidying Up `get_stats_tags`

The controller method should look like this:

```ruby
def get_stats_tags
  cloud = TagCloud.new(current_user, @cut_off_3months)
  cloud.compute
  # tag cloud code inspired by this article
  #  http://www.juixe.com/techknow/index.php/2006/07/15/acts-as-taggable-tag-cloud/

  levels=10
  # TODO: parameterize limit

  @tags_for_cloud = cloud.tags_for_cloud
  @tags_min = cloud.tags_min
  @tags_divisor = cloud.tags_divisor

  @tags_for_cloud_90days = cloud.tags_for_cloud_90days
  @tags_min_90days = cloud.tags_min_90days
  @tags_divisor_90days = cloud.tags_divisor_90days
end
```

We can delete the comments, because they've all been moved into the `TagCloud`
class.

We can also ditch the `level` variable, which is no longer used here.

The controller method now looks like this:

```ruby
def get_stats_tags
  cloud = TagCloud.new(current_user, @cut_off_3months)
  cloud.compute

  @tags_for_cloud = cloud.tags_for_cloud
  @tags_min = cloud.tags_min
  @tags_divisor = cloud.tags_divisor

  @tags_for_cloud_90days = cloud.tags_for_cloud_90days
  @tags_min_90days = cloud.tags_min_90days
  @tags_divisor_90days = cloud.tags_divisor_90days
end
```

If the `lockdown` test is passing, commit your changes.

## I4: Cleaning up the TagCloud

If you've gotten confused and want a clean slate, go ahead and checkout a new branch based on the `cloud.i3` tag.

{% terminal %}
$ git checkout -b iteration4 cloud.i3
{% endterminal %}

Otherwise just create a new branch based on the current state of your code:

{% terminal %}
$ git checkout -b iteration4
{% endterminal %}

### Current User is No Longer Current

In `app/models/stats/tag_cloud.rb` we're referring to a `current_user`, but users in
the model aren't really `current`, that's a concern for the web-part of the
application (controllers and views).

Rename `current_user` to `user`, and run the `lockdown` test to make sure you
did it correctly.

### Comments

Take a look at the comment that goes like this:

```ruby
# tag cloud code inspired by this article
# http://www.juixe.com/techknow/index.php/2006/07/15/acts-as-taggable-tag-cloud/
```

That seems like it is relevant to the whole file, not just the compute method.
Move it up to the top of the file.

The `TODO` comment is still relevant, but let's make it a comment for the
whole `compute` method.

The remaining comments are just trying to explain the code. Let's go ahead and
get rid of them.

### Redundant Variable Names

`TagCloud#tags_for_cloud` is a very redundant method name. It would read much
better if we just call it `tags`, because we already know we're in a cloud.

Look at how nice this becomes:

```ruby
cloud.tags
```

Once you've made the change in the `TagCloud` class, you'll need to update the
controller.

Be sure to only update the message that gets sent to the `cloud` object, not the name of the instance variable that you're assigning, because the view is still using the old variable name.

```ruby
@tags_for_cloud = cloud.tags
```

### More Redundancy

When a variable name is composed of several parts, then each part should
make a meaningful distinction.

Think a bit about the following variable names:

* `tags_for_cloud_90days`
* `tags_min`
* `tags_divisor`
* `tags_min_90days`
* `tags_divisor_90days`

For each part of the name, think about whether or not that portion of the name
is making a meaningful distinction. Does the variable name lose any meaning if
that bit is dropped?

Update the variable names, and remember to update the controller as well.

Run the `lockdown` test, which should still be passing.

### Overspecified Variable Name

The `@cut_off_3months` variable name has too much information in it.

The fact that it is a `cut_off` is important. The fact that it is `3months` is
fairly arbitrary. If we happened to set the `cut_off` to 12 months or 30 days
the code would still work, giving us back the data for 12 months or 30 days.

Rename the variable to `@cut_off`, run the `lockdown` test, and commit your changes.

## I5: Extracting the SQL queries

If you've gotten confused and want a clean slate, go ahead and checkout a
new branch based on the `cloud.i4` tag.

{% terminal %}
$ git checkout -b iteration5 cloud.i4
{% endterminal %}

Otherwise just create a new branch based on the current state of your code:

{% terminal %}
$ git checkout -b iteration5
{% endterminal %}

### Breaking Down `compute`

It's time to start dealing with that big `compute` method.

The first thing I want to do is get those enormous SQL strings out of the main
computation.

There are two `query` strings, and they're very similar, but not identical.

That's unfortunate, because _identical_ is easy to deal with: you extract one,
and call it twice.

With _similar_ we're stuck with dealing with them one at a time.

### Exctracting a Method

Let's start with the second one, because that is the longest one.

First add a `private` declaration at the bottom of the class.

Then, below it, add an empty method called `sql_90days`.

```ruby
private

def sql_90days
end
```

Now _copy_ (don't _cut_) the query string that gets used for the `@tags_90days` assignment.

```ruby
def sql_90days
  query = "SELECT tags.id, tags.name AS name, count(*) AS count"
  query << " FROM taggings, tags, todos"
  query << " WHERE tags.id = tag_id"
  query << " AND todos.user_id=? "
  query << " AND taggings.taggable_type='Todo' "
  query << " AND taggings.taggable_id=todos.id "
  query << " AND (todos.created_at > ? OR "
  query << "      todos.completed_at > ?) "
  query << " GROUP BY tags.id, tags.name"
  query << " ORDER BY count DESC, name"
  query << " LIMIT 100"
end
```

Find the line where this local variable `query` gets used:

```ruby
@tags_90days = Tag.find_by_sql(
  [query, user.id, @cut_off, @cut_off]
).sort_by { |tag| tag.name.downcase }
```

Replace the reference to the local method `query` with a call to the private method `sql_90days`.

Run the `lockdown` test. It should be passing.

Delete the old code where the `query` string is being built, then rerun the
`lockdown` test. It should still be passing.

Commit your changes.

### Do It Again

Let's do the same thing for the first SQL query string.

Create a method called `sql`, and copy the query string into it.

Verify that the test is passing, delete the old query assignment, and check
that the test is still passing.

Commit your changes.

### Comparing the two SQL queries

Now that the SQL queries are all on their own, let's take a look at how they
compare to each other.

Take a look at the first lines:

```ruby
# sql
"SELECT tags.id, name, count(*) AS count"
```

```ruby
# sql_90days
"SELECT tags.id, tags.name AS name, count(*) AS count"
```

One says `tags.name AS name`. This is an explicit way of saying _the name
column of the tags table, and oh, by the way, make the result be called
**name**_.

The second one just specifies `name`, which implicitly means _the name column of the tags table, and oh, by the way, make the result be called **name**_.

In other words: These are completely equivalent.

We can convert _similar_ into _identical_ by taking one of them and replacing
the other with it. Let's use the more verbose one in case we're dealing with a
join that makes it necessary.

### Identifying Identical

In both queries, lines 2 and 3 look like this:

```ruby
query << " FROM taggings, tags, todos"
query << " WHERE tags.id = tag_id"
```

They are identical, so we can leave them.

### Analyzing Similar

Here are the following lines of code from both queries:

```ruby
# sql
query << " AND taggings.taggable_id = todos.id"
query << " AND todos.user_id="+user.id.to_s+" "
query << " AND taggings.taggable_type='Todo' "
```

```ruby
# sql_90days
query << " AND todos.user_id=? "
query << " AND taggings.taggable_type='Todo' "
query << " AND taggings.taggable_id=todos.id "
```

They are very similar. Let's take it line by line.

The first line extracted from `sql` is this:

```ruby
query << " AND taggings.taggable_id = todos.id"
```

The last line in `sql_90days` is identical to that. The order of
these clauses are irrelevant, so we can move the first of the
three lines in the excerpt of `sql` to be last.

We end up with the following code:

```ruby
# sql
query << " AND todos.user_id="+user.id.to_s+" "
query << " AND taggings.taggable_type='Todo' "
query << " AND taggings.taggable_id = todos.id"
```

```ruby
# sql_90days
query << " AND todos.user_id=? "
query << " AND taggings.taggable_type='Todo' "
query << " AND taggings.taggable_id=todos.id "
```

The last two lines are now identical. Let's get rid of them and focus on the
remaining line:

```ruby
# sql
query << " AND todos.user_id="+user.id.to_s+" "
```

```ruby
# sql_90days
query << " AND todos.user_id=? "
```

This is a pun, and it's not a very good one.

Both lines of code are doing the same thing: interpolating a user id into the
query.

The first just concatenates the user id straight in to the string, and the
second uses `ActiveRecord`'s dynamic conditions that turn things like this:

```ruby
BikeShed.where('color = ?', some_color)
```

into this:

```sql
SELECT bike_sheds.* FROM bike_sheds WHERE color = 'PapayaWhip'
```

It replaces the `?` with the value you send in, and in the process protects
you against [SQL injection attacks](http://guides.rubyonrails.org/security.html#sql-injection).

We aren't afraid of SQL injection happening here, because we're just using the
`user.id` that the database made up for us, but using the dynamic conditions
is a good habit to have, so let's standardize to that version.

### Converting to a Dynamic Condition

Before we make these two lines identical it's helpful to understand how they
are different.

There are two `find_by_sql` calls in the `compute` method, and these are _similar_, but not _identical_:

```ruby
@tags = Tag.find_by_sql(sql).sort_by { |tag| tag.name.downcase }

# ... some code

@tags_90days = Tag.find_by_sql(
  [sql_90days, user.id, @cut_off, @cut_off]
).sort_by { |tag| tag.name.downcase }
```

First, let's reformat the one-liner to be on 3 lines:

```ruby
@tags = Tag.find_by_sql(
  sql
).sort_by { |tag| tag.name.downcase }

# ... some code

@tags_90days = Tag.find_by_sql(
  [sql_90days, user.id, @cut_off, @cut_off]
).sort_by { |tag| tag.name.downcase }
```

It becomes easier to see that the only difference between the two calls
is the middle line, or rather: the arguments that get passed to the
`find_by_sql` method.

To clarify this, let's extract the part that varies.

Assign the arguments to `find_by_sql` to a variable named `params`:

```ruby
params = sql
@tags = Tag.find_by_sql(params).sort_by { |tag| tag.name.downcase }

# ... some code

params = [sql_90days, user.id, @cut_off, @cut_off]
@tags_90days = Tag.find_by_sql(params).sort_by { |tag| tag.name.downcase }
```

The `find_by_sql` incantation is now identical in both cases, so we can ignore
it and focus on the parts that are different:

```ruby
params = sql
# vs
params = [sql_90days, user.id, @cut_off, @cut_off]
```

One is an array, and one is not. When `find_by_sql` receives an array, it
takes the first element of the array and assumes that it is the actual query
string, and then all the rest of the variables are what are known as `bind`
variables because they get _bound_ into the array wherever there are question
marks.

This is important, because you need to have a variable for every question
mark, otherwise it blows up.

On the other hand, it's perfectly fine to have an array with a single element
in it.

```ruby
params = [sql]
# vs
params = [sql_90days, user.id, @cut_off, @cut_off]
```

If you run the `lockdown` test, it should still be passing.

It's also perfectly OK to have `bind` variables that don't actually get used.
It's probably not a good idea to keep them around, but as a temporary step to
keep tests green while preparing code to be changed it's a completely
rational thing to do.

So we can add the `user.id` to the argument list.

```ruby
params = [sql, user.id]
```

The `lockdown` test is still passing`.

And now, finally, we can change the line of code in the `sql` method to be
identical to the one in the `sql_90days` method:

```ruby
query << " AND todos.user_id=? "
```

### Are the Queries Identical Yet?

```ruby
# sql
query = "SELECT tags.id, tags.name AS name, count(*) AS count"
query << " FROM taggings, tags, todos"
query << " WHERE tags.id = tag_id"
query << " AND todos.user_id=? "
query << " AND taggings.taggable_type='Todo' "
query << " AND taggings.taggable_id=todos.id "
query << " GROUP BY tags.id, tags.name"
query << " ORDER BY count DESC, name"
query << " LIMIT 100"
```

```ruby
query = "SELECT tags.id, tags.name AS name, count(*) AS count"
query << " FROM taggings, tags, todos"
query << " WHERE tags.id = tag_id"
query << " AND todos.user_id=? "
query << " AND taggings.taggable_type='Todo' "
query << " AND taggings.taggable_id=todos.id "
query << " AND (todos.created_at > ? OR "
query << "      todos.completed_at > ?) "
query << " GROUP BY tags.id, tags.name"
query << " ORDER BY count DESC, name"
query << " LIMIT 100"
```

There is only one difference between the two queries now:

The `sql_90days` method has 2 lines more than the `sql` method.

```ruby
query << " AND (todos.created_at > ? OR "
query << "      todos.completed_at > ?) "
```

Notice the question marks in those two lines? We have two bind variables:
`@cut_off` and `@cut_off`.

```ruby
params = [sql_90days, user.id, @cut_off, @cut_off]
```

### The Final Two Lines

We are so close to having the two queries be identical, and the only way that
I can think of to make this happen is to wrap the two lines with a conditional
so that if the `@cut_off` is nil, the `sql_90days` query is exactly like the
`sql` query.

This would allow us to use the same string for both queries.

```ruby
def sql_90days(cut_off = nil)
  query = "SELECT tags.id, tags.name AS name, count(*) AS count"
  query << " FROM taggings, tags, todos"
  query << " WHERE tags.id = tag_id"
  query << " AND todos.user_id=? "
  query << " AND taggings.taggable_type='Todo' "
  query << " AND taggings.taggable_id=todos.id "
  if cut_off
    query << " AND (todos.created_at > ? OR "
    query << "      todos.completed_at > ?) "
  end
  query << " GROUP BY tags.id, tags.name"
  query << " ORDER BY count DESC, name"
  query << " LIMIT 100"
end
```

Update the call to `sql_90days` to take the `@cut_off`:

```ruby
params = [sql_90days(@cut_off), user.id, @cut_off, @cut_off]
```

The `lockdown` test should still be passing.

### Reusing the Code

Now, finally, if we call the `sql_90days` method without a `@cut_off` we get
the exact same result as if we had called the `sql` method.

Find this line of code:

```ruby
params = [sql, user.id]
```

and update it to be like this:

```ruby
params = [sql_90days, user.id]
```

The `lockdown` test should still be passing.

The `sql` method is no longer in use. Go ahead and delete it.

Finally, rename `sql_90days` to just be `sql`.

Then run your test and commit your changes.

## I6: Two `TagCloud` Objects

If you've gotten confused and want a clean slate, go ahead and checkout a new branch based on the `cloud.i5` tag.

{% terminal %}
$ git checkout -b iteration6 cloud.i5
{% endterminal %}

Otherwise just create a new branch based on the current state of your code:

{% terminal %}
$ git checkout -b iteration6
{% endterminal %}

### Identifying More Duplication

Notice how the `TagCloud` essentially does the same thing twice.

The first time, it calculates a tag cloud for all TODO items that have ever
existed.

The second time, it calculates a tag cloud for all the TODO items in the past
90 days.

We've managed to reduce the duplication of the SQL query by using the
`cut_off` to determine whether or not the result set should actually be
restricted.

Let's expand on that idea so that the whole tag cloud object either calculates
tags since the beginning of time, or only for a certain time period.

In other words: Let's make two separate tag cloud objects for our two separate
tag clouds.

### Optional Cut Off

In the `TagCloud` initializer, make the `cut_off` parameter optional, with a
default of `nil`:

```ruby
def initialize(user, cut_off = nil)
  @user = user
  @cut_off = cut_off
end
```

Then create two tag clouds in the controller instead of one.

The first does not take a `cut_off`, but the second still does.

The controller method now looks like this:

```ruby
def get_stats_tags
  cloud = TagCloud.new(current_user)
  cloud.compute
  @tags_for_cloud = cloud.tags
  @tags_min = cloud.min
  @tags_divisor = cloud.divisor

  cloud = TagCloud.new(current_user, @cut_off_3months)
  cloud.compute
  @tags_for_cloud_90days = cloud.tags_90days
  @tags_min_90days = cloud.min_90days
  @tags_divisor_90days = cloud.divisor_90days
end
```

This causes the `lockdown` test to fail because we have the wrong number of
`bind` variables for the SQL queries.

We now need to pass in the correct number of bind variables based on whether
or not we actually have a value for `@cut_off` at all.

Change both of the `params` assignments to look like this:

```ruby
params = [sql(@cut_off), user.id]
if @cut_off
  params += [@cut_off, @cut_off]
end
```

The test should be passing again.

In the controller method the first tag cloud is using the first half of the
compute method, whereas the second tag cloud is using the second half of the
compute method.

Change the controller so that none of the calls to `cloud` call methods with
`_90days` in them:

```ruby
def get_stats_tags
  cloud = TagCloud.new(current_user)
  cloud.compute
  @tags_for_cloud = cloud.tags
  @tags_min = cloud.min
  @tags_divisor = cloud.divisor

  cloud = TagCloud.new(current_user, @cut_off_3months)
  cloud.compute
  @tags_for_cloud_90days = cloud.tags
  @tags_min_90days = cloud.min
  @tags_divisor_90days = cloud.divisor
end
```

The `lockdown` test should still be passing.

Having done this we can delete anything in the `TagCloud` referring to
`90days`.

Run the `lockdown` test and commit your changes.

## I7: Sending the tag clouds to the view

If you've gotten confused and want a clean slate, go ahead and checkout a new branch based on the `cloud.i6` tag.

{% terminal %}
$ git checkout -b iteration7 cloud.i6
{% endterminal %}

Otherwise just create a new branch based on the current state of your code:

{% terminal %}
$ git checkout -b iteration7
{% endterminal %}

Open up the `app/views/stats/_tags.html.erb` file. This is the template for
our tag cloud.

Now that we have these handy tag cloud objects in the controller, let's assign
them to instance variables and use them in the view.

Start out by just adding extra lines with the assignments in them so that we
don't have to change all the code in the controller method:

```ruby
def get_stats_tags
  cloud = TagCloud.new(current_user)
  cloud.compute
  @cloud = cloud # <-- this line is new
  @tags_for_cloud = cloud.tags
  @tags_min = cloud.min
  @tags_divisor = cloud.divisor

  cloud = TagCloud.new(current_user, @cut_off_3months)
  cloud.compute
  @cloud_90days = cloud # <-- this line is new
  @tags_for_cloud_90days = cloud.tags
  @tags_min_90days = cloud.min
  @tags_divisor_90days = cloud.divisor
end
```

Assigning extra variables won't change the output, so our test is still
passing.

Let's go back to the view and replace each instance variable one at a time
with a call to the cloud object that we now have available to us.

First, replace `@tags_for_cloud` with `@cloud.tags`.

The tests failed when I did this.

Take a look at the diff of the files, though:

{% terminal %}
$ diff .lockdown/received.html .lockdown/approved.html
{% endterminal %}

The only difference is a single line of extra whitespace. I'm OK with that, so
I'm going to approve the new file:

{% terminal %}
$ cp .lockdown/received.html .lockdown/approved.html
{% endterminal %}

Next replace `@tags_min` with `@cloud.min` and run the test.

It's still passing.

Replace `@tags_divisor` with `@cloud.divisor`.

Run the test.

Replace `@tags_for_cloud_90days` with `@cloud_90days.tags`, and run the
tests.

Replace `@tags_min_90days` with `@cloud_90days.min` and `@tags_divisor_90days`
with `@cloud_90days.divisor`.

Run the tests.

Now we can go back and clean up the controller, because we're not using some
of those instance variables:

```ruby
def get_stats_tags
  @cloud = TagCloud.new(current_user)
  @cloud.compute
  @cloud_90days = TagCloud.new(current_user, @cut_off_3months)
  @cloud_90days.compute
end
```

Run the test and commit your changes.

## I8: Collapsing duplication in the view

If you've gotten confused and want a clean slate, go ahead and checkout a new branch based on the `cloud.i7` tag.

{% terminal %}
$ git checkout -b iteration8 cloud.i7
{% endterminal %}

Otherwise just create a new branch based on the current state of your code:

{% terminal %}
$ git checkout -b iteration8
{% endterminal %}

Let's get those instance variables all the way out of the partial.

Open up `app/views/stats/index.html.erb` and find the line that renders the
`tags` partial:

```erb
<%= render partial: 'tags' -%>
```

Let's pass the tag cloud objects as local variables to the partial.

```erb
<%= render partial: 'tags', locals: { cloud: @cloud, cloud_90days:
@cloud_90days } -%>
```

The test is still passing, but we're not using those local variables.

Go into the `app/views/stats/_tags.html.erb` file and delete the `@`
characters.

When I did this I got another failure, but again it was just a bit of
whitespace. I just went ahead and approved the new version of the output:

{% terminal %}
$ cp .lockdown/received.html .lockdown/approved.html
{% endterminal %}

Now we can call the partial twice from the `index.html.erb` file, once for each tag cloud:

```erb
<%= render partial: 'tags', locals: { cloud: @cloud } -%>
<%= render partial: 'tags', locals: { cloud: @cloud_90days } -%>
```

Before we run the tests, we need to delete the second half of the partial.

Run the tests.

Woah! We have more than just whitespace changes this time.

It looks like we changed the following lines:

```html
<h3>Tag cloud actions in past 90 days</h3>
<p>This tag cloud includes tags of actions that were created or completed in
the past 90 days.</p>
```

```html
<h3>Tag cloud for all actions</h3>
<p>This tag cloud includes tags of all actions (completed, not completed,
visible and/or hidden)</p>
```

We missed a spot.

Two of the lines that we deleted looked like this:

```erb
<h3><%= t('stats.tag_cloud_90days_title') %></h3>
<p><%= t('stats.tag_cloud_90days_description') %></p>
```

and the code that gets called instead looks like this:

```erb
<h3><%= t('stats.tag_cloud_title') %></h3>
<p><%= t('stats.tag_cloud_description') %></p>
```

We need to update the translation key to include the `_90days` bit.

Change the calls to render the partials like this:

```erb
<%= render partial: 'tags', locals: { cloud: @cloud, key: '' } -%>
<%= render partial: 'tags', locals: { cloud: @cloud_90days, key: '_90days' } -%>
```

Also, update the translation keys in the `_tags.html.erb` partial:

```erb
<h3><%= t("stats.tag_cloud#{key}_title") %></h3>
<p><%= t("stats.tag_cloud#{key}_description") %></p>
```

Running the tests again leaves us with only whitespace changes. Approve the
new version of the output:

{% terminal %}
$ cp .lockdown/received.html .lockdown/approved.html
{% endterminal %}

Commit your changes.

## I9: Polishing up the TagCloud

If you've gotten confused and want a clean slate, go ahead and checkout a new branch based on the `cloud.i8` tag.

{% terminal %}
$ git checkout -b iteration9 cloud.i8
{% endterminal %}

Otherwise just create a new branch based on the current state of your code:

{% terminal %}
$ git checkout -b iteration9
{% endterminal %}

### Status

So far we've managed to reduce the amount of code in the controller method
from 50 lines to 4 lines.

We've added a model, `TagCloud`, where we deleted about half of the original
code that was in the controller.

We've also deleted about half of the code in the view layer.

What could possibly be left to do here?

Well, I'm not very happy with how the `TagCloud` class turned out. We can do
better.

There's a lot of bits and pieces here.

First, let's move the `TODO` comment down to the big `sql` method.

Next, create a private method called `levels` and have it return the value 10.

Delete the `levels = 10` line from the compute method.

The `lockdown` test should still be passing.

Let's create a public method called `tags`:

```ruby
def tags
  params = [sql(@cut_off), user.id]
  if @cut_off
    params += [@cut_off, @cut_off]
  end
  @tags = Tag.find_by_sql(params).sort_by { |tag| tag.name.downcase }
end
```

Notice that we've copied the first 5 lines of the `compute` method into it.

Let's get rid of the assignment on the last line:

```ruby
def tags
  params = [sql(@cut_off), user.id]
  if @cut_off
    params += [@cut_off, @cut_off]
  end
  Tag.find_by_sql(params).sort_by { |tag| tag.name.downcase }
end
```

And now in `compute` after the line with the assignment in it, create a new
assignment that calls the tags method:

```ruby
def compute
  params = [sql(@cut_off), user.id]
  if @cut_off
    params += [@cut_off, @cut_off]
  end
  @tags = Tag.find_by_sql(params).sort_by { |tag| tag.name.downcase }
  @tags = tags
  # ...
end
```

Run the test. It passes, so we can delete the 5 lines above our new
assignment.

The tests are passing, but we have some weirdness. We have an `attr_reader`
for `:tags` and we also have a method for `tags`.

We can change the method for `tags` to assign the results of the database
call the first time that it gets called:

```ruby
def tags
  unless @tags
    params = [sql(@cut_off), user.id]
    if @cut_off
      params += [@cut_off, @cut_off]
    end
    @tags = Tag.find_by_sql(params).sort_by { |tag| tag.name.downcase }
  end
  @tags
end
```

Delete the `@tags = tags` assignment in `compute`, and change the remaining
reference to `@tags` in `compute` to `tags`.

Delete the `attr_reader` for `:tags` as well.

Run the test. It should be passing.

Commit your changes.

Take a look at the code that calculates that `min` and `max` tag counts:

```ruby
max, @min = 0, 0
tags.each { |t|
  max = [t.count.to_i, max].max
  @min = [t.count.to_i, @min].min
}
```

First of all, min is always 0, because we never get negative counts out of our
sql query.

So we can simplify:

```ruby
max, @min = 0, 0
tags.each { |t|
  max = [t.count.to_i, max].max
}
```

Next, instead of checking at every step of the way in the iteration, let's
create a variable called `tag_counts` below this section, which is a simple
array of the counts:

```ruby
tag_counts = tags.map {|t| t.count.to_i}
```

Then, we'll get the max from that array:

```ruby
max = tag_counts.max
```

The test is still passing, so we can delete the old code, leaving us with
this `compute` method:

```ruby
def compute
  @min = 0
  tag_counts = tags.map {|t| t.count.to_i}
  max = tag_counts.max

  @divisor = ((max - @min) / levels) + 1
end
```

We can create a public method called min that just returns `0`, and delete
the `attr_reader` for it. Make sure to change `@min` to `min` in the computation
for `@divisor`.

Run the test.

Next, let's extract the `tag_counts` to a private method:

```ruby
def tag_counts
 @tag_counts ||= tags.map {|t| t.count.to_i}
end
```

Run the test.

Extract `max` to a private method:

```ruby
def max
  tag_counts.max
end
```

Run the test.

Extract divisor to a public method:

```ruby
def divisor
  @divisor ||= ((max - min) / levels) + 1
end
```

Run the test.

This leaves us with an empty compute method. Delete it. Remember to delete the
call to compute from the controller as well.

Run the `lockdown` test, as well as the `wip` rake task, and then commit your
changes.

## I10: Polishing Up the View

If you've gotten confused and want a clean slate, go ahead and checkout a new branch based on the `cloud.i9` tag.

{% terminal %}
$ git checkout -b iteration10 cloud.i9
{% endterminal %}

Otherwise just create a new branch based on the current state of your code:

{% terminal %}
$ git checkout -b iteration10
{% endterminal %}

Open up the tag cloud partial `app/views/stats/_tags.html.erb`. There's a big
calculation here:

```erb
(9 + 2*(t.count.to_i-cloud.min)/cloud.divisor)
```

This calculates the relative font size for a tag. A font size is definitely a
view concern, but it seems like part of that calculation wants to live in the tag
cloud itself.

Let's create a method in the `TagCloud` called `relative_size` which takes a tag, and put the non-font part of the calculation into it:

```ruby
def relative_size(tag)
  (t.count.to_i - cloud.min) / cloud.divisor
end
```

`t` is now called `tag`:

```ruby
def relative_size(tag)
  (tag.count.to_i - cloud.min) / cloud.divisor
end
```

And we're inside the cloud object, so we don't need to refer to the `cloud`
variable:

```ruby
def relative_size(tag)
  (tag.count.to_i - min) / divisor
end
```

Update the view to use this:

```erb
(9 + 2*cloud.relative_size(t))
```

This is better, but we still probably shouldn't have the calculation in the
view. Let's create a helper method for it.

Open up the `app/helpers/stats_helper.rb` and add the following:

```ruby
def font_size(cloud, tag)
  9 + 2 * cloud.relative_size(tag)
end
```

Update the view again:

```erb
:style => "font-size: #{font_size(cloud, t)}pt"
```

The `lockdown` test is passing.

`min` and `divisor` are no longer referenced outside of the `TagCloud` so we
can make those methods private.

The `lockdown` test is passing.

Let's run the `rake wip` task to be sure that everything is still good. The
tests are all green.

Pat your self on the back, and commit your code.

## I11: Retrospective

Push your changes up to github.

Go to your page on Code Climate and look at the changes that were introduced.

* Did the overall GPA change?
* What is the complexity metric for the `StatsController`?
* What is the duplication metric for the `StatsController`?
* What is the score of the new `TagCloud` class?
