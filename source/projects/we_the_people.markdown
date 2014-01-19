---
layout: page
title: We The People
sidebar: true
---

## Introduction

[We the People](https://petitions.whitehouse.gov/) seeks to "[give] all Americans a way to engage their government on the issues that matter to them." The application provides an [API]() which allows us to both read existing data and write new data to the application.

Jeremy McAnally and a team of contributors created the [We the People Gem](https://github.com/jm/we_the_people) to make it easy for Ruby developers to ignore many of the details of accessing the API. The library uses [RestClient](https://github.com/archiloque/rest-client) to encapsulate the details of communication over HTTP.

Within the library itself, you have two options:

1. Use the *simple* access tools, which return you just raw Ruby hashes. It's then up to you to pick through the keys, values, and nested data. This approach is simple to get started, relatively robust over time as the API changes, but leads to reading a lot of hash-soup.
2. Use the *resources* objects, which model the data from the API into logical Ruby objects (like petition data becoming a `WeThePeople::Resources::Petition`). This approach means reading/learning more of the gem's structure upfront, slightly more brittleness if the API changes, but more readable and maintainable Ruby code.

Let's take a look at each approach.

## General Setup

There are just a few small steps to get going.

### Environment Configuration

#### Ruby Version

This tutorial assumes that you're using Ruby version 1.9.3. Validate your Ruby version by:

* Opening your **Terminal** on Mac OS X (Applications > Utilities > Terminal) or **Command Prompt** on Windows (Start > Run > cmd)
* Run `ruby -v` like below and observe the output:

{% terminal %}
$ ruby -v
ruby 1.9.3p327 (2012-11-10 revision 37606) [x86_64-darwin12.2.0]
{% endterminal %}

If you get an older version (like Ruby 1.8.7) or an error (like `-bash: ruby: command not found`) then your need to install/update Ruby. Hop over to our [Environment Setup Tutorial](http://tutorials.jumpstartlab.com/topics/environment/environment.html) to get your system ready to go.

#### Editor

You'll need a text editor to write your code. We recommend [SublimeText](http://www.sublimetext.com/).

### Install the Gem

#### Traditional Installation

The gem is available on [Rubygems](http://rubygems.org), so it can be installed from your Terminal:

{% terminal %}
$ gem install we_the_people
{% endterminal %}

**But**, it's best to manage your gems using **Bundler**.

#### Using Bundler

##### Install the Latest Released Version

If you're creating a significant Ruby project you want to use [Bundler](http://gembundler.com). In your project directory, create a file named `Gemfile` with these contents:

```ruby
source 'https://rubygems.org'
gem 'we_the_people'
```

##### Edge Gem

Want to live on the edge, building the gem directly from the source on GitHub? Modify your `Gemfile` to point directly to the repository on GitHub:

```ruby
source 'https://rubygems.org'
gem 'we_the_people', :git => "git@github.com:jm/we_the_people.git"
```

##### Process the `Gemfile`

From your terminal, run `bundle` to install the gem and dependencies:

{% terminal %}
$ bundle
Updating git@github.com:jm/we_the_people.git
Fetching gem metadata from https://rubygems.org/..........
Fetching gem metadata from https://rubygems.org/..
Installing activesupport (3.0.0) 
Installing active_support (3.0.0) 
Installing json (1.7.7) with native extensions 
Installing mime-types (1.21) 
Using rest-client (1.6.7) 
Using we_the_people (0.0.2) from git@github.com:jm/we_the_people.git (at master) 
Using bundler (1.2.3) 
Your bundle is complete! Use `bundle show [gemname]` to see where a bundled gem is installed.
{% endterminal %}

### Register for an API Key

[ Instructions for registering for an API key forthcoming ]

#### Demo API Key

Until you have a person API key, you can use `your_api_key_here`.

### Proof of Concept

Let's run through a short IRB session to prove that things are wired up correctly.

Start up an IRB session:

{% terminal %}
$ bundle exec irb
{% endterminal %}

The once you're inside IRB, set your API key and a specific petition:

{% irb %}
1.9.3-p327 :001 > require 'we_the_people'
 => true 
1.9.3-p327 :002 > WeThePeople::Config.api_key = "your_api_key_here"
 => "your_api_key_here"
1.9.3-p327 :003 > petition = WeThePeople::Resources::Petition.find('50a3fd762f2c88cd65000015')
 => #<WeThePeople::Resources::Petition:0x007fc523699d90 @parent=nil, @attributes={"id"=>"50a3fd762f2c88cd65000015", "type"=>"petition", "title"=>"Secure resources and funding, and begin construction of a Death Star by 2016.", "body"=>"Those who sign here petition the United States government to secure funding and resources, and begin construction on a Death Star by 2016.\r\n\r\nBy focusing our defense resources into a space-superiority platform and weapon system such as a Death Star, the government can spur job creation in the fields of construction, engineering, space exploration, and more, and strengthen our national defense.\r\n\r\n", "status"=>"responded", "deadline"=>1355516534, "created"=>1352924534, "response"=>#<struct WeThePeople::Resources::Response id="716", url="https://petitions.whitehouse.gov/response/isnt-petition-response-youre-looking">, "issues"=>[#<struct WeThePeople::Resources::Issue id="12", name="Defense">, #<struct WeThePeople::Resources::Issue id="97", name="Job Creation">, #<struct WeThePeople::Resources::Issue id="139", name="Science and Space Policy">]}>
 1.9.3-p327 :04 > petition.title
 => "Secure resources and funding, and begin construction of a Death Star by 2016." 
{% endirb %}

Tada!

## Understanding the API

Let's back up and dig into the details of this all works.

### API Structure

The We The People API, like most HTTP-based APIs, uses JSON to communicate. You, or your program, puts together a carefully formatted HTTP request, submits it to the server, and gets back a package of JSON data.

For example, use a web browser like Chrome to visit this URL:

```plain
https://petitions.whitehouse.gov/api/v1/petitions/50a3fd762f2c88cd65000015.json?limit=100&offset=0&key=your_api_key_here
```

You should see a JSON response like this:

```json
{"metadata":{"execution time":0},"results":[{"id":"50a3fd762f2c88cd65000015","type":"petition","title":"Secure resources and funding, and begin construction of a Death Star by 2016.","body":"Those who sign here petition the United States government to secure funding and resources, and begin construction on a Death Star by 2016.\r\n\r\nBy focusing our defense resources into a space-superiority platform and weapon system such as a Death Star, the government can spur job creation in the fields of construction, engineering, space exploration, and more, and strengthen our national defense.\r\n\r\n","issues":[{"id":"12","name":"Defense"},{"id":"97","name":"Job Creation"},{"id":"139","name":"Science and Space Policy"}],"signature threshold":25000,"signature count":34435,"signatures needed":0,"url":"https://petitions.whitehouse.gov/petition/secure-resources-and-funding-and-begin-construction-death-star-2016/wlfKzFkN","deadline":1355516534,"status":"responded","response":{"id":"716","url":"https://petitions.whitehouse.gov/response/isnt-petition-response-youre-looking","association time":"1357944472"},"created":1352924534}]}
```

#### Picking Apart the URL

Let's look at the components of the request URL

```plain
https://petitions.whitehouse.gov/api/v1/petitions/50a3fd762f2c88cd65000015.json?key=your_api_key_here
```

Broken down:

* `https://` -- the browser is communicating with the server using the HTTPS protocol
* `petitions.whitehouse.gov` -- the server or computer that is actually running the We The People application
* `api/v1/` -- all API calls are run under this folder or "namespace"
* `petitions/` -- we're looking at petitions
* `50a3fd762f2c88cd65000015` -- the unique ID of the petition we're interested in
* `.json` -- we'd like the response formatted in JSON
* `?key=your_api_key_here` -- we identify our request with our unique API key, obtained earlier

Using this URL structure, you could manually request the details of any presentation if you know the ID number. For instance, substituting in another ID:

```plain
https://petitions.whitehouse.gov/api/v1/petitions/5057ad98adfd95100b000008.json?key=your_api_key_here
```

Which retrieves the JSON details about that second petition.

#### API Endpoints

The API offers dozens of "endpoints" -- URLs that you can access to retrieve data. The best reference for everything available is the API documentation available at [TODO: Insert Public Link].

#### So this is all about URLs?

Experimenting with a few URLs manually is a great way to get your feet wet with the API, but it's not practical for building code. Instead, we'll use the gem library to automate requests and processing of the responses.

But whenever you're using an HTTP-based API, remember that there's no real magic going on: it's just a carefully constructed web request, just like any other page you visit on the web.

#### Why Use a Gem?

There are three main reasons to use an API wrapper gem:

##### Insulation

Manipulating URLs by hand is error-prone and fragile. Imagine that you write a big program using dozens of URLs representing API endpoints. Then the We The People team decides to change the URL structure! You might have to rewrite large parts of your application.

Gem gem wrapper provides a *layer of abstraction*. If your program depends on and utilizes the gem, then a few small changes in the gem can make up for massive changes in the API. Ideally, as a gem user you might not even need to know that the API changed. The gem can insulate you from the API.

##### Ignore Transport Details

But more importantly, API gems provide a way to ignore the HTTP details. Without the gem, you might think "I need to make a request to *X* endpoint, using *Y* URL format, with *Z* parameters, then parse the response JSON and find the data I need." You're likely to make typos in the URLs, maybe not get the parameters quite right, etc. Your implementation is mostly about manipulating strings and trying to make sense of the data.

##### Think In Domain Objects

Many API gems, beyond the other two uses, allow you to think in domain objects. Instead of concerning yourself with URL details and JSON, you can think in domain objects: "I want to fetch a petition and find it's current number of signatures."

The `we_the_people` gem allows you to insulate yourself from the API, ignore the transport details, and (optionally) work in domain objects.

## Simple API Access

Let's first look at the lower level gem usage which just allows us to ignore the URL/HTTP details.

We'll use the `WeThePeople::Simple` object. It helps us make the HTTP requests and returns raw JSON.

### An Example

{% irb %}
$ bundle exec irb
> require 'we_the_people'
 => true 
> require 'we_the_people/simple'
 => true 
> WeThePeople::Config.api_key = "your_api_key_here"
 => "your_api_key_here" 
> petition = WeThePeople::Simple.petition("50a3fd762f2c88cd65000015")
 => {"id"=>"50a3fd762f2c88cd65000015", "type"=>"petition", "title"=>"Secure resources and funding, and begin construction of a Death Star by 2016.", "body"=>"Those who sign here petition the United States government to secure funding and resources, and begin construction on a Death Star by 2016.\r\n\r\nBy focusing our defense resources into a space-superiority platform and weapon system such as a Death Star, the government can spur job creation in the fields of construction, engineering, space exploration, and more, and strengthen our national defense.\r\n\r\n", "issues"=>[{"id"=>"12", "name"=>"Defense"}, {"id"=>"97", "name"=>"Job Creation"}, {"id"=>"139", "name"=>"Science and Space Policy"}], "signature threshold"=>25000, "signature count"=>34435, "signatures needed"=>0, "url"=>"https://petitions.whitehouse.gov/petition/secure-resources-and-funding-and-begin-construction-death-star-2016/wlfKzFkN", "deadline"=>1355516534, "status"=>"responded", "response"=>{"id"=>"716", "url"=>"https://petitions.whitehouse.gov/response/isnt-petition-response-youre-looking", "association time"=>"1357944472"}, "created"=>1352924534} 
{% endirb %}

See that result? By the leading `{` and trailing `}` you can see it's a Ruby hash. You can navigate that hash to find the data you're looking for:

{% irb %}
> petition["title"]
 => "Secure resources and funding, and begin construction of a Death Star by 2016." 
{% endirb %}

### Digging In To Signatures

Or maybe you want to find information about the signatures on that petition:

{% irb %}
 > sigs = WeThePeople::Simple.signatures("50a3fd762f2c88cd65000015")
 => [{"id"=>"50f0b6637043013f5d000005", "type"=>"signature", "name"=>"EZ", "zip"=>"07940", "created"=>1357952611}, {"id"=>"50f0b56e2f2c88ff3700000b", "type"=>"signature", "name"=>"JY", "zip"=>nil, "created"=>1357952366}, {"id"=>"50f0b554c988d4551e000004", "type"=>"signature", "name"=>"cc", "zip"=>
 ...
{% endirb %}

That's a huge chunk of data!

{% irb %}
> sigs.count
 => 1000 
> sigs.class
 => Array 
> sigs.first
 => {"id"=>"50f0b6637043013f5d000005", "type"=>"signature", "name"=>"EZ", "zip"=>"07940", "created"=>1357952611}
{% endirb %}

Specifically it's 1000 signitures from that petition, which we see are collected in an `Array`. Looking at the first element of the array, it's a hash with keys `"id"`, `"type"`, `"name"`, `"zip"`, and `"created"`. 

#### Top Zipcodes

What could we do with that? How about "find the top 10 zipcodes with the most signitures":

{% irb %}
> zipcodes = sigs.collect{|sig| sig['zip']}
 => ["07940", nil, "02769", " 20181", "21040", "80814", "95624", "30518", #...
> grouped_zipcodes = zipcodes.group_by{|zip| zip.to_s.strip}
 => {"07940"=>["07940"], "02769"=>["02769"], #...
> sorted_groups = grouped_zipcodes.sort_by{|zipcode, instances| instances.count}
 => [["07940", ["07940"]], ["80040-070", ["80040-070"]], ["02769", ["02769"]], #...
> highest_groups_first = sorted_groups.reverse
 => [["", [nil, nil, nil, nil, #...
> top_ten = highest_groups_first.take(10)
 => [["", [nil, nil, nil, nil, #...
> top_ten.each do |zipcode, instances|
>   puts "#{zipcode} (#{instances.count})"
> end
 (112)
32780 (4)
43068 (4)
44256 (3)
80918 (3)
14450 (3)
20850 (3)
91342 (3)
90210 (3)
45241 (2)
{% endirb %}

Which shows us that, among the first 1000 signatures, 112 of them recorded no zipcode, four of them were from 32780, etc.

#### But with ALL the Signatures

But then you want *all* the signatures, not just the first 1000. Add an `offset` option to the `signatures` method, fetching 1000 signatures at a time:

```ruby
id = "50a3fd762f2c88cd65000015"
all_signatures = []
response = ""
counter = 0

until response == []
  response = WeThePeople::Simple.signatures("50a3fd762f2c88cd65000015", :offset => 1000*counter)
  all_signatures = all_signatures + response
  counter = counter + 1
end
```

At the time of this writing, this process takes a few minutes to make over 30 API requests. Then follow it with the same process as before:

```ruby
zipcodes = all_signatures.collect{|sig| sig['zip']}
grouped_zipcodes = zipcodes.group_by{|zip| zip.to_s.strip}
sorted_groups = grouped_zipcodes.sort_by{|zipcode, instances| instances.count}
highest_groups_first = sorted_groups.reverse
top_ten = highest_groups_first.take(10)
top_ten.each do |zipcode, instances|
  puts "#{zipcode} (#{instances.count})"
end; nil
```

Which, when run against the full set of signatures, would create this list:

```plain
 (4877)
90210 (107)
85281 (24)
10001 (22)
98052 (22)
12345 (21)
98034 (20)
47906 (20)
66062 (19)
48104 (19)
```

Almost 5000 had no zipcode stored, while we learn that Beverly Hills is *very* interested in death stars.

### Next Steps

If you enjoy working with Ruby hashes and Arrays, dig into the [`WeThePeople::Simple` source code](https://github.com/jm/we_the_people/blob/master/lib/we_the_people/simple.rb) and you'll find all the different end points it supports.

## Resource Objects API Access

Digging through hashes is a bit of a pain. Let's step up a level of abstraction and deal with domain objects.

## Example Data Access

In the `WeThePeople` gem there are classes collected under the namespace `Resource`:

https://github.com/jm/we_the_people/tree/master/lib/we_the_people/resources

Each class represents a domain object in the We the People system. Let's explore...

### Finding with `Petition`

Starting a fresh IRB session:

{% irb %}
we_the_people ⚡ bundle exec irb
> require 'we_the_people'
 => true 
> WeThePeople::Config.api_key = "your_api_key_here"
 => "your_api_key_here" 
> petition = WeThePeople::Resources::Petition.find('50a3fd762f2c88cd65000015')
 => #<WeThePeople::Resources::Petition:0x007f88d3c16548 #...
{% endirb %}

When using the `Simple` fetcher, you got back a hash. Now the response looks like this:

```plain
#<WeThePeople::Resources::Petition:0x007
```

Which shows you that it's an instance of the `WeThePeople::Resources::Petition` class. You could [browse the source of that class](https://github.com/jm/we_the_people/blob/master/lib/we_the_people/resources/petition.rb), and see that there are many attributes available including:

{% irb %}
> p.signature_threshold
 => 25000 
> p.signature_count
 => 38023 
> p.status
 => "responded" 
{% endirb %}

That's a little cleaner and easier than digging through Hash keys. And, in the case of `signature_threshold` and `signature_count`, you can see they values have been converted to integers where the hash would have simply given strings. 

If you looked at the data as it comes back in JSON form, the `deadline` attribute comes back at `"1350515352"`. What is that? It's the time offset since the Unix epoch:

{% irb %}
> Time.at("1350515352".to_i)
 => 2012-10-17 19:09:12 -0400 
{% endirb %}

It'd be a pain to remembwer to do this conversion every time you use a date from the response, but the `Petition` object does the tedius work for you:

{% irb %}
> p.deadline
 => 2012-10-17 19:09:12 -0400 
> p.deadline.class
 => Time 
{% endirb %}

Instead of giving you back the offset, when you call the `deadline` method you get back an instance of Ruby's `Time` class which is much more useful.

### Associated Objects

Beyond just attribute manipulation, the `Resource` objects are able to navigate between relationships:

{% irb %}
> p = WeThePeople::Resources::Petition.find("5057ad98adfd95100b000008")
 => #<WeThePeople::Resources::Petition:0x007fde79591410 @parent=nil #...
> p.response.url
 => "https://petitions.whitehouse.gov/response/addressing-freedoms-speech-and-religion" 
{% endirb %}

We get the URL of the official response to the petition. Did it require another API request? Was it embedded in the JSON about the `Petition`? We don't have to know or care -- the gem's domain models hide that complexity from you.

## Sample Problems

Let's solve some realistic questions assuming:

* Code is running inside IRB or as a Ruby script
* The API key has already been set

### What are the most popular petitions posted in the last week?

```ruby
begin
  one_week = 60*60*24*7  # One week in seconds
  start_time = (Date.today.beginning_of_day - one_week).to_i

  recent_petitions = WeThePeople::Resources::Petition.all(nil, :createdAfter => start_time)
  sorted_petitions = recent_petitions.sort_by{|petition| petition.signature_count }
  highest_first = sorted_petitions.reverse

  top_10 = highest_first.take(10)
  top_10.each_with_index do |petition, rank|
    puts "#{rank + 1}. #{ petition.title } (#{ petition.signature_count })"
  end
  puts ""
end
```

### Which active petitions are closest to the response threshold?

```ruby
begin
  thirty_days = 30*24*60*60
  active_petitions = WeThePeople::Resources::Petition.all(nil, :createdAfter => thirty_days)
  pending_petitions = active_petitions.select do |petition| 
    (petition.status == "open") && (petition.signatures_needed > 0)
  end
  
  sorted_petitions = pending_petitions.sort_by{|petition| petition.signatures_needed }

  top_10 = sorted_petitions.take(10)
  top_10.each_with_index do |petition, rank|
    puts "#{rank + 1}. #{ petition.title } (needs #{ petition.signatures_needed })"
  end
  puts ""
end
```

### For a given petition, what states do the signers come from?

This script makes use of the `geokit` gem, install it with `gem install geokit`.

```ruby
require 'geocoder'
begin
  petition = WeThePeople::Resources::Petition.find("5126762c688938c751000010")
  all_signatures = petition.signatures.get_all
  by_state = all_signatures.group_by do |signature|
    zipcode = signature.zip
    geo = GeoKit::Geocoders::MultiGeocoder.multi_geocoder(zipcode)
    if geo.success
      geo.state
    else
      "none"
    end
  end
  by_state = by_state.sort_by{|state, sigs| state || ""}
  by_state.each do |state, sigs|
    puts "#{state} : #{sigs.count}"
  end;nil
end
```

### What petitions are people near me signing?

[ Needs API support for /petitions.json ]

## SupportMapper