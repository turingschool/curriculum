# Measuring Performance

( Intro about why we measure performance, how does it fit into development lifecycle )
( Effective apps respond to all requests in under 1 second )
( Before we can optimize we need to measure so we know if goals are acheived, progress made, etc)

## Inspecting the Logs

( First step )

### Response Time

( What should response time look like in development )

### Query Count

( Are requests spawning a billion queries? A normal request should have somewhere 1-8(?) queries, more than that is probably a problem)
( Ex: Scenarios that create many queries, like accessing child objects )

### Side-Effect Queries

( Queries that are triggered every request )
( Like from before filters, eg: user lookup or shopping cart lookup )
( If necessary to the app, these are what should be put in a high-performance cache )

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
