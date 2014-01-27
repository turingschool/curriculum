---
layout: page
title: Monsterporioum - Practicing with Services
sidebar: true
---

During this session, we'll help you think and work through how to apply these ideas to your own work and projects.

## Brainstorming Services

Let's collaborate on ideas. Pair with another developer to complete the following:

* Choose an app to discuss, ideally that you're both familiar with
* Spend about 10 minutes discussing ideas for services that could be extracted with the following considerations:
  * the smaller, the better
  * how much/little data does it need to do its job?
  * what happens when the job is done? (Sends email, stores data, etc)
  * how does it improve the parent application?
  * what technologies would best suit it? (Ruby, Sinatra, Rails, ...?)
* In the full group, let's spend about five minutes per pair pitching your best service concept and asking each other questions
* Spend about 30 minutes with your pair working out a whiteboard-level diagram of the components and data flow that would take place to make the service work.

## Building a Service

For the next two hours, along with your pair, work independently on a small service project. It could be the project you brainstormed above or the one described below:

### RepFinder

We have a [CSV data file with attendees from a conference](/projects/full_event_attendees.csv) and want to find the congresspersons associated with each attendee based on zipcode.

**Note**: The data has been obfuscated such that the street addresses don't match with the zipcodes. If accurate, the full address would give more accurate results. But here just deal with the zipcodes.

Can you build a system of interoperating services to get the job done?

* the Parser service...
  * reads the CSV
  * pulls out the ID, zipcode, and name
  * corrects any data inconsistencies with the zipcode
  * publishes a message to the channel with the data to be looked up
* the Fetcher service...
  * watches for zipcodes to hit the channel
  * looks them up against the Sunlight API
  * publishes the fetched data on to the output channel
* the Printer service...
  * watches for fetched data to hit the channel
  * formats the data for print
  * prints it to a CSV output file

#### Accessing the API

See our [EventManager project](http://tutorials.jumpstartlab.com/projects/eventmanager.html#iteration-3:-using-sunlight) for an explanation of the Congress API provided by the [Sunlight Foundation](http://sunlightfoundation.com).

Install the gem:

{% terminal %}
$ gem install sunlight
{% endterminal %}

Get an API key at [sunlightfoundation.com](http://sunlightfoundation.com/api/).

Here's how you would find legislators if the only information you have is a zipcode:

```ruby
require 'sunlight'
Sunlight::Base.api_key = "YOUR_API_KEY"

congresspeople = Sunlight::Legislator.all_in_zipcode("80203")

congresspeople.each do |peep|
  puts "#{peep.firstname} #{peep.lastname} (#{peep.district})"
end
```

### Extension

If you get it working, consider parallelizing the operation. The chokepoint here is the Fetcher service. How could one Parser feed multiple Fetchers and those go back into one Printer?

The key is to avoid double-fetching. The PubSub style we've been using won't work. Instead we need a queue.

Here's a sample of how to use the `redis-queue` gem:

{% terminal %}
$ gem install redis-queue
{% endterminal %}

You can learn more about it at https://github.com/taganaka/redis-queue

#### Queueing Items

This is how you add a bunch of items to the queue:

{% irb %}
> require 'redis-queue'
2.0.0-p0 :001 > require 'redis-queue'
 => true
2.0.0-p0 :002 > redis = Redis.new
 => #<Redis client v3.0.4 for redis://127.0.0.1:6379/0>
2.0.0-p0 :003 > queue = Redis::Queue.new("waiting_queue", "in_process", :redis => redis)
 => #<Redis::Queue:0x007fca3b9ed178 @redis=#<Redis client v3.0.4 for redis://127.0.0.1:6379/0>, @queue_name="waiting_queue", @process_queue_name="in_process", @last_message=nil, @timeout=0>
2.0.0-p0 :004 > (1..100).to_a.each{|i| queue.push "element #{i}"}
{% endirb %}

The two queues named on line 3 are (A) the queue of items waiting to be processed and (B) the queue of items currently in process. If items in B are not comitted in a certain timeframe, they are moved back to A. If they are comitted, then they're removed from B.

The names of the queues here are arbitrary. If they exist in Redis, they'll be used. If they don't, they'll be created.

#### Working from the Queue

Run two (or more) separate instances of IRB with this pattern:

{% irb %}
> require 'redis-queue'
2.0.0-p0 :001 > require 'redis-queue'
 => true
2.0.0-p0 :002 > redis = Redis.new
 => #<Redis client v3.0.4 for redis://127.0.0.1:6379/0>
2.0.0-p0 :003 > queue = Redis::Queue.new("waiting_queue", "in_process", :redis => redis)
 => #<Redis::Queue:0x007fca3b9ed178 @redis=#<Redis client v3.0.4 for redis://127.0.0.1:6379/0>, @queue_name="waiting_queue", @process_queue_name="in_process", @last_message=nil, @timeout=0>
2.0.0-p0 :004 > queue.process do |message|
2.0.0-p0 :005 >     puts message.inspect
2.0.0-p0 :006?>   sleep 3
2.0.0-p0 :007?>   end
{% endirb %}

If your `process` block returns a truthy value, then the message is "comitted" which removes it from the `"in_process"` queue.
