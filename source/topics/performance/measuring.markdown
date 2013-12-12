---
layout: page
title: Measuring Performance
section: Performance
---

Performance is often ignored in Rails development until it becomes a problem. If ignored too long, though, it can get very tricky to improve. It's valuable to regularly audit performance and look for hotspots or design choices that are slowing things down.

### Inspecting the Logs

Inspecting the log will help identify the source of several performance issues the application may have.

The Rails application log outputs the time spent processing each request.  It breaks down the time spent at the database level as well processing the view code.  In development mode, the logs are displayed on STDOUT where the server is being run.  In a production setting the logs will be in `log/production.log` within the application's root directory.

#### An Example

Take note of lines 4-9 in the following request:

```text
1 Started GET "/articles/1" for 127.0.0.1 at 2011-09-12 13:07:21 -0400
2   Processing by ArticlesController#show as HTML
3   Parameters: {"id"=>"1"}
4   Article Load (0.3ms)  SELECT "articles".* FROM "articles" WHERE "articles"."id" = 1 LIMIT 1
5   Tag Load (0.3ms)  SELECT "tags".* FROM "tags" INNER JOIN "taggings" ON "tags".id = "taggings".tag_id WHERE (("taggings".article_id = 1))
6   SQL (0.2ms)  SELECT COUNT(*) FROM "comments" WHERE ("comments".article_id = 1)
7   Comment Load (0.2ms)  SELECT "comments".* FROM "comments" WHERE ("comments".article_id = 1)
8 Rendered articles/show.html.erb within layouts/application (102.8ms)
9 Completed 200 OK in 124ms (Views: 106.7ms | ActiveRecord: 1.0ms)
```

* Lines 4-7 include a breakdown of the time spent executing the database queries to fulfill the request.
* Line 8 indicates how long was spent building the view
* Line 9 reports the total time spent along with a breakdown of time in the view vs in the database

The total time will likely be greater than the sum of the view and database processing time.  The remaining time is spent in other parts of the system, such as the router, controller, and logger I/O.

*NOTE:* Be aware of the environment of the log being inspected.  By default, in production the log output will not include the details of time spent processing each database query, although it will still provide the total time as indicated on line 9 of the above request.  Lines 4-7 of the above request would not be present in production.

#### Response Time

Response time for an effective application should never go above half a second. If you cross that line, it's time to investigate ways to move some of the processing to asynchronous workers, cut down the number of queries, or cache data.

#### Query Count

If the log for a single request is filled with a lot of database queries that can often be a red flag in identifying a performance bug.  A normal request should have somewhere between 1-4 queries.  If more than that are being spawned, they should be condensed using techniques in the [Query Strategies]({% page_url /topics/performance/queries %}) section.

### New Relic

New Relic (http://newrelic.com) is an essential tool for any Rails application. It tracks the performance of every request and can be used in both development and production.

#### Setup

Add the `newrelic_rpm` gem to your `Gemfile` and `bundle`.

Register for an account at http://newrelic.com/ and get the `newrelic.yml` from the welcome email. Drop this file into the `/config` directory of your project.

#### Usage in Development

New Relic will track the most recent 100 requests in development. To view the data visit `/newrelic` in your browser.

So, assuming your app is running on `localhost:3000`, find New Relic at `http://localhost:3000/newrelic`.  You may need to restart your server.

#### Usage in Production

There's no additional configuration for production, just run your app as normal then view the results under your account at http://rpm.newrelic.com/

### Perftools.rb

PerfTools.rb is a port of Google's Perftools: https://github.com/tmm1/perftools.rb

It's an amazing library to profile which methods are making up the bulk of your processing time.

#### Basic Ruby Usage

{% terminal %}
gem install perftools.rb
{% endterminal %}

#### Using a block:

```ruby
require 'perftools'
PerfTools::CpuProfiler.start("/tmp/add_numbers_profile") do
  5_000_000.times{ 1+2+3+4+5 }
end
```

#### Using Start/Stop

```ruby
require 'perftools'
PerfTools::CpuProfiler.start("/tmp/add_numbers_profile")
5_000_000.times{ 1+2+3+4+5 }
PerfTools::CpuProfiler.stop
```

#### Running Externally

```ruby
CPUPROFILE=/tmp/my_app_profile RUBYOPT="-r`gem which perftools \
| tail -1`" ruby my_app.rb
```

Where `my_app.rb` is the external file

### Reports

With the data file generated you can create a variety of reports. 

#### Plain Text Table

The simplest is the plain text table. Run this from the command line:

{% terminal %}
$ pprof.rb --text /tmp/add_numbers_profile
Total: 1735 samples
    1487  85.7%  85.7%     1735 100.0% Integer#times
     248  14.3% 100.0%      248  14.3% Fixnum#+
{% endterminal %}

Where the columns indicate:

1. Number of profiling samples in this function
2. Percentage of profiling samples in this function
3. Percentage of profiling samples in the functions printed so far
4. Number of profiling samples in this function and methods it calls
5. Percentage of profiling samples in this function and methods it calls
6. Function name

In a typical Ruby/Rails application, columns 4 and 5 are the most interesting. The methods you write usually aren't CPU intensive, but they trigger other methods that soak up the CPU. High numbers in 4 and 5 show your methods that are causing the issues.

#### PDF Output

Even better than the table, Perftools can generate PDFs. You'll need the `ps2pdf` utility.

On OS X, install it with `brew install ghostscript`.

On Linux, install it with `apt-get install ps2pdf`. If you get an error that `ps2pdf` package can not be found, try typing `ps2pdf` to see if it is already installed as part of the OS.

Then generate and open the pdf with:

{% terminal %}
$ pprof.rb --pdf /tmp/add_numbers_profile > /tmp/add_numbers_profile.pdf
$ open /tmp/add_numbers_profile.pdf
{% endterminal %}

### Usage with Rails

There's a Rack middleware which can easily inject PerfTools into your application. 

#### Setting up the Gem / Middleware

First, add the following to your `Gemfile`:

```ruby
gem 'rack-perftools_profiler', require: 'rack/perftools_profiler'
```

Then run `bundle` to install it. Next, open `/config/application.rb` and initialize the middleware:

```ruby
config.middleware.use ::Rack::PerftoolsProfiler, 
  default_printer: 'pdf', bundler: true
```

#### Activating Perftools

Finally, it's time to make your request. Enter the URL you want to examine and add the parameter `?profile=true` in your browser. 

For instance, to see the graph for the `articles#index` you could visit: 

```plain
http://localhost:3000/articles?profile=true
```

For better statistical accuracy, you might want to run the same request several times by adding the `times` parameter:  

```plain
http://localhost:3000/articles?profile=true&amp;times=5
```

### References

* PerfTools.rb: https://github.com/tmm1/perftools.rb
* Google's PProf:  http://google-perftools.googlecode.com/svn/trunk/doc/cpuprofile.html#pprof
* Notes on Profiling Ruby:  http://www.igvita.com/2009/06/13/profiling-ruby-with-googles-perftools/
* Rack PerfTools Middleware: https://github.com/bhb/rack-perftools_profiler
