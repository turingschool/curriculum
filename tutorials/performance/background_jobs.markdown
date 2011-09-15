# Background Jobs

A background job is a chunk of work to be executed outside of the request lifecycle.  Their purpose is to offload work that may take a while to complete out of a request, since we want to return content to the user as fast as possible.

Most applications have some requests that take a relatively long time to complete.  This may be for a number of reasons, but commonly there is too much work being in the request - including work that isn't critical to the repsonse being prepared for the user's request.

If some of the work can be set aside to be performed later, then moving it into a background job will allow the application to focus on responding to the user as quickly as possible.  Anything that can be done asynchronously should be done so.

While there are various solutions to provide a background job, we'll focus on how to implement Background Jobs using [Resque](https://github.com/defunkt/resque).

## Finding An Asynchronous Job

How do you identify areas of the application that can benefit from a background job?  Some common areas for asynchronous work:

* Data Processing - e.g. generating thumbnails or resizing images
* 3rd Party APIs - interacting with a service outside of your site
* Maintenance [TODO: example?]
* Email - a request that causes an email to be sent

It may be challenging to segregate work that can be done asynchronously from critical code to the request.  Applications with good OO design make it easy to send jobs to workers, poor OO makes it hard to extract jobs since responsibilities tend to overlap.

Email is an easy example to visualize.  Suppose a contact page has a form to send an email.  If the controller tries to send the email via `sendmail` before sending the response, the user may have an above average wait before they see a response.  The content of the response to sending this form usually contains a message saying something simple like "The email has been sent".  The response doesn't depend on the email being sent so it's a perfect example of something to move into a background job.  The controller should just focus on being like most controllers: pass the posted parameters to a model and send a response.  The model will take the form's parameters, validate them, queue the job to send the email, and send a response to the user.

## Setting up Resque

Installing Resque in the project is as easy as adding `gem "resque"` to the `Gemfile` and running `bundle`.  Next add an initializer that requires resque and optionally configures how to connect to Redis (the configuration is only necessary if not connecting on localhost:6379 and using database 0):

```ruby
 # config/initializers/resque.rb
require 'resque'
Resque.redis = 'localhost:6379:1/myns'
```

The connection string takes a variety of options:

1. A 'hostname:port' String
2. A 'hostname:port:db' String (to select the Redis db)
3. A 'hostname:port/namespace' String (to set the Redis namespace)
4. A Redis URL String 'redis://host:port'
5. An instance of `Redis`, `Redis::Client`, `Redis::DistRedis`, or `Redis::Namespace`.

No. 4 is almost identical to the string format in `Redis-Store`, however it cannot specify a namespace in this form.  No. 3 should be used to specify a namespace as in the example above.  If no namespace is specified the keys in Redis are prefixed with `resque:`.

## Writing a Worker

A Resque worker is just a class or module with a `perform` class method.  Here's what an email sender might look like:

```ruby
class Emailer
  @queue = :emails
  def self.perform(to, subject, body)
    # possibly long-running code to send the email
    # ...
  end
end
```

The `@queue` variables allows different jobs to go on different queues.  A common use case is to have separate queues for different priority levels, so that jobs on higher priority queues will be run before jobs with a lower priority.

( Where do you store the files in the project? ) [TODO: not sure what your preferences are]

Practice good OO design when writing a Resque worker.  Workers should be able to interact with the application's models, but probably not much else.

( What parts of the system can/should you access from a worker? Models => yes, everything else => probably not)

## Job Lifecycle

When a job is created it gets appended to a list in redis.  At some point in time, a Resque worker will try to process the job.  Resque keeps track of when jobs fail so that they may be retried, but if the job finishes without error the worker will move onto the next job and mark the previous one as completed.

( Extended example of a job being done ) [Isn't that going to be shown in the sections below?]

### Monitoring the Resque Queue

Resque provides a Sinatra application as a web interface to monitor the status of your queues & workers and to view statistics of the instance.  The sections below describe the tabs in the web interface and what each does.

#### Overview

On the Overview tab you can see a list of the queues and workers.  Each queue shows how many remainig pending jobs there are.  The list of workers displays what queue(s) each worker is working on, and the job currently being processed (if any).

![Resque Overview Tab](/images/resque_overview.png)

#### Working

The Working tab just displays the bottom portion of the Overview tab.

#### Failed

The Failed tab shows jobs which failed along with the exception that was thrown, an error message, and the line where the error occurred.  You can also kick off jobs to be retried on this page, or remove them from the history of failed jobs.

![Resque Failed Tab](/images/resque_failed.png)

#### Queues

The Queues tab just displays the top portion of the Overview tab.

#### Workers

The Workers tab shows a list of all workers and their status.  Clicking on a worker shows the details of the worker including the host, pid, when it was started, how many jobs its processed, and how many failures it has encountered.

#### Stats

The Stats tab displays overall stats of the Resque instance as well as a listing of all the keys in Redis.  Clicking on the keys will show the value of the key, so this provides a nice quick way to look inside Redis without having to connect and fire up the command line client.

### Queuing a Job

Queuing a job in Resque is also simple:

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

Jobs should only be queued from within a model.  Queuing from a controller breaks encapsulation.

### Starting the Workers

Resque provides rake tasks to start one or many workers.  Simply add `require 'resque/tasks'` in the top of your `Rakefile`:

```text
$> rake -T resque
rake resque:work     # Start a Resque worker
rake resque:workers  # Start multiple Resque workers.
```

If you need to connect to Redis with non-default settings then a `resque:setup` task will need to be added in the `Rakefile` to specify the connection string as was done in the Rails initializer.

```ruby
...
require 'resque/tasks'
task "resque:setup" do
  Resque.redis = 'localhost:6379:1/myns'
end
...
```

The `work` rake task can now be run and the QUEUE environment variable will tell the worker what queue to work off of.  The `workers` task will read a COUNT environment variable and spin up that many workers.  Setting the VERBOSE environment variable to true will turn on verbose output for the worker.

```text
$> QUEUE=emails rake resque:work
*** Starting worker hostname.local:28372:emails
```

### The Work Happens

Once the rake task starts it will begin processing jobs from the queue.  If `VERBOSE=true` is not set in the environment you will not see any output on the command line, regardless of whether the job failed or succeeded.  If verbosity is turned on, then the console will show any output sent from the job via things like `puts`, as well as when it started, finished, or failed a job:

```text
$> VERBOSE=true QUEUE=emails rake resque:work
*** got: (Job{emails} | Emailer | ["person@example.com", "Sample Subject", "Email being sent from Resque"])
*** done: (Job{emails} | Emailer | ["person@example.com", "Sample Subject", "Email being sent from Resque"])

*** got: (Job{emails} | Emailer | ["fail job"])
*** (Job{emails} | Emailer | ["fail job"]) failed: #<RuntimeError: exception thrown>
```

If VERBOSE isn't providing enough information there's also a VVERBOSE environment variable to enable *very verbose* logging.  Turning this on helps illustrate exactly what a worker is doing:

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
...
```

Since workers will be kicked off on remote servers it will be helpful to redirect their log output instead of just dumping it to STDOUT to be lost:

```text
$> VVERBOSE=true QUEUE=emails rake resque:work >> log/worker.log
```

### Job Feedback/Review


( Through the web interface )
( What do you see, can you trigger follow up jobs, etc )

## Worker Considerations

( Do they need to have all of rails loaded? )
( How do you know how many workers to spin up )
( Maybe mention that gem that can scale Heroku workers up and down as needed)

## References

* https://github.com/defunkt/resque
* https://github.com/blog/542-introducing-resque
