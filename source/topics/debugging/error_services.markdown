---
layout: page
title: Error Tracking Services
section: Debugging
---

Why bother with an external error tracking service? There are several reasons.

1. When your application generates errors it is a sign you don't understand what is happening or there are scenarios you didn't expect. Therefore, your application is untrustworthy.
2. If your app is running across multiple services it'll be tricky to collect errors in a single place.
3. Writing a system to send you an email when an error occurs is easy. But errors tend to happen in bunches. Do you want to get 900 emails in the span of a few seconds?

{% include custom/sample_project_follow_along.html %}

<div class="note">
  <p>To follow the examples in this section you'll need to have an application running on Heroku.</p>
</div>

## Exceptional

There are two main players in error tracking: [Exceptional](http://www.getexceptional.com/) and [Airbrake](http://airbrakeapp.com/). 

<div class="opinion">
<p>I've used both and don't have a strong preference, but friends report experience with Airbrake itself being unreliable. So let's look at Exceptional!</p>
</div>

### Adding Through Heroku

Exceptional is a $9/month add-on through Heroku. Run this instruction from your project directory:

```bash
heroku addons:add exceptional:premium
```

Everything is taken care of for you! Exceptional will create an account if there isn't one already associated with your Heroku account.

### Accessing Exceptional

Now, the fun part. Raise an exception! Figure out a way to generate a 500 error. If all else fails, just check in a controller with a `raise` instruction, push it live, then trigger the action.

Check the email address associated with your Heroku account. If you don't see it yet, try navigating to the Exceptional admin screen:

* Via direct login at http://getexceptional.com
* Via Heroku:
  * View your app's page in your Heroku admin interface
  * Click the Add-ons button
  * Click Exceptions
  * Click the *Go to Exceptional Admin* link
  
### Reading an Exception

Exceptional will show you how many times the exception has occurred (in red with a star) along with the stack trace. You can view the details of the individual request(s) like the URL, params, and user agent.

Notice the bar that says *"Show Session, HTTP Headers, Environment"* and click it for way more information!

### Resolving Exceptions

Once you fix your code, just click the *Close* button up on the top right.

That's about it!