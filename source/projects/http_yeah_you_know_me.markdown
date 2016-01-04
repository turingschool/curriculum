---
layout: page
title: HTTP, Yeah You Know Me!
sidebar: true
---

## Project Overview

In this project we'll begin to introduce HTTP, the protocol that runs the web, and build a functioning web server to put that understanding into action.

### Learning Goals

* Practice breaking a workflow into a system of coordinating components
* Practice using TDD at the unit, integration, and acceptance levels
* Understand how the HTTP request/response cycle works
* Practice implementing basic HTTP requests and responses

### Background

The internet, which for most people is the web...how does that work?

HTTP (HyperText Transfer Protocol) is the protocol used for sending data from your browser to a web server then getting data back from the server. As protocols go, it's actually a very simple one.

#### HTTP with Penpals

Imagine that you're requesting information from a penpal (old school with paper, envelopes, etc). The protocol would go something like this:

* You write a letter requesting information
* You wrap that letter in an envelope
* You add an address that uniquely identifies the destination of the letter
* You hand the sealed enveloper to your mail person
* It travels through a network of people, machines, trucks, planes, etc
* Assuming the address is correct, it arrives at your penpal's mailbox
* Your penpal opens the envelope and reads the letter
* Assuming they understand your question, your penpal writes a letter of their own back to you
* They wrap it in an envelope and add an address that uniquely identifies you (which they got from the return address on *your* envelope)
* They hand their letter to their mail person, it travels through a series of machines and people, and eventually arrives back at your mailbox
* You open the envelope and do what you see fit with the information contained in there.

#### HTTP in Actuality

Metaphor aside, let's run through the protocol as executed by computers:

* You open your browser and type in a web address like `http://turing.io` and hit enter. The URL (or "address") that you entered is the core of the letter.
* The browser takes this address and builds a *request*, the envelope. It uniquely identifies the machine (or *server*) out there on the internet that the message is intended for. It includes a return address and other information about the requestor.
* The request is handed off to your Internet Service Provider (ISP) (like CenturyLink or Comcast) and they send it through a series of wires and fiber optic cables towards the server
* The request arrives at the server. The server reads the precisely formatted request to figure out (a) who made the request and (b) what they requested
* The server fetches or calculates the requested information and prepares a *response*. The response wraps the requested information in an envelope that has the destination address on it (your machine).
* The server hands the response off to their ISP and it goes through the internet to arrive at your computer
* Your browser receives that response, unwraps it, and displays the data on your machine.

That's HTTP. You can read more on [wikipedia article](https://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol)
or the [IETF specification](https://tools.ietf.org/html/rfc2616).

### The Request

Here is what an actual request looks like. Note that it's just a single highly-formatted string:

```
GET / HTTP/1.1
Host: 127.0.0.1:9292
Connection: keep-alive
Cache-Control: max-age=0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
Upgrade-Insecure-Requests: 1
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.80 Safari/537.36
Accept-Encoding: gzip, deflate, sdch
Accept-Language: en-US,en;q=0.8
```

The parts we're most interested in are:

* The first line, `POST /to_braille HTTP/1.1`, which specifies the *verb*, *path*, and *protocol* which we'll pick apart later
* `Host` which is where the request is sent to
* `Accept` which specifies what format of data the client wants back in the response

With those pieces of information a typical server can generate a response.

### The Response

The Server generates and transmits a response that looks like this:

```
http/1.1 200 ok
date: Sun,  1 Nov 2015 17:25:48 -0700
server: ruby
content-type: text/html; charset=iso-8859-1
content-length: 27

The response body goes here
```

The parts we're most interested in are:

* The first line, `HTTP/1.1 200 ok`, which has the *protocol* and the *response code*
* The unmarked lines at the end which make up the *body* of the response
* `content-length` which tells the client when to stop listening

### Tooling

While working on this project you're going to need to make a lot of HTTP requests. There are many
tools that can help you with that, but we recommend you use the following:

1. **Web Browser** -- if you need to make HTTP GET requests you can use the browser, but it's the weakest of these three tools.
2. [**Postman**](https://chrome.google.com/webstore/detail/postman/fhbjgbiflinjbdggehcddcbncdddomop?hl=en) -- a Chrome extension which gives you amazing control and the ability to make any kind of request. Use this for your manual testing and experimentation.
3. [**Hurley**](https://github.com/lostisland/hurley) -- a Ruby library for making requests and parsing responses. Use this for your automated testing, basically like a scripted version of request/reponse cycles you could do with Postman.

## Experiment

Ruby has handy built-in libraries for dealing with most of the low-level networking details about running a server. Let's write a short program that can start up, listen for a request, print that request out to the screen, then shut down.

First, we need to "open a port" which basically means "tell the computer that network requests identified addressed for a specific port should belong to this program".

On your computer there are dozens of programs that are using the network connection at any given time. If the messages in and out of those programs were all happening through the same channel then it'd be confusing which message belongs to which program. Think of the *port* like a mailbox in an apartment building: all the residents (aka programs) share the same street address (your computer) but each have their own mailbox (or port).

Let's start our server instance and have it listen on port `9292`:

```ruby
require 'socket'
tcp_server = TCPServer.new(9292)
client = tcp_server.accept
```

We can read the request from the `client` object which is what we call an IO stream. Here's a snippet to keep reading from that stream until the input is a blank line and store all the request lines in an array `request_lines`:

```ruby
puts "Ready for a request"
request_lines = []
while line = client.gets and !line.chomp.empty?
  request_lines << line.chomp
end
```

Note that when the program runs it'll hang on that `gets` method call waiting for a request to come in. When it arrives it'll get read and stored into `request_lines`, then lets print it to the console for debugging:

```ruby
puts "Got this request:"
puts request_lines.inspect
```

Then it's time to build a response. For this example let's just print out the request data as the response:

```ruby
puts "Sending response."
response = "<pre>" + request_lines.join("\n") + "</pre>"
output = "<html><head></head><body>#{response}</body></html>"
headers = ["http/1.1 200 ok",
          "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
          "server: ruby",
          "content-type: text/html; charset=iso-8859-1",
          "content-length: #{output.length}\r\n\r\n"].join("\r\n")
client.puts headers
client.puts output
```

And close up the server:

```ruby
puts ["Wrote this response:", headers, output].join("\n")
client.close
puts "\nResponse complete, exiting."
```

Save that file and run it. Open your web browser and enter the address `http://127.0.0.1:9292`. If everything worked then your browser should show all the details of your request. Flip over to the terminal where your ruby program was running and you should see the request outputted to the terminal.

You just built a web server.

Having trouble? Check out the [whole file here](https://github.com/turingschool/curriculum/blob/master/source/projects/http_yeah_you_know_me.rb).

## The Project

You're going to build a web application capable of:

* Receiving a request from a user
* Comprehending the request's intent and source
* Generating a response
* Sending the response to the user

### Iteration 0 - Hello, World

Build a web application/server that:

* listens on port 9292
* responds to HTTP requests
* responds with a valid HTML response that displays the words `Hello, World! (0)` where the `0` increments each request until the server is restarted

### Iteration 1 - Outputting Diagnostics

Let's start to rip apart that request and output it in your response. In the body of your response, include a block of HTML like this including the actual information from the request:

```html
<pre>
Verb: POST
Path: /
Protocol: HTTP/1.1
Host: 127.0.0.1
Port: 9292
Origin: 127.0.0.1
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
</pre>
```

Keep the code that outputs this block at the bottom of all your future outputs to help with your debugging.

### Iteration 2 - Supporting Paths

Now let's react to the `path` that the user specifies:

* If they request the root, aka `/`, respond with just the debug info from V1.
* If they request `/hello`, respond with "Hello, World! (0)" where the `0` increments each time the path is requested, but not when any other path is requested.
* If they request `/datetime`, respond with today's date and time in this format: `11:07AM on Sunday, October November 1, 2015`.
* If they request `/shutdown`, respond with "Total Requests: 12" where `12` is the aggregate of all requests. It also causes the server to exit / stop serving requests.

### Iteration 3 - Supporting Parameters

Often we want to supply some data with a request. For instance, if you were submitting a search, that'd typically be a `GET` request that has a parameter. When we use parameters in `GET` requests they are embedded in the URL like this:

```
http://host:port/path?param=value&param2=value2
```

You know your computer has a dictionary built in, right? Write an "endpoint" that works like this:

* The path is `/word_search`
* The verb will always be a `GET`
* The parameter will be named `word`
* The value will be a possible word fragment

In your HTML response page, output one of these:

* `WORD is a known word`
* `WORD is not a known word`

Where `WORD` is the parameter from the URL.

### Iteration 4 - Verbs & Parameters

The *path* is the main way that the user specifies what they're requesting, but the secondary tool is the *verb*. There are several official verbs, but the only two typical servers use are `GET` and `POST`.

We use `GET` to fetch information. We typically use `POST` to send information to the server. When we submit parameters in a `POST` they're in the body of the request rather than in the URL.

Let's write a simple guessing game that works like this:

#### `POST` to `/start_game`

This request begins a game. The response says `Good luck!` and starts a game.

#### `GET` to `/game`

A request to this verb/path combo tells us:

* a) how many guesses have been taken.
* b) if a guess has been made, it tells what the guess was and whether it was too high, too low, or correct

#### `POST` to `/game`

This is how we make a guess. The request includes a parameter named `guess`. The server stores the guess and sends the user a redirect response, causing the client to make a `GET` to `/game`.

### Iteration 5 - Response Codes

We use the HTTP response code as a short hand way to explain the result of the request. Here are the most common HTTP status codes:

* `200 OK`
* `301 Moved Permanently`
* `401 Unauthorized`
* `403 Forbidden`
* `404 Not Found`
* `500 Internal Server Error`

Let's modify your game from Iteration 4 to use status codes:

* Most requests, unless listed below, should respond with a `200`.
* When you submit the `POST` to `/new_game` and there is no game in progress, it should start one and respond with a `301` redirect.
* When you submit the `POST` to `/new_game` but there is already a game in progress, it should respond with `403`.
* If an unknown path is requested, like `/fofamalou`, the server responds with a `404`.
* If the server generates an error, then it responds with a `500`. Within the response let's present the whole stack trace. Since you don't write bugs, create an `/force_error` endpoint which just raises a `SystemError` exception.

## Extensions

### 1. HTTP-Accept

The `HTTP-Accept` parameter is used to specify what kind of data the client wants in response. Modify your `/word_search` path so that if the `HTTP-Accept` starts with `application/json` then they are sent a JSON body like the following.

A search for `pizza` returns this JSON:

```
{"word":"pizza","is_word":true}
```

A search for `pizz` returns JSON with possible matches like this:

```
{"word":"pizza","is_word":true,"possible_matches":["pizza","pizzeria","pizzicato"]}
```

### 2. Threading

What happens if your web server gets more than one request at a time? Let's experiment with Threads. *to be continued*

## Evaluation Rubric

The project will be assessed with the following rubric:

### 1. Overall Functionality

* 4: Application implements all five iterations and at least one extension
* 3: Application implements four iterations
* 2: Application implements three iteration
* 1: Application implements two or fewer iterations

### 2. Fundamental Ruby & Style

* 4:  Application demonstrates excellent knowledge of Ruby syntax, style, and refactoring
* 3:  Application shows some effort toward organization but still has 6 or fewer long methods (> 8 lines) and needs some refactoring.
* 2:  Application runs but the code has many long methods (>8 lines) and needs significant refactoring
* 1:  Application generates syntax error or crashes during execution

### 3. Test-Driven Development

* 4: Application is broken into components which are well tested in both isolation and integration
* 3: Application uses tests to exercise core functionality and some edge cases, but fails to break out component objects/tests.
* 2: Application uses tests to exercise core functionality but leaves many common edge cases untested.
* 1: Application does not demonstrate strong use of TDD

### 4. Breaking Logic into Components

* 4: Application effectively breaks logical components apart with clear intent and usage
* 3: Application has multiple components with defined responsibilities but there is some leaking of responsibilities
* 2: Application has some logical components but divisions of responsibility are inconsistent or unclear and/or there is a "God" object taking too much responsibility
* 1: Application logic shows poor decomposition with too much logic mashed together

## Addendum Content

There is content from previous versions not germane to the assignment above [available here](https://github.com/turingschool/curriculum/blob/master/source/projects/http_yeah_you_know_me-addendum.markdown).
