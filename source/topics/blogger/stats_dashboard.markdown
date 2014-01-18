---
layout: page
title: Stats Dashboard
section: Blogger
---

When the hard work of composing articles is done blog maintainers often want
to start collecting statistics about their accomplishments. Gathering
information about the total articles published, comments across all the articles,
the most popular article and other details.

We want to be a responsible developer so we are going to build this feature
with tests. This will help ensure that we know that the statistics are correct
when we display them.

The goal of this tutorial is to add a "statistics dashboard" to an existing
blog in a test-driven development way.

<div class="note">
<p>This tutorial is open source. Please contribute fixes or additions to <a href="https://github.com/JumpstartLab/curriculum/blob/master/source/topics/blogger/stats_dashboard.markdown">the markdown source on GitHub.</a></p>
</div>

{% include custom/sample_project_blogger.html %}

## I0: Total Articles

First we want to display the total number of articles that we have written.
This is not a hard statistic to calculate. We want to start with a simple
statistic because we have a lot of other things to learn about testing.

### Creating the First Test

It seems strange to create a test when we have not created the code we want to
test. One suggestion that may be helpful is to imagine that the code is already
written. What would that code look like? What would you name the class? What
would you name the methods?

Immediately you may become concerned about choosing the wrong names for the
class or the methods. The secret to remember is that the choice you make is
not wrong at this moment in time. You are making a decision with the best
knowledge you have at the time. Perhaps also equally important to remember is
that you can always change the names later.

We are interested in gathering together statistics about our blog. So right
now the best name of a class that comes to mind is `Statistics`. So let's
create a test file that we will use to test our `Statistics` class.

So if the name of the class is `Statistics` the convention is to create a test
class that matches it named `StatisticsTest`.

* Create `test/unit/statistics_test.rb` and add the following code to the file:

```ruby
require 'test_helper'

class StatisticsTest < ActiveSupport::TestCase
  test "the truth" do
    assert true
  end
end
```

* Run `rake db:migrate db:test:prepare`
* Run `rake test`


We created a test class in a test file with a single test. Then we prepared
the database in the test environment. Finally we ran the test and saw our result.

This simple test simply tests "the truth", which is to say we expect it to pass.

### Create the First Meaningful Test

Our test for "the truth" is great way to ensure we setup everything correctly
but we need to start testing our `Statistics` object's ability to return to
us the total number of articles for our blog.

It sounds like we need a method on the `Statistics` class that returns the
`total_articles` which is a number of articles within our blog.


* Open `test/unit/statistics_test.rb` and add a new test:

```ruby

  test "total articles returns a count of all the articles for the blog" do
    Article.create title: "First", body: "Body"
    Article.create title: "Second", body: "Body"

    stats = Statistics.new
    assert_equal 2, stats.total_articles
  end

```

* Run `rake test`

The test should be failing. This is great. Now we need to create the class
and the method to ensure the test passes.


### Passing our Test

A trick that developers often use when testing is to write a simple
implementation that does nothing except return a simple value that we think
it should return. This is kind of like the very first test we wrote that ensures
that even the simpliest solution is working before we try to work on a more
complex solution.

* Create `app/models/statistics.rb` and add the following code:

```ruby
class Statistics
  def total_articles
    2
  end
end
```

* Run `rake test`

Our test should now be passing. This is great. Though the answer that our
statistics class is returning is not based on reality. However, we know we
have gotten the test definition correct and the class definition correct.

This may feel silly but it helps ensure that we have not made any small mistakes
while we setup both of these files.

### Passing our Test (for real)

We need the true count of articles that our blog manages. That value can be
quickly returned by asking the `Article` class for the count of articles.

* Open `app/models/statistics.rb` and update the `total_articles` method:

```ruby
class Statistics
  def total_articles
    Article.count
  end
end
```

* Run `rake test`

Our test should still be passing. This is great. Our `Statistics` class now
will return the correct number of articles based on the reality of how many
currently within the blog.

## I1: Total Comments

Similar to the total articles we are also interested in the total number of
comments. So we will need to add a test, make it fail, write a simple solution,
and then re-write a more complex solution.

### Add a Failing Test

* Open `test/unit/statistics_test.rb` and add a new test:

```ruby

  test "total comments returns a count of all the comments for the blog" do
    article = Article.create title: "First", body: "Body"
    article.comments.create author_name: "Commenter", body: "New Comment"

    stats = Statistics.new
    assert_equal 1, stats.total_comments
  end

```

* Run `rake test`

The test should be failing. This is great. Now we need to create the method to
ensure the test passes.

### Write a Simple Solution

* Open `app/models/statistics.rb` and add the `total_comments` method:

```ruby
class Statistics

  # ... total articles ...

  def total_comments
    1
  end
end
```

* Run `rake test`

The test should be passing. This is great. Now we need to change our solution
to be based on the real number of comments for our blog.

### Write the Real Solution

* Open `app/models/statistics.rb` and update the `total_comments` method:

```ruby
class Statistics

  # ... total articles ...

  def total_comments
    Comment.count
  end
end
```

* Run `rake test`

The test should be passing. We now confidently can say our `Statistics` class
returns for us the correct number of comments for our blog.

## I2: Most Popular Article

The article count and comment count are useful but what would be really useful
is the ability to tell which article within our blog has the most comments.
That way we can write more follow up articles to entice more readers to comment.

To find the most popular article we need to look at each article comment count
and compare them selecting the article with the highest comment count.

* Add a failing test

Remember to setup up at least two articles with a differing number of comments.

* Write a simple solution

For a simple solution just return the article you know has the highest number
of comments. So if the last article you added has the most comments you could
use something as simple as the following:

```ruby
Article.last
```

* Write a real solution

Every article has a comments count so we need to sort the articles in that
order. The sorted order is the article with the smallest number of comments
to the article with the largest number of comments.

```ruby
Article.all.sort_by { |article| article.comments.count }.last
```

## I3: Word Count

Now that we have the popularity of our articles and comments out of the way,
we want to also start looking again at our hard work. This time we want to
start to understand how many words we are using to express ourselves. Maybe
we have a certain number of words we want to write for an upcoming
[writing event](http://nanowrimo.org/) or we would simply like to give ourselves
a gold star every few hundred words we complete.

* Write a test that asks for total number of words across all articles in a method
  named `article_word_counts`.

* Write a test that asks for the average word count across all articles in a
  method named `article_average_word_count`

* Write a test that asks for the greatest number of words in a single article
  in a method named `article_max_word_count`

* Write a test that asks for the smallest number of words in a single article
  in a method named `article_min_word_count`

## I4: Building our Dashboard

All of these statistics are great but they have only been able to give us an
indication of the stats in our tests. It is now time for us to get the stats
for our real blog.

Let's add a single dashboard page that will show us all of the statistics for
our blog. First we'll need to add our route, then our controller, load our
statistics, and finally output that data in the view.

* Open `config/routes.rb` and add the "dashboard" route to the routes:

```ruby
Blogger::Application.routes.draw do

  # ... other defined routes ...

  get 'dashboard' => 'dashboard#index'
end
```

* Create `app/controllers/dashboard_controller.rb` and add the following code:

```ruby
class DashboardController < ApplicationController

end
```

* Open `app/controllers/dashboard_controller.rb` and update the index action
  to create an assign a new instance of our statistics object:

```ruby
class DashboardController < ApplicationController
  def index
    @stats = Statistics.new
  end
end
```

* Create the directory `app/views/dashboard`

* Create `app/views/dashboard/index.html.erb` and add the following code:

```erb
<h1>Stats</h1>

<div>
  Total Articles: <%= @stats.total_articles %>
</div>
<div>
  Total Comments: <%= @stats.total_comments %>
</div>
```

* Add the remaining statistics that you would like to have displayed in your
  dashboard.


Now our dashboard is complete. We are able to get a better understanding about
all the hard work we have been doing in a single glance.

It was really great that we were also able to build the `Statistics` class
entirely in the test environment. We should be much more confident that the
class works and will be correct even if we decide to make more changes in the
future.

