---
layout: page
title: Automated Tasks with Cron and Rake
section: Systems Management
---

While much of your application is built to (swiftly) respond to a web request, there are many scenarios where you would like to access and run pieces of your application outside of that request/response cycle.

You may want to run maintenance tasks, periodic calculations, or reporting in your production environment, while in development, you may want to trigger your full test suite to run.

## Rake

The rake gem is Ruby's most widely accepted solution for performing these types of tasks. 

Rake is a 'ruby build program with capabilities similar to make' providing you a convenient way to make your Ruby libraries executable on your system.

### Rake Tasks

You write rake _tasks_, which can be invoked by calling:

{% terminal %}
$ rake my_task_name
{% endterminal %}

Thankfully, you aren't expected to memorize every rake task your application has available. You can view all your application's rake tasks using:

{% terminal %}
$ rake -T --all
{% endterminal %}

This output may be overwhelming though, so you can narrow down the results to the most commonly used commands by dropping the `--all` flag:

{% terminal %}
$ rake -T
{% endterminal %}

And can limit your results even further by using:

{% terminal %}
$ rake -T text_to_match
{% endterminal %}

### Rakefile

Rake finds these tasks by reading the `Rakefile`. In a default Rails application, the `Rakefile` will look like this:

```
#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
MyRailsApplication::Application.load_tasks
```

#### Creating Your Own `.rake` file

As you can read from the comments, you should add your own rake tasks  in the _lib/tasks_. This is possible thanks to the `load_tasks` call made to your application object. 

Say, for example, that we're going to create a file `lib/tasks/myrailsapp.rake`

#### Creating a Namespace

It's a good practice to wrap your tasks into a namespace to make sure they don't collide with tasks from Rails or other libraries. In the `Rakefile`, you'd create a namespace like this:

```ruby
namespace :myrailsapp do

end
```

It's conventional to have the name of the `.rake` file and the namespace match.

#### Defining a Task

Defining a task within the namespace looks like this:

```ruby
namespace :myrailsapp do
  task purge_audits: :environment do
    puts "Purging old audits..."
    Audit.purge
  end
end
```

It starts with the `task` method which takes a hash parameter. The key, here `:purge_audits`, will be the name of the task. The value stored under that key, here `:environment`, indicates which other Rake tasks should be run *before* this task is run. Think of them like dependencies.

When your task depends on `:environment`, it will load your entire Rails application. If your task doesn't actually need Rails, don't depend on `:environment` and you can greatly increase startup time and decrease memory usage.

#### Describing the Task

Finally, all tasks should have a `desc` call which is a brief, one line description of what the task does:

```ruby
namespace :myrailsapp do
  desc "Purge stale entries from audits table"  
  task purge_audits: :environment do
    puts "Purging old audits..."
    Audit.purge
  end
end
```

This description is output when the user runs `rake -T`.

#### Designing Tasks

Rake tasks are Ruby, so you can do complex logic. But well designed Rake tasks use as little logic as possible. Instead, they should call methods on domain objects (models, workers, etc). 

### Flexible Tasks

You've already seen a few examples of calling simple rake tasks, but what if you'd like to pass values into your task? 

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

#### ENV Variables as Arguments

Another way of passing parameters through is to include them after the rake command. This will inject the variable name into the environment and allow our task to access it as follows:

`rake myrailsapp:monthly_report month=2011-08`

```ruby
namespace :myrailsapp do
  desc "Run monthly report"
  task montly_report: :environment do
    month = ENV['month'].to_i || Time.now.month
    puts "Generate TPS report CSV..."
    TpsWorker.export_csv(month)
  end
end
```

## Scheduled Tasks

Now you have tasks you can run from the command line, but being the experienced developer that you are, you understand the real goal is to automate yourself out of existence. So how do we run these rake tasks on a schedule?

### Creating a Crontab

Cron is a unix utility for scheduling and executing commands.

To utilize cron, you create a _crontab_.

{% terminal %}
$ crontab -e
{% endterminal %}

This will create a crontab for your user is none exists, or open your crontab for editing.

### Calling a Rake Task

Creating a cron job that calls a rake task is _almost_ as easy as typing the rake command into the command line. 

The one major caveat is that the cron job runs in a different environment. This means environment variables, even very important ones like PATH, may be completely different. This can cause major headaches in your cron jobs.

The solution is to "assume nothing" in your cron jobs. The most basic step to take here is to always use full paths in your cron jobs:

#### The WRONG Way

{% terminal %}
$ cd ~/projects/myrailsapp && rake myrailsapp:monthly_report
{% endterminal %}

#### The RIGHT Way

{% terminal %}
cd /Users/you/projects/myrailsapp && /usr/local/bin/rake RAILS_ENV=production myrailsapp:monthly_report
{% endterminal %}

To find the full path for your rake executable, run `which rake`.

### Timing

The timing of a cron job follows a standard format that, while is a little intimidating at first, is really very easy to dig into. In fact, it's very much like a time based regex in the following pattern:

`minute hour day month weekday`

A few examples:

#### `15 * * * *`

Run on the 15th minute of every hour of the day, every day of the month, every month of the year, every day of the week.

#### `00,15,30,45 * * * *`

Run on the 0th, 15th, 30th, and 45th minute of every hour of the day, every day of the month, every month of the year, every day of the week.

#### `00 00 * * 0`

Run at 00:00 every Sunday.

#### Generating Timing Settings

There are several tools to help turn everyday language into a cron job timing or GUI tools like this one: http://www.openjs.com/scripts/jslibrary/demos/crontab.php

#### Timing Strategy

Scheduling your jobs is something you should put some thought into. 

Running resource intensive jobs very close together or at high peak times can cause system wide performance problems and system crashes. Try to target low-utilization periods and/or space out jobs.

### Bringing it All Together

You've jumped through the hoops to make your command cron compliant and figured out the timing, now you can automate your rake tasks.

`crontabe -e`

```
00 00 * * * cd /Users/you/projects/myrailsapp && /usr/local/bin/rake RAILS_ENV=production myrailsapp:purge_audits
```

## References

* Crontab Timing Generator: http://www.openjs.com/scripts/jslibrary/demos/crontab.php
