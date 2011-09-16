# Automated Tasks with Cron and Rake

( Why do we need systems tasks? Doing anything outside the scope of request/response. Maintenance, calculations, generation, etc )

While much of your application is built to (swiftly) respond to a web request, there are many scenarios where you would like to access and run pieces of your application outside of that request/response cycle.

You may want to run maintenance tasks, periodic calculations, or reporting in your production environment, while in development, you may want to trigger your full test suite to run.

## Rake

( What is rake all about: ruby make, useful for building systems operations )

The rake gem is Ruby's answer to [TODO: fill in the blank] and is one of the basic building blocks of most Ruby systems. (It's so core that rvm installs it by default for you in each environment you create.) [TODO: Fact check]

rake is a 'ruby build program with capabilities similar to make' providing you a convenient way to make your Ruby libraries executable on your system. (And by you from the command line.) 


### Rake Tasks

( We write rake tasks to do stuff )
( List out the built-in rake tasks with rake -T )
( Explain how they can be namespaced like the db:XYZ tasks)

In order to utilize your Ruby and Rails code through rake, you write rake _tasks_, which can be invoked by calling:

`rake my_task_name`

Thankfully, you aren't expected to memorize every rake task your application has available. You can view all your application's rake tasks using:

`rake -T`

And can even limit your results using:

`rake -T text_to_match`

Even with these display options, it's not hard to imagine that a large application could quickly turn into a hot mess of rake tasks. To combat this, rake provides the ability to _namespace_ your tasks. Some examples built into Rails are the `rake db:ABC` and `rake tmp:XYZ` tasks.


### Rakefile

( Look at the built in Rake file )
( Explain how the .load_tasks method will look in lib/tasks/ for your custom rake file(s) )
( Show an example Rakefile )

### Rake Strategy

( It's typically easiest, in the long run, to not write a lot of logic in your rake tasks )
( Instead, build classes in /app/workers/blah.rb and call methods on those workers from the rake task )
( This way you can easily share functionality/responsibility with Resque workers )
( I don't know: Show a sample worker class that could be used by both Resque and a rake task)
( Show the rakefile / usage that could trigger that task )

### Flexible Tasks

( Show the normal usage of a rake task no param)
( but what about when we want to pass in or read parameters? )
( we can customize it with... )

#### Command Line Arguments

( Show how you add command line arguments to a task )
( And how you use them from the command line )

#### Environment Variables

( Show how to add an ENV variable )
( How to read it in general )
( In workers, create a Config class that reads those variables )
( Then in the Rake task, call Config to get the values needed )
( Ex: maybe the current system name, IP address, RailsEnv, something like that )

## Scheduled Tasks

( Now that you have tasks that can be run from the command line, you want to automate them )

### Creating a Crontab

( make one for the current user )

### Calling a Rake Task

( explain that cron is just like typing the instruction into the terminal )
( EXCEPT that it runs in a different environment )
( so PATH and such might be jacked up )
( cron jobs should "assume nothing" about the current env -- use full paths and such )

### Timing

( Explain how cron can schedule based on second, minute, etc )
( It is kind of like a regex )
( Explain the layout of the timing )
( Link to http://www.openjs.com/scripts/jslibrary/demos/crontab.php which can help generate the timing, or something better if you know of one )
( Watch out: if you schedule tasks really close together a new one could start before the previous one finishes, causing a race for resources and your system is going DOWN! )

### Bringing it All Together

( combine the timing with the rake instruction in a composite crontab file )

### Logging

( What's a good practice for logging from Cron? I don't really know. Just piping it somewhere? )

## References

* Crontab Timing Generator: http://www.openjs.com/scripts/jslibrary/demos/crontab.php