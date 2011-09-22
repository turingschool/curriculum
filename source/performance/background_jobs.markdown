# Background Jobs

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

Instal Resque by adding `gem "resque"` to the `Gemfile` and running `bundle`.  

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

Resque provides a Sinatra application as a web interface to monitor the status of your queues & workers and to view statistics of the instance.  Here's a quick overview of the web interface:

#### Overview

On the Overview tab you can see a list of the queues and workers.  Each queue shows a count of pending jobs.  The list of workers displays what queue(s) each worker is working on, and the job currently being processed (if any).

![Resque Overview Tab](/images/resque_overview.png)

[TODO: Check image]

#### Failed

The Failed tab shows jobs which failed along with the exception that was thrown, an error message, and the line where the error occurred.  You can also kick off jobs to be retried on this page, or remove them from the history of failed jobs.

![Resque Failed Tab](/images/resque_failed.png)

[TODO: Check image]

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

## References

* Resque Gem: https://github.com/defunkt/resque
* Resque Introduction: https://github.com/blog/542-introducing-resque
