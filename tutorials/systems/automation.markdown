# Automated Tasks with Cron and Rake

While much of your application is built to (swiftly) respond to a web request, there are many scenarios where you would like to access and run pieces of your application outside of that request/response cycle.

You may want to run maintenance tasks, periodic calculations, or reporting in your production environment, while in development, you may want to trigger your full test suite to run.

## Rake

The rake gem is Ruby's most widely accepted solution for performing these types of tasks. (It's so widely accepted that rvm installs rake by default for you in each environment you create.) [TODO: Fact check]

rake is a 'ruby build program with capabilities similar to make' providing you a convenient way to make your Ruby libraries executable on your system. (And by you from the command line.) 

### Rake Tasks

In order to utilize your Ruby and Rails code through rake, you write rake _tasks_, which can be invoked by calling:

`rake my_task_name`

Thankfully, you aren't expected to memorize every rake task your application has available. You can view all your application's rake tasks using:

`rake -T`

And can even limit your results using:

`rake -T text_to_match`

Even with these display options, it's not hard to imagine that a large application could quickly turn into a hot mess of rake tasks. To combat this, rake provides the ability to _namespace_ your tasks. Some examples built into Rails are the `rake db:ABC` and `rake tmp:XYZ` tasks.

### Rakefile

Now you may be wondering where `rake -T` finds all these tasks to display. They are made available by the presence of a _Rakefile_ and Rails comes with a pretty powerful (and short) one built in.

[TODO: This is the 3.1 Rakefile. The 3.0 is a little different...which one to use?]

```
#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

MyRailsApplication::Application.load_tasks
```

As you can read from the comments, this Rakefile sets the stage for you to add your own rake tasks to your applicaiton in the _lib/tasks_. This is possible thanks to the 'load_tasks' call made to your application object. (MyRailsApplication::Application#load_tasks calls super to Engine#load_task which loads any .rake file in lib/tasks) [TODO: This feels like way too much detail. Remove the parenthetical?]

A sample rake file in lib/tasks might look something like this:

```ruby
# lib/tasks/myrailsapp.rake
namespace :myrailsapp do
  desc "Purge stale entries from audits table"
  task :purge_audits => :environment do
    puts "Purging old audits..."
    Audit.purge
  end

  desc "Run monthly TPS report"
  task :monthly_report => :environment do
    puts "Generate TPS report CSV..."
    TpsWorker.export_csv
  end
end
```

You would then be able to call `rake myrailsapp:purge_audits` and `rake myrailsapp:monthly_report`

### Rake Strategy

( It's typically easiest, in the long run, to not write a lot of logic in your rake tasks )
( Instead, build classes in /app/workers/blah.rb and call methods on those workers from the rake task )
( This way you can easily share functionality/responsibility with Resque workers )
( I don't know: Show a sample worker class that could be used by both Resque and a rake task)
( Show the rakefile / usage that could trigger that task )

While you may be tempted to throw the kitchen sink into your rake tasks, you will probably find in the long run it's best to keep your tasks simple and store your logic elsewhere. (Many developers keep these in /app/workers/xyz.rb) An example might look something like this:

```ruby
# /app/workers/tps_worker.rb
class TpsWorker
  def export_csv
    Tps.all.to_csv
  end
end
```

The benefit of this is more than just a cleaner rake file, you'll have methods that can be used elsewhere in your application, like in a Resque job. [TODO: Were we wanting more on the Resque front...not sure what.]

### Flexible Tasks

You've already seen a few examples of calling simple rake tasks, but what if you'd like to pass values into your task? You have a few options on that front:

#### Command Line Arguments

First is to pass them as parameters to the rake task itself:

`rake myrailsapp:monthly_report[8]`

```ruby
namespace :myrailsapp do
  desc "Run monthly report"
  task :montly_report, [:month] => :environment do
    month = args[:month].to_i || Time.now.month
    puts "Generate TPS report CSV..."
    TpsWorker.export_csv(month)
  end
end
```

By adding the `[:month]` into the task declaration, you unlock the ability to pass a value in to your rake call.

Another way of passing parameters through is to include them after the rake command. This will inject the variable name into the environment and allow our task to access it as follows:

`rake myrailsapp:monthly_report month=2011-08`

```ruby
namespace :myrailsapp do
  desc "Run monthly report"
  task :montly_report => :environment do
    month = ENV['month'].to_i || Time.now.month
    puts "Generate TPS report CSV..."
    TpsWorker.export_csv(month)
  end
end
```

This method is less straight forward in your task declaration and requires much more while calling the task but can be useful in conjunction with using other environment variables. [TODO: Really?]

#### Environment Variables

( Show how to add an ENV variable )
( How to read it in general )
( In workers, create a Config class that reads those variables )
( Then in the Rake task, call Config to get the values needed )
( Ex: maybe the current system name, IP address, RailsEnv, something like that )



There are situations where it may be advantageous to use a rake task's access to the environment variables. [TODO: Build example] (Isn't there a gotcha here with cron + rake if your ENV isn't set as expected?)


## Scheduled Tasks

Now you have tasks you can run from the command line, but being the experienced developer that you are, you understand the real goal is to automate yourself out of existence. So how to we run these rake tasks on a schedule?

### Creating a Crontab

cron is a *nix utility for scheduling and executing commands.

To utilize cron, you create a _crontab_.

`crontab -e`

This will create a crontab for your user is none exists, or open your crontab for editing.

### Calling a Rake Task

Creating a cron job that calls a rake task is _almost_ as easy as typing the rake command into the command line. 

The one major caveat is that the cron job runs in a different environment. This means environment variables, even very important ones like PATH, may be completely different. This can cause major headaches in your cron jobs.

The solution is to "assume nothing" in your cron jobs. The most basic step to take here is to always use full paths in your cron jobs:

WRONG WAY:
`cd ~/projects/myrailsapp && rake myrailsapp:monthly_report`

RIGHT WAY:
`cd /Users/jeff/projects/myrailsapp && /usr/local/bin/rake RAILS_ENV=production myrailsapp:monthly_report`

NOTE: To find the full path for your rake install try:
`which rake`

### Timing

The timing of a cron job follows a standard format that, while is a little intimidating at first, is really very easy to dig into. In fact, it's very much like a time based regex in the following pattern:

`minute hour day month weekday`

A few quick examples:

`15 * * * *` (Run on the 15th minute of every hour of the day, every day of the month, every month of the year, every day of the week)

`00,15,30,45 * * * *` (Run on the 0th, 15th, 30th, and 45th minute of every hour of the day, every day of the month, every month of the year, every day of the week)

`00 00 * * 0` (Run at 00:00 every Sunday)

As you can see, it is easy to understand once you know the code, but still it's a lot to keep up. There are several tools to help turn everyday language into a cron job timing. [TODO: How are we referencing resources?]

WARNING: Scheduling your jobs is something you should put some thought into. Running resource intensive jobs very close together or at high peak times can cause system wide performance problems, system crashes, and even death. (Ok, not death...but it can get bad.)

### Bringing it All Together

You've jumped through the hoops to make your command cron compliant and figured out the timing, now you can automate your rake tasks.

`crontabe -e`

```
00,30 * * * * cd /Users/jeff/projects/myrailsapp && /usr/local/bin/rake RAILS_ENV=production myrailsapp:make_recommendations
00 00 * * * cd /Users/jeff/projects/myrailsapp && /usr/local/bin/rake RAILS_ENV=production myrailsapp:purge_audits
00 00 1 * * cd /Users/jeff/projects/myrailsapp && /usr/local/bin/rake RAILS_ENV=production myrailsapp:monthly_report
```

### Logging

( What's a good practice for logging from Cron? I don't really know. Just piping it somewhere? )

[TODO: I don't know either (mark)]

## References

* Crontab Timing Generator: http://www.openjs.com/scripts/jslibrary/demos/crontab.php