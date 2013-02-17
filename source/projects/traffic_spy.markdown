---
layout: page
title: TrafficSpy
---

### Abstract

In this project you'll use Ruby, Sinatra, and Sequel to build a web traffic tracking and analysis tool.

Your application will be live on the Internet. It will recieve data over HTTP from a simulation engine. The simulator will construct and transmit HTTP requests which include tracking data.

Imagine that I run a commercial website and embed JavaScript code which gets activated each time a page is viewed on my site. That JavaScript captures information about the visitor and the page they're viewing then, in the background, submits that data to *your* TrafficSpy application.

Your application parses and stores that data.

Later, I visit your site and can view data about my traffic through a normal HTML interface.

### Learning Goals

* Understand how web traffic works
* Dig into HTTP concepts including headers, referrers, and payload
* Design a normalized SQL-based database structure
* Use Sequel to interface with the database from Ruby
* Practice fundamental database storage and retrieval
* Understand and practice HTTP verbs including GET, PUT, and POST
* Practice using fundamental HTML and CSS to create a usable web interface

## Getting Started

### Clone the Project

1. One team member forks the repository at https://github.com/gschool/traffic_spy
2. Add the second team member as a collaborator

### Data Simulator

You can download the data simulator from RubyGems:

```bash
gem install traffic_spy-simulator
```

The simulator has pre-configured scripts of data. For instance:

```bash
$ traffic_spy_simulator -script 1 http://localhost:3000
```

Would run "Script 1" and stream traffic to your local machine on port 3000. Visit http://github.com/jumpstartlab/traffic_spy_simulator to learn more about the scripts.

If you'd like to continuously stream traffic to your server in random distributions, use:

```
$ traffic_spy_simulator http://localhost:3000 -sites 3 -traffic high
```

Which will simulate three sites simultaneously sending data at a high frequency.

### Understandings

### Requirements

The project must use:

* [Sinatra](http://www.sinatrarb.com/)
* [PostgreSQL](http://www.postgresql.org/)
* [Sequel](http://sequel.rubyforge.org/)
* [Heroku](http://heroku.com)

### Restrictions

The project may not use:

* ActiveRecord
* Rails

## Functionality

### Base Expectations

#### Generate Site Accounts

To register with your application, the client will submit a `POST` request to:

```
http://yourapplication:port/application/new
```

It will include a parameter named `identifier` with a name string like `'jumpstartlab'`. It will include a parameter `'root_url'` with a url like `'http://jumpstartlab.com'`.

If that identifier already exists in the system, your application should return status `403`.

If that identifier does not yet exist, your application should return status `200` and a JSON body like this:

```
{"identifier":374392874}
```

With a generated, unique identifier.

#### Recieve Data

Your application will receive a `POST` request to the following URL pattern:

```
http://yourapplication:port/source/IDENTIFIER/data
```

Where `IDENTIFIER` is the unique identifier generated previously for this site. The request will contain a JSON body with this format:

```
{
  "url":"http://jumpstartlab.com/blog",
  "requested_at":"2013-02-16 21:38:28 -0700",
  "responded_in":37,
  "referred_by":"http://jumpstartlab.com",
  "request_type":"GET",
  "parameters":[],
  "user_agent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17",
  "resolution_width":"1920",
  "resolution_height":"1280",
  "ip":"63.29.38.211"
}
```

Your application should break up and store all parts on the data package.

#### Viewing Data & Statistics

### Extensions

#### Authenticated Data

When the system creates an account, generate and return a public key. Use public/private key cryptography to sign the data on the way into the server.

#### Offering a JSON API

Write a gem to fetch an application's stats via JSON.

#### Live Updating

Use JavaScript to dynamically update the data without a full-page refresh.

#### Sending Highlights

Send a summary of a specific site's statistics via email when activated by a certain URL.

## Evaluation

### Evaluation Criteria

