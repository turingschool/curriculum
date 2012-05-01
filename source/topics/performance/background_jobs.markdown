---
layout: page
title: Background Jobs with Resque
section: Performance
---

A background job is a chunk of work to be executed outside of the request lifecycle.  Their purpose is to offload work that may take a while to complete so we can respond to the user as quickly as possible.

While there are various solutions to provide a background job, we'll focus on using [Resque](https://github.com/defunkt/resque).

## Finding An Asynchronous Job

How do you identify areas of the application that can benefit from a background job?  Some common areas for asynchronous work:

* Data Processing - e.g. generating thumbnails or resizing images
* 3rd Party APIs - interacting with a service outside of your site
* Maintenance - expiring old sessions, sweeping caches
* Email - a request that causes an email to be sent

Applications with good OO design make it easy to send jobs to workers, poor OO makes it hard to extract jobs since responsibilities tend to overlap.

### Sending Email

Email is an easy example to visualize.

Suppose a contact page has a form to send an email.  If the controller tries to send the email via `sendmail` before sending the response, the user may wait several seconds before they see a response.  The content of the response to sending this form usually contains a message saying something simple like "The email has been sent".  

The response doesn't actually depend on the email being sent, so it can be moved into a background job.  The controller can pass the posted parameters to a model, then the model will take the form's parameters, validate them, queue the job to send the email, and send a response to the user.

## Setting up Resque

Install Resque by adding `gem "resque"` to the `Gemfile` and running `bundle`.

Next, create an initializer that requires resque configures how to connect to Redis. For example, in `config/initializers/resque.rb`:

```ruby
require 'resque'
Resque.redis = 'localhost:6379:1/myns'
```

The connection string takes a several options:

1. `hostname:port`, here `localhost:6379`
2. `:db`, here `:1` to select the Redis database
3. `/namespace` to set the Redis namespace

If no namespace is specified the keys in Redis are prefixed with `resque:`.

## Writing a Worker

A Resque worker is any Ruby class or module with a `perform` class method.  Here's what an email sender might look like:

```ruby
class Emailer
  @queue = :emails
  def self.perform(to, subject, body)
    # possibly long-running code to send the email
    # ...
  end
end
```

Resque can maintain multiple queues for different job types. By setting the `@queue` instance variable, this worker will only look for jobs on the `:emails` queue.

### Storing Workers

A good practice is to create an `app/workers` folder and store any worker classes there.

### Worker Design

Workers should only need to access your models. If you're tempted to trigger a controller action, it's a sign that the controller action is holding domain logic which needs to be pushed down to the model layer.

## Job Lifecycle

When a job is created it gets appended to a list data structure in redis.  A Resque worker will then try to process the job. 

### Monitoring the Resque Queue

Resque provides a Sinatra application as a web interface to monitor the status of your queues & workers and to view statistics of the instance.  

#### Setup

The front-end application is not loaded by default, but we can load it using an initializer. Create `config/initializers/resque.rb` and add this require:

```ruby
require 'resque/server'
```

Open your `config/routes.rb` and mount the application like this:

```ruby
mount Resque::Server.new, :at => "/resque"
```

Then **restart** your Rails server.

#### Overview

On the Overview tab you can see a list of the queues and workers.  Each queue shows a count of pending jobs.  The list of workers displays what queue(s) each worker is working on, and the job currently being processed (if any).

![Resque Overview Tab](/images/resque_overview.png)

#### Failed

The Failed tab shows jobs which failed along with the exception that was thrown, an error message, and the line where the error occurred.  You can also kick off jobs to be retried on this page, or remove them from the history of failed jobs.

![Resque Failed Tab](/images/resque_failed.png)

#### Workers

The Workers tab shows a list of all workers and their status.  Clicking on a worker shows the details of the worker including the host, pid, when it was started, how many jobs its processed, and how many failures it has encountered.

#### Stats

The Stats tab displays overall stats of the Resque instance as well as a listing of all the keys in Redis.  Clicking on the keys will show the value of the key, so this provides a nice quick way to look inside Redis without having to connect and fire up the command line client.

### Queuing a Job

Queuing a job in Resque looks like this:

```ruby
Resque.enqueue(Emailer, "person@example.com", "Sample Subject", "Email being sent from Resque")
```

The parameters will be serialized as JSON and appended onto the Redis queue specified in the job class.  The above call would be added to the `emails` queue with the following JSON:

```text
{
  'class': 'Emailer',
  'args': [ 'person@example.com', 'Sample Subject', 'Email being sent from Resque' ]
}
```

Given that workers do "business logic" and that logic belongs in the model layer, jobs should only be queued from within model methods.

### Starting Up the Workers

Resque provides rake tasks to start one or many workers. Add `require 'resque/tasks'` in the top of your `Rakefile`. Then, you'll see them added to your available tasks:

```
$> rake -T resque
rake resque:work     # Start a Resque worker
rake resque:workers  # Start multiple Resque workers.
```

You can control these tasks with environment variables:

* `QUEUE` controls which queue will be monitored
* `COUNT` sets the number of workers
* `VERBOSE` will turn on verbose output

So, to startup an email worker, you might run:

```text
$> QUEUE=emails COUNT=3 VERBOSE=false rake resque:workers
*** Starting worker hostname.local:28372:emails
*** Starting worker hostname.local:28372:emails
*** Starting worker hostname.local:28372:emails
```

### The Work Happens

Once the rake task starts it will begin processing jobs from the queue.  

If `VERBOSE=true` is not set in the environment you will not see any output on the command line, regardless of whether the job failed or succeeded.  If verbosity is turned on, then the console will show any output sent from the job via things like `puts`, as well as when it started, finished, or failed a job:

```text
$> VERBOSE=true QUEUE=emails rake resque:work
*** got: (Job{emails} | Emailer | ["person@example.com", "Sample Subject", "Email being sent from Resque"])
*** done: (Job{emails} | Emailer | ["person@example.com", "Sample Subject", "Email being sent from Resque"])

*** got: (Job{emails} | Emailer | ["fail job"])
*** (Job{emails} | Emailer | ["fail job"]) failed: #<RuntimeError: exception thrown>
```

If VERBOSE isn't providing enough information there's also a `VVERBOSE` environment variable to enable *very verbose* logging.  Turning this on helps illustrate exactly what a worker is doing:

```text
$> VVERBOSE=true QUEUE=emails rake resque:work
** [20:12:09 2011-09-14] 28695: Starting worker hostname.local:28695:emails
** [20:12:09 2011-09-14] 28695: Registered signals
** [20:12:09 2011-09-14] 28695: Checking emails
** [20:12:09 2011-09-14] 28695: Sleeping for 5.0 seconds
** [20:12:09 2011-09-14] 28695: resque-1.19.0: Waiting for emails
** [20:12:14 2011-09-14] 28695: Checking emails
** [20:12:14 2011-09-14] 28695: Sleeping for 5.0 seconds
** [20:12:14 2011-09-14] 28695: resque-1.19.0: Waiting for emails
```

Since workers will be kicked off on remote servers it will be helpful to redirect their log output instead of just dumping it to STDOUT to be lost:

```text
$> VVERBOSE=true QUEUE=emails rake resque:work >> log/worker.log
```

## Trying it Out

{% include custom/sample_project_advanced.html %}

Start the server, and visit the root page. This is the `DashboardController#index` which we'll use to illustrate the benefits of workers.

### Why Use a Worker

The blogger application tracks the total word counts for all articles and all comments on the dashboard. Currently, it recalculates these values for each request of the dashboard page.

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

The result is that each viewing of the dashboard causes a calculation involving each comment or article to be rerun. This is the sort of potentially slow operation that should A) be cached, and B) be calculated in the background. Introducing a Resque worker into our application will make this change relatively simple and straightforward to implement.

## Writing Our Word Count Worker

Before we write our custom worker class, let's make the Resque Rake tasks available so that we can run our worker queue later. Create a file `lib/tasks/resque.rake` and add the following line:

```ruby
require 'resque/tasks'
```

Running `rake -T` should show us a list that includes two Resque-related tasks.

We'll want to replace the inline call to `Comment.total_word_count` with something that is run in the background, i.e., our Resque worker. Create a directory called `app/workers`, then inside it create a file called `comment_total_word_count.rb`.

Inside the file let's add the following:

```ruby
class CommentTotalWordCount
  @queue = :total_word_count
  def self.perform
    Comment.total_word_count
  end
end
```

We've moved the call that calculates the total count of words for comments into a worker method, moving the slow operation away from the request-response cycle, but we haven't stored the result of the calculation anywhere that the request can retrieve it.

We could store it somewhere in the database, but as of right now there's no obvious place to put it. A dashboard table of some kind seems pretty unappealing. Fortunately, a side-benefit of using Resque is that we get access to a Redis instance for free. Redis is a natural place to cache a value such as this.

The easiest way to access a Redis server in Ruby is through the `redis` gem. Although we could add the `redis` gem to our Gemfile, it's not needed because Resque already has it declared as a dependency. We will, however, need to bring a Redis endpoint into our Rails application so that we can easily access the memory store.

Create an initializer file in `config/initializers/redis.rb` and add the following content:

```ruby
$redis = Redis.new(:host => 'localhost', :port => 6379)
```

After a quick restart of the Rails server, we'll now have a globally-available handle on our Redis store. Although globals are ideally avoided, the `redis` gem is at least threadsafe by default, so this approach will meet our needs for now.

With this in place, let's return to our Resque worker and store the result of the word count calculation:

```ruby
class CommentTotalWordCount
  @queue = :total_word_count
  def self.perform
    $redis.set 'comment_total_word_count', Comment.total_word_count
  end
end
```

Now that we know the name of the Resque queue that our worker class is using, let's start up a Resque worker processor by running one of its built-in Rake tasks: `QUEUE=total_word_count rake environment resque:work`. Note this will block the terminal it is run in.

We now are able to find the total word count for comments in the background, but we still need to enqueue the worker job at some point. The natural place to do this is after the creation of a new comment. Let's add an `after_create` hook to `app/models/comment.rb`:

```ruby
class Comment
  ...

  after_create :enqueue_total_word_count

  ...

  private

  def enqueue_total_word_count
    Resque.enqueue(CommentTotalWordCount)
  end
end
```

Now we're storing the current total word count after each comment is created so that it can be retrieved later. If we move back to the controller, we can take advantage of this by removing the call to `Comment.total_word_count`, replacing it with a Redis query:

```ruby
  def show
    @articles = Article.for_dashboard
    @article_count = Article.count
    @article_word_count = Article.total_word_count
    @most_popular_article = Article.most_popular

    @comments = Comment.for_dashboard
    @comment_count = Comment.count
    @comment_word_count = $redis.get('comment_total_word_count').to_i
  end
```

### Refactoring to a Cleaner Approach

What we've done so far essentially works, but there are some sloppy aspects that could be cleaned up. For one, we've leaked information about where aggregate comment data is stored out of the `Comment` class and into both our dashboard controller and our worker. That's probably not a great idea.

Let's update the comment class to have two methods for the total word count: one that calculates and stores the total and one that retrieves it. By doing so, we can move all knowledge of its storage in Redis inside the `Comment` class. Here's the code:

```ruby
class Comment
  ...

  after_create :enqueue_total_word_count

  ...

  def self.calculate_total_word_count
    total = all.inject(0) {|total, a| total += a.word_count }
    $redis.set 'comment/total_word_count', total
  end

  def self.total_word_count
    $redis.get('comment/total_word_count').to_i
  end

  private

  def enqueue_total_word_count
    Resque.enqueue(CommentTotalWordCount)
  end
end
```

Now we've wrapped the knowledge of aggregate comment data inside the `Comment` class. Let's adjust our worker accordingly:

```ruby
class CommentTotalWordCount
  @queue = :total_word_count
  def self.perform
    Comment.calculate_total_word_count
  end
end
```

Finally, let's revisit the dashboard controller and put things back the way we found them:

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

Before we started to implement the worker pattern, the the `DasboardController#show` action was unaware of the calculation that `Comment.total_word_count` entailed. We've come full circle: now it's ignorant of the background work and caching going on behind the scenes. This is probably a good sign.

## Going Further

We've created a big savings for each request to view the dashboard by offloading the calculation of total words count for comments to a worker. We're still incurring a similar penalty for articles, though.

* Update the articles total word count calculation to use the worker pattern similarly to what we've done for comments
* Our implementation for comments has a race condition when multiple Resque workers are running; use the Redis `MULTI` command to help ameliorate this problem

### Configuring the Resque Dashboard in a Rails Application

Resque's built-in dashboard can be embedded directly into our Rails application without much hassle. First, add the following code into `config/routes.rb`:

```ruby
mount Resque::Server.new, :at => "/resque"
```

Then add `require 'resque/server'` to either an initializer or to the top of `routes.rb`. Restart the app and then browse to `http://localhost:3000/resque` to view the Resque dashboard.


## References

* Resque Gem: https://github.com/defunkt/resque
* Resque Introduction: https://github.com/blog/542-introducing-resque
* Redis Gem: https://github.com/ezmobius/redis-rb
* Redis documentation: http://redis.io/documentation
