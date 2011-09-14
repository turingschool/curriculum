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

Email is an easy example to visualize.  Suppose a contact page has a form to send an email.  If the controller tries to send the email via `sendmail` before sending the response, the user may have an above average wait before they see a response.  The content of the response to sending this form usually contains a message saying something simple like "The email has been sent".  The response doesn't depend on the email being sent so it's a perfect example of something to move into a background job.  The controller should just take the form, validate it, queue the job to send the email, and send a response to the user.

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

* https://github.com/blog/542-introducing-resque
