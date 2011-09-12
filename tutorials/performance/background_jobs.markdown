# Background Jobs

( Why use background jobs )
( It's why most apps are slow)
( Focus on returning to the user as quickly as possible -- everything that can possibly be async should be)

## Finding An Asynchronous Job

( How do you find work that can be broken out? )
( Common areas: data processing, 3rd party api, maintenance, email )
( Applications with good OO design make it easy to send jobs to workers, poor OO makes it hard to extract jobs )

## Writing a Worker

( What does a worker look like? )
( Where do you store the files in the project? )
( What parts of the system can/should you access from a worker? Models => yes, everything else => probably not)

## Job Lifecycle

( Extended example of a job being done )

### Monitoring the Resque Queue

( Web Interface, what can they see, click on, etc )

### Queuing a Job

( How do you queue a job )
( Where should the job be queued? _ONLY_ from a model. Queuing from a controller breaks encapsulation )

### The Work Happens

( What does the worker access when it runs )
( Where are errors/messages logged by default? )
( How can you redirect that log output?)

### Job Feedback/Review

( Through the web interface )
( What do you see, can you trigger follow up jobs, etc )

## Worker Considerations

( Do they need to have all of rails loaded? )
( How do you know how many workers to spin up )
( Maybe mention that gem that can scale Heroku workers up and down as needed)

## References