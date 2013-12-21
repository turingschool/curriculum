---
layout: page
title: Background Jobs with Resque
section: Performance
---

When building websites, it's important to keep your response times down.
Long-running requests tie up server resources, degrade user perception of
your site, and make it hard to manage failures.

There's a solution to this: return a successful response, and then schedule
some computation to happen later, outside the original request/response cycle.

## Do you need a job queue?

How do you identify areas of the application that can benefit from a background
job? Some common areas for asynchronous work:

* Data Processing - e.g. generating thumbnails or resizing images
* 3rd Party APIs - interacting with a service outside of your site
* Maintenance - expiring old sessions, sweeping caches
* Email - a request that causes an email to be sent

Applications with good OO design make it easy to send jobs to workers, poor OO
makes it hard to extract jobs since responsibilities tend to overlap.

While there are various solutions to provide a background job, we'll focus on
using [Resque](https://github.com/resque/resque), the most widely
deployed queuing library.

For this tutorial, clone our blogger advanced repo. You can find it [here](https://github.com/JumpstartLab/blogger_advanced.git).

## Setting up Resque

### Setup Redis

You'll need Redis installed. Assuming you're on MacOS and using Homebrew:

{% terminal %}
$ brew install redis
{% endterminal %}

Follow the instructions in the notes to start Redis on boot, or start it manually with `redis-server`

### Setup Resque

Install Resque by adding `gem 'resque'` to the `Gemfile` and running `bundle`.

## Creating a fake delay

To exemplify how background jobs work, we are going to fake a delayed process. Under the `ArticlesController#create` let's add a `sleep` method that will delay our controller for 5 seconds.

```ruby
class ArticlesController < ApplicationController
  # more code goes here

  def create
    @article = Article.new(params[:article])

    if @article.save
      sleep(5)

      flash[:notice] = "Article was created."
      redirect_to articles_path
    else
      render :new
    end
  end
end
```

Now, launch your app and try to create an article. You'll see that there is a 5 seconds delay.

Let's move that fake process to a background job.

## Writing a Job

A good practice is to create an `app/jobs` folder and store your job classes there. Let's create a `jobs` folder under your `app` folder. Then create a file named `sleeper.rb` under your `app/jobs` folder.

A Resque job is any Ruby class or module with a `perform` class method. Put the following code in your `sleeper.rb` file.

```ruby
class Sleeper
  @queue = :sleep

  def self.perform(seconds)
    sleep(seconds)
  end
end
```

Resque can maintain multiple queues for different job types. By setting the
`@queue` class instance variable, this worker will only look for jobs on the
`:sleep` queue.

## Queueing a Job

Queuing a job in Resque looks like this:

```ruby
Resque.enqueue(Sleeper, 5)
```

The parameters will be serialized as JSON and appended onto the Redis queue
specified in the job class. The above call would be added to the `sleep`
queue with the following JSON:

```text
{
  'class': 'Sleeper',
  'args': [ 5 ]
}
```

Now that we have our fake process in our Sleeper job, we can modify our controller to call our background job instead.

```ruby
class ArticlesController < ApplicationController
  # more code goes here

  def create
    @article = Article.new(params[:article])

    if @article.save
      Resque.enqueue(Sleeper, 5)

      flash[:notice] = "Article was created."
      redirect_to articles_path
    else
      render :new
    end
  end
end
```

Jobs should only need to access your models. If you're tempted to trigger a
controller action, it's a sign that the controller action is holding domain
logic which needs to be pushed down to the model.

When a job is created it gets appended to a list data structure in Redis. A
Resque worker will then try to process the job.

## Monitoring the Resque Queue

Resque provides a Sinatra application as a web interface to monitor the status
of your queues & workers and to view statistics of the instance.

### Setup

The front-end application is not loaded by default, but we can load it in our
routes file.

Open your `config/routes.rb` and mount the application like this:

```ruby
require 'resque/server'

# Of course, you need to substitute your application name here, a block
# like this probably already exists.
MyApp::Application.routes.draw do
  mount Resque::Server.new, at: "/resque"
end
```

Then **restart** your Rails server. Open up `http://localhost:3000/resque` in
a browser to check out the web backend.

### Overview

On the Overview tab you can see a list of the queues and workers. Each queue
shows a count of pending jobs. The list of workers displays what queue(s) each
worker is working on, and the job currently being processed (if any).

![Resque Overview Tab](/images/resque_overview.png)

### Failed

The Failed tab shows jobs which failed along with the exception that was
thrown, an error message, and the line where the error occurred. You can also
kick off jobs to be retried on this page, or remove them from the history of
failed jobs.

![Resque Failed Tab](/images/resque_failed.png)

### Workers

The Workers tab shows a list of all workers and their status. Clicking on a
worker shows the details of the worker including the host, pid, when it was
started, how many jobs its processed, and how many failures it has encountered.

### Stats

The Stats tab displays overall stats of the Resque instance as well as a
listing of all the keys in Redis. Clicking on the keys will show the value of
the key, so this provides a nice quick way to look inside Redis without having
to connect and fire up the command line client.

## Starting Up the Workers

Resque provides rake tasks to start one or many workers. Add `require
'resque/tasks'` in the top of your `Rakefile`. Then, you'll see them added to
your available tasks:

{% terminal %}
$ bundle exec rake -T resque
rake resque:failures:sort  # Sort the 'failed' queue for the redis_multi_queue failure backend
rake resque:work           # Start a Resque worker
rake resque:workers        # Start multiple Resque workers.
{% endterminal %}

You can control these tasks with environment variables:

* `QUEUE` controls which queue will be monitored
* `COUNT` sets the number of workers (only with `resque:workers`)

So, let's startup a worker by running:

{% terminal %}
$ bundle exec rake environment resque:work QUEUE=sleep
{% endterminal %}

Once the rake task starts it will begin processing jobs from the queue. Now go to your app and try to create an article.

Since we put the sleep method in a background job, you will notice that the delay is gone.

## Additional Rake Tasks

If you're in a situation where the worker *doesn't need* access to your Rails
app, skip the `environment` and you'll save a lot of memory/start-up time:

{% terminal %}
$ rake resque:work QUEUE=sleep
{% endterminal %}

### Formatting the Log

If you'd like to change the Resque's log format, create an initializer to do it. Open up
`config/initializers/resque.rb` and put this in it:

```ruby
Resque.logger.formatter = Resque::QuietFormatter.new
```

This is the default. If you'd like to make it verbose, do this instead:

```ruby
Resque.logger.formatter = Resque::VerboseFormatter.new
```

or even

```ruby
Resque.logger.formatter = Resque::VeryVerboseFormatter.new
```

If you really want to see all the gory details. Resque uses a variant of the
standard Ruby logger ([mono_logger](https://rubygems.org/gems/mono_logger))
that's got equivalent behavior. So if you want, you could write your own
formatter to get exactly the logging you'd prefer. See the [standard library logger
documentation](http://www.ruby-doc.org/stdlib-1.9.3/libdoc/logger/rdoc/Logger.html)
for more.

With the `VerboseFormatter`,

{% terminal %}
$ bundle exec rake environment resque:work QUEUE=sleep
*** Checking sleep
*** Found job on sleep
*** got: (Job{sleep} | Sleeper | [5])
*** resque-1.25.1: Processing sleep since 1386736305 [Sleeper]
*** Running before_fork hooks with [(Job{sleep} | Sleeper | [5])]
*** resque-1.25.1: Forked 13978 at 1386736305
*** Running after_fork hooks with [(Job{sleep} | Sleeper | [5])]
*** done: (Job{sleep} | Sleeper | [5])
{% endterminal %}

And with the `VeryVerboseFormatter`,

{% terminal %}
$ bundle exec rake environment resque:work QUEUE=sleep
** [21:35:54 2013-12-10] 14071: Checking sleep
** [21:35:54 2013-12-10] 14071: Found job on sleep
** [21:35:54 2013-12-10] 14071: got: (Job{sleep} | Sleeper | [5])
** [21:35:54 2013-12-10] 14071: resque-1.25.1: Processing sleep since 1386736554 [Sleeper]
** [21:35:54 2013-12-10] 14071: Running before_fork hooks with [(Job{sleep} | Sleeper | [5])]
** [21:35:54 2013-12-10] 14071: resque-1.25.1: Forked 14101 at 1386736554
** [21:35:54 2013-12-10] 14101: Running after_fork hooks with [(Job{sleep} | Sleeper | [5])]
** [21:35:59 2013-12-10] 14101: done: (Job{sleep} | Sleeper | [5])
{% endterminal %}

Since workers will be kicked off on remote servers it will be helpful to
redirect their log output instead of just dumping it to STDOUT to be lost. Do
this in `config/initializers/resque.rb`:

```ruby
Resque.logger = MonoLogger.new(File.open("#{Rails.root}/log/resque.log", "w+"))
Resque.logger.formatter = Resque::QuietFormatter.new
```

And then, in the terminal,

{% terminal %}
$ bundle exec rake environment resque:work QUEUE=sleep
{% endterminal %}

As usual.

## Queuing Calculations

{% include custom/sample_project_advanced.html %}

Start the server, and visit the root page. This is the
`DashboardController#index` which we'll use to illustrate the benefits of
jobs.

### Why Use a Job

The blogger application tracks the total word counts for all articles and all
comments on the dashboard. Currently, it recalculates these values for each
request of the dashboard page.

```ruby
  def show
    @articles = Article.for_dashboard
    @article_count = Article.count
    @article_word_count = Article.total_word_count
    @most_popular_article = Article.most_popular

    @comments = Comment.for_dashboard
    @comment_count = Comment.count
    @comment_word_count = Comment.total_word_count
  end
```

The `total_word_count` methods on `Article` and `Comment` are each implemented as such:

```ruby
  def self.total_word_count
    all.inject(0) {|total, a| total += a.word_count }
  end
```

The result is that each viewing of the dashboard causes a calculation involving
each comment or article to be rerun. This is the sort of potentially slow
operation that should A) be cached, and B) be calculated in the background.
Introducing a Resque job into our application will make this change
relatively simple and straightforward to implement.

## Writing Our Word Count Job

Before we write our custom job class, let's make the Resque Rake tasks
available so that we can run our worker queue later. Create a file
`lib/tasks/resque.rake` and add the following line:

```ruby
require 'resque/tasks'
```

Running `bundle exec rake -T` should show us a list that includes two Resque-related tasks.

We'll want to replace the inline call to `Comment.total_word_count` with
something that is run in the background, i.e., our Resque job. Create a
directory called `app/jobs`, then inside it create a file called
`comment_total_word_count.rb`.

Inside the file let's add the following:

```ruby
class CommentTotalWordCount
  @queue = :total_word_count

  def self.perform
    Comment.total_word_count
  end
end
```

We've moved the call that calculates the total count of words for comments into
a job method, moving the slow operation away from the request-response
cycle, but we haven't stored the result of the calculation anywhere that the
request can retrieve it.

We could store it somewhere in the database, but as of right now there's no
obvious place to put it. A dashboard table of some kind seems pretty
unappealing. Fortunately, a side-benefit of using Resque is that we get access
to a Redis instance for free. Redis is a natural place to cache a value such as
this.

The easiest way to access a Redis server in Ruby is through the `redis` gem.
Although we could add the `redis` gem to our Gemfile, it's not needed because
Resque already has it declared as a dependency. We will, however, need to bring
a Redis endpoint into our Rails application so that we can easily access the
memory store.

Create an initializer file in `config/initializers/redis.rb` and add the
following content:

```ruby
class DataCache
  def self.data
    @data ||= Redis.new(host: 'localhost', port: 6379)
  end

  def self.set(key, value)
    data.set(key, value)
  end

  def self.get(key)
    data.get(key)
  end

  def self.get_i(key)
    data.get(key).to_i
  end
end
```

After a quick restart of the Rails server, we'll now have a globally-available
handle on our Redis store. Although globals are ideally avoided, the `redis`
gem is at least threadsafe by default, so this approach will meet our needs for
now.

With this in place, let's return to our Resque job and store the result of
the word count calculation:

```ruby
class CommentTotalWordCount
  @queue = :total_word_count

  def self.perform
    DataCache.set 'comment_total_word_count', Comment.total_word_count
  end
end
```

Now that we know the name of the Resque queue that our job class is using,
let's start up a Resque worker processor by running one of its built-in Rake
tasks: `bundle exec rake environment resque:work QUEUE=total_word_count`. Note
this will block the terminal it is run in.

We now are able to find the total word count for comments in the background,
but we still need to enqueue the job at some point. The best place to
put this is in the controller, after we make a new comment.

```ruby
class CommentsController < ApplicationController
  def create
    article = Article.find(params[:comment][:article_id])
    comment = article.comments.create(params[:comment])

    Resque.enqueue(CommentTotalWordCount)

    flash[:notice] = "Your comment was added."
    redirect_to article_path(article)
  end
end
```

Now we're storing the current total word count after each comment is created so
that it can be retrieved later. If we move back to the dashboard controller, we
can take advantage of this by removing the call to `Comment.total_word_count`,
replacing it with a Redis query:

```ruby
class DashboardController < ApplicationController
  def show
    @articles = Article.for_dashboard
    @article_count = Article.count
    @article_word_count = Article.total_word_count
    @most_popular_article = Article.most_popular

    @comments = Comment.for_dashboard
    @comment_count = Comment.count
    @comment_word_count = DataCache.get_i('comment_total_word_count')
  end
end
```

### Refactoring to a Cleaner Approach

What we've done so far essentially works, but there are some sloppy aspects
that could be cleaned up. For one, we've leaked information about where
aggregate comment data is stored out of the `Comment` class and into both our
dashboard controller and our job. That's probably not a great idea.

Let's update the comment class to have two methods for the total word count:
one that calculates and stores the total and one that retrieves it. By doing
so, we can move all knowledge of its storage in Redis inside the `Comment`
class. Here's the code:

```ruby
class Comment

  # ...

  def self.update_statistics
    calculate_total_word_count
  end

  def self.calculate_total_word_count
    total = all.inject(0) {|total, a| total += a.word_count }
    DataCache.set 'comment/total_word_count', total
  end

  def self.total_word_count
    DataCache.get_i('comment/total_word_count')
  end
end
```

Now we've wrapped the knowledge of aggregate comment data inside the `Comment`
class. Let's adjust our job accordingly:

```ruby
class CommentTotalWordCount
  @queue = :total_word_count

  def self.perform
    Comment.calculate_total_word_count
  end
end
```

Finally, let's revisit the dashboard controller and put things back the way we
found them:

```ruby
  def show
    @articles = Article.for_dashboard
    @article_count = Article.count
    @article_word_count = Article.total_word_count
    @most_popular_article = Article.most_popular

    @comments = Comment.for_dashboard
    @comment_count = Comment.count
    @comment_word_count = Comment.total_word_count
  end
```

Before we started to implement the job pattern, the
`DasboardController#show` action was unaware of the calculation that
`Comment.total_word_count` entailed. We've come full circle: now it's ignorant
of the background work and caching going on behind the scenes. This is probably
a good sign.

## Going Further

We've created a big savings for each request to view the dashboard by
offloading the calculation of total words count for comments to a job. We're
still incurring a similar penalty for articles, though.

* Update the articles total word count calculation to use the job pattern
  similarly to what we've done for comments
* Our implementation for comments has a race condition when multiple Resque
  workers are running; use the Redis `MULTI` command to help ameliorate this
  problem.

## References

* Resque Gem: https://github.com/resque/resque
* Resque Introduction: https://github.com/blog/542-introducing-resque
* Redis Gem: https://github.com/ezmobius/redis-rb
* Redis documentation: http://redis.io/documentation