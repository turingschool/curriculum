---
layout: page
title: TrafficSpy
---

## Abstract

In this project you'll use Ruby, Sinatra, and Sequel to build a web traffic tracking and analysis tool.

Your application will be live on the Internet. It will recieve data over HTTP from a simulation engine. The simulator will construct and transmit HTTP requests which include tracking data.

Imagine that I run a commercial website and embed JavaScript code which gets activated each time a page is viewed on my site. That JavaScript captures information about the visitor and the page they're viewing then, in the background, submits that data to *your* TrafficSpy application.

Your application parses and stores that data.

Later, I visit your site and can view data about my traffic through a HTML interface.

## Learning Goals

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

### Requirements

The project must use:

* [Sinatra](http://www.sinatrarb.com/)
* [PostgreSQL](http://www.postgresql.org/)
* [Sequel](http://sequel.rubyforge.org/)

### Restrictions

The project may not use:

* `ActiveRecord`
* Rails°
* `Sequel::Model`

°: You may use parts of `ActiveSupport` if you so choose

## Base Expectations

### Application Registration

To register with your application, the client will submit a request to:
```
http://yourapplication:port/sources
```

Parameters:

* identifier
* rootUrl

Example Request:

{% terminal %}
$ curl -i -d 'identifier=jumpstartlab&rootUrl=http://jumpstartlab.com'  http://localhost:4567/sources
{% endterminal %}

Possible Responses:

* Missing Parameters - 400 Bad Request

If missing any of the required parameters return status `400 Bad Request` with
a descriptive error message.

* Identifier Already Exists - 403 Forbidden

If that identifier already exists return status `403 Forbidden` with a
descriptive error message.

* Success - 200 OK

When the request contains all the required parameters return status `200 OK`
with the following data for the client:

```
{"identifier":"jumpstartlab"}
```

* identifier - the unique identitier for the application that has been created
  for the client.

### Processing Requests

A registered application will send `POST` requests to the following URL:

```
http://yourapplication:port/sources/IDENTIFIER/data
```

Where `IDENTIFIER` is the unique identifier generated previously for this site.
The request will contain a parameter named 'payload' which contains JSON data with this structure:

```
payload = {
  "url":"http://jumpstartlab.com/blog",
  "requestedAt":"2013-02-16 21:38:28 -0700",
  "respondedIn":37,
  "referredBy":"http://jumpstartlab.com",
  "requestType":"GET",
  "parameters":[],
  "eventName": "socialLogin",
  "userAgent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17",
  "resolutionWidth":"1920",
  "resolutionHeight":"1280",
  "ip":"63.29.38.211"
}
```

Your application should extract, analyze, and store all the content in the
payload based on the view requirements defined below.

Example Request:

{% terminal %}
curl -i -d 'payload={"url":"http://jumpstartlab.com/blog","requestedAt":"2013-02-16 21:38:28 -0700","respondedIn":37,"referredBy":"http://jumpstartlab.com","requestType":"GET","parameters":[],"eventName": "socialLogin","userAgent":"Mozilla/5.0 (Macintosh%3B Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17","resolutionWidth":"1920","resolutionHeight":"1280","ip":"63.29.38.211"}' http://localhost:9393/sources/jumpstartlab/data
{% endterminal %}

### Possible Outcomes:

#### Missing Payload - 400 Bad Request

If the payload is missing return status `400 Bad Request` with a descriptive
error message.

#### Already Received Request - 403 Forbidden

If the request payload has already been received return status `403 Forbidden`
with a descriptive error message.

#### Application Not Registered - 403 Forbidden

When data is submitted to an application URL that does not exist, return a `403 Forbidden` with a descriptive error message.

#### Success - 200 OK

When the request contains a unique payload return status `200 OK`.

## Viewing Data & Statistics

### Application Details

A client is able to view aggregate site data at the following address:

```
http://yourapplication:port/sources/IDENTIFIER
```

When an identifer exists return a page that displays the following:

* Most requested URLS to least requested URLS (url)
* Web browser breakdown across all requests (userAgent)
* OS breakdown across all requests (userAgent)
* Screen Resolution across all requests (resolutionWidth x resolutionHeight)
* Longest, average response time per URL to shortest, average response time per URL
* Hyperlinks of each url to view url specific data
* Hyperlink to view aggregate event data

When an identifier does not exist return a page that displays the following:

* Message that the identifier does not exist

### Application URL Statistics

A client is able to view URL specific data at the following address:

```
http://yourapplication:port/sources/IDENTIFIER/urls/RELATIVE/PATH

Examples:

http://yourapplication:port/sources/jumpstartlab/urls/blog
http://yourapplication:port/sources/jumpstartlab/urls/article/1
http://yourapplication:port/sources/jumpstartlab/urls/about
```

When the url for the identifier does exists:

* Longest response time
* Shortest response time
* Average response time
* Which HTTP verbs have been used
* Most popular referrrers
* Most popular user agents

When the url for the identifier does not exist:

* Message that the url has not been requested

### Application Events Index

A client is able to view aggregate event data at the following address:

```
http://yourapplication:port/sources/IDENTIFIER/events
```

When events have been defined:

* Most received event to least received event
* Hyperlinks of each event to view event specific data

When no events have been defined:

* Message that no events have been defined

### Application Event Details

A client is able to view event specific data at the following address:

```
http://yourapplication:port/sources/IDENTIFIER/events/EVENTNAME

Examples:

http://yourapplication:port/sources/jumpstartlab/events/startedRegistration
http://yourapplication:port/sources/jumpstartlab/events/addedSocialThroughPromptA
http://yourapplication:port/sources/jumpstartlab/events/addedSocialThroughPromptB
```

When the event has been defined:

* Hour by hour breakdown of when the event was received. How many were shown
  at noon? at 1pm? at 2pm? Do it for all 24 hours.
* How many times it was recieved overall

When the event has not been defined:

* Message that no event with the given name has been defined
* Hyperlink to the Application Events Index

## Extension: Campaigns

A client wants to aggregate event information into campaigns to better
visualize AB testing and successes through a series of events.

### Registering a Campaign

To register a campaign with your application, the client will submit a `POST` request to:
```
http://yourapplication:port/sources/IDENTIFIER/campaigns
```

Parameters:

* 'campaignName'
* 'eventNames'

Example AB Test Campaign:

{% terminal %}
$ curl -i -d 'campaignName=socialSignup&eventNames[]=addedSocialThroughPromptA&eventNames[]=addedSocialThroughPromptB'  http://localhost:4567/sources/IDENTIFIER/campaigns
{% endterminal %}

Example AB Test Campaign:

{% terminal %}
$ curl -i -d 'campaignName=socialSignup&eventNames[]=registrationStep1&eventNames[]=registrationStep2&eventNames[]=registrationStep3&eventNames[]=registrationStep4'  http://localhost:4567/sources/IDENTIFIER/campaigns
{% endterminal %}

Possible Outcomes:

* Missing Parameters - 400 Bad Request

If missing any of the required parameters return status `400 Bad Request` with
a descriptive error message.

* Campaign Already Exists - 403 Forbidden

If that campaign name already exists return status `403 Forbidden` with a
descriptive error message.

* Success - 200 OK

When the request contains all the required parameters return status `200 OK`

## Viewing a Campaign

**Application Campaigns Index**

A client is able to view all defined campaigns at the following address:

```
http://yourapplication:port/sources/IDENTIFIER/campaigns
```

When campaigns exist:

* Hyperlinks of each campaign to view campaign specific data

When there are no campaigns defined:

* A message that states no campaigns have been defined

**Application Campaign Details**

A client is able to view campaign specific data at the following address:

```
http://yourapplication:port/sources/IDENTIFIER/campaigns/CAMPAIGNNAME
```

When the campaign exists:

* Most received event to least receieved event
* Hyperlinks of each event to view event specific data

When the campaign does not exist:

* message that states no campaign with that name exists
* Hyperlink back to the Application Campaigns Index

## Extension: Provide a JSON API

Provide JSON API endpoints to your site.

* http://localhost:9393/sources/IDENTIFIER.json
* http://localhost:9393/sources/IDENTIFIER/urls.json
* http://localhost:9393/sources/IDENTIFIER/events.json
* http://localhost:9393/sources/IDENTIFIER/campaigns.json

The content of the json response should be comparable set of information that a user sees on the equivalent HTML page.

## Extension: Dynamic Display

Presuming that a user is likely to keep statistics pages open for a long time, use JavaScript to dynamically update the displayed statistics and rankings *without a full-page refresh*.

## Extension: Authenticated Data

When the system creates an account, generate and return a public key. Use public/private key cryptography to sign the data on the way into the server.

## Evaluation Criteria

This project will be peer assessed using automated tests and the criteria below.

1. Correctness
2. Testing
3. Style
4. Effort