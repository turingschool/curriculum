# Measuring Performance

( Intro about why we measure performance, how does it fit into development lifecycle )
( Effective apps respond to all requests in under 1 second )
( Before we can optimize we need to measure so we know if goals are acheived, progress made, etc)

## Inspecting the Logs

( First step )

Inspecting the log will help identify the source of any performance issues the application may have.

The Rails application log will output the time spent processing each request.  It will breakdown the time spent at the database level as well processing the view rendering code.  In development mode the logs are displayed on STDOUT where the server is being run.  In a production setting the logs will be in `log/production.log` within the application's root directory.

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

The total time will likely be greater than the sum of the view and database processing time.  The remaining time is likely spent processing the controller.

*NOTE:* Be aware of the environment of the log being inspected.  By default, in production the log output will not include the details of time spent processing each database query, although it will still provide the total time as indicated on line 9 of the above request (lines 4-7 of the above request would not be present in prouction).

### Response Time

( What should response time look like in development )

### Query Count

( Are requests spawning a billion queries? A normal request should have somewhere 1-8(?) queries, more than that is probably a problem)

If the log for a single request is filled with a lot of database queries that can often be a red flag in identifying a performance bug.  A normal request should have somewhere between 1-8 queries.  If the request has many more than that it may raise a question in the application's design of the page, or perhaps some of the queries can be consolidated into bigger statements (more on this in the next section).

( Ex: Scenarios that create many queries, like accessing child objects )

Some scenarios of a request that has many queries are:

#### Accessing Child Objects

An example of accessing child objects is a blogging application where a blog post has many comments attached to it.  Consider the following controller and view code fragments:

```ruby
 # articles_controller.rb
 ...
 def show
   @article = Article.find(params[:id])
 end
 ...

 # app/views/articles/show.html.erb
 ...
 <% @article.comments.each do |comment| %>
   <div class='comment'>
     <p>
       <em><%= comment.author_name %></em> said at <%= distance_of_time_in_words(@article.created_at, comment.created_at) %> later:</p>
       <p><%= comment.body %></p>
     </p>
   </div>
 <% end %>
 ...
```

Each time an article is loaded then all of the comments for the article are also loaded.  Suppose a comment had another `has_many` relationship under it.  If this other model was also being accessed to display each comment it would result in another query in the request for each comment attached to the article.

### Side-Effect Queries

( Queries that are triggered every request )
( Like from before filters, eg: user lookup or shopping cart lookup )
( If necessary to the app, these are what should be put in a high-performance cache )(the first

Side-Effect Queries are queries that may be executed for every or many requests in the application.  These types of queries often come from before_filters doing things like looking up the current user or contents of a shopping cart.

If these queries are crucial to every request in the application then they may be a good candidate of something that should be moved into a high-performance cache like Redis (more on this later).

## New Relic

( Basic intro, mention how just about every Rails app uses New Relic)

### Setup

( Gem, API key, registering, app config, etc )

### Usage in Development

( What are some of the things to look at, click on, etc)

### Usage in Production

( Any notes about parts that are more useful in production )

## Perftools.rb

( More Introduction to Perftools )

PerfTools.rb is a port of Google's Perftools: https://github.com/tmm1/perftools.rb

### Basic Ruby Usage

* `gem install perftools.rb`
* Collect data by:
  * Using a block:

```ruby
require 'perftools'
PerfTools::CpuProfiler.start("/tmp/add_numbers_profile") do
  5_000_000.times{ 1+2+3+4+5 }
end
```

  * Using Start/Stop

```ruby
require 'perftools'
PerfTools::CpuProfiler.start("/tmp/add_numbers_profile")
5_000_000.times{ 1+2+3+4+5 }
PerfTools::CpuProfiler.stop
```

  * Running Externally

```ruby
CPUPROFILE=/tmp/my_app_profile RUBYOPT="-r`gem which perftools | tail -1`" ruby my_app.rb
```

Where `my_app.rb` is the external file

### Reports

With the data file generated you can create a variety of reports. 

#### Plain Text Table

The simplest is the plain text table. Run this from the command line:

```
pprof.rb --text /tmp/add_numbers_profile
```

To generate output like this:

```
Total: 1735 samples
    1487  85.7%  85.7%     1735 100.0% Integer#times
     248  14.3% 100.0%      248  14.3% Fixnum#+
```

Where the columns indicate:

1. Number of profiling samples in this function
2. Percentage of profiling samples in this function
3. Percentage of profiling samples in the functions printed so far
4. Number of profiling samples in this function and its callees
5. Percentage of profiling samples in this function and its callees
6. Function name

#### SVG Graph

### Usage with Rails

( ? )

### References

* https://github.com/tmm1/perftools.rb
* http://google-perftools.googlecode.com/svn/trunk/doc/cpuprofile.html#pprof
* http://www.igvita.com/2009/06/13/profiling-ruby-with-googles-perftools/
