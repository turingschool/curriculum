---
layout: page
title: HTTP, Yeah You Know Me!
sidebar: true
---

## Project Overview

In this project we'll begin to introduce HTTP, the protocol that runs the web, and build a functioning web server to put that understanding into action.

### Learning Goals

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
POST /to_braille HTTP/1.1
Host: localhost:9292
Connection: keep-alive
Content-Length: 20
Cache-Control: max-age=0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
Origin: http://localhost:9292
Upgrade-Insecure-Requests: 1
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.85 Safari/537.36 OPR/32.0.1948.25
Content-Type: application/x-www-form-urlencoded
Referer: http://localhost:9292/to_braille
Accept-Encoding: gzip, deflate, lzma
Accept-Language: en-US,en;q=0.8

english-message=asdf
```

The parts we're most interested in are:

* The first line, `POST /to_braille HTTP/1.1`, which specifies the *verb*, *path*, and *protocol* which we'll pick apart later
* `Host` which is where the request is sent to
* `Accept` which specifies what format of data the client wants back in the response
* `Origin` which is the return address

With those pieces of information a typical server can generate a response.

### The Response

The Server generates and transmits a response that looks like this:

```
HTTP/1.1 301 Moved Permanently
Location: http://www.google.com/
Content-Type: text/html; charset=UTF-8
Date: Sat, 26 Sep 2015 21:51:13 GMT
Expires: Mon, 26 Oct 2015 21:51:13 GMT
Cache-Control: public, max-age=2592000
Server: gws
Content-Length: 219
X-XSS-Protection: 1; mode=block
X-Frame-Options: SAMEORIGIN

<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">
<TITLE>301 Moved</TITLE></HEAD><BODY>
<H1>301 Moved</H1>
The document has moved
<A HREF="http://www.google.com/">here</A>.
</BODY></HTML>
```

The parts we're most interested in are:

* The first line, `HTTP/1.1 301 Moved Permanently`, which has the *protocol* and the *response code*
* The unmarked lines after `X-Frame-Options` which make up the *body* of the response

## Experiment

Ruby has handy built-in libraries for dealing with most of the low-level networking details about running a server. Let's write a short program that can start up, listen for a request, print that request out to the screen, then shut down.

First, we need to "open a port" which basically means "tell the computer that network requests identified addressed for a specific port should belong to this program".

On your computer there are dozens of programs that are using the network connection at any given time. If the messages in and out of those programs were all happening through the same channel then it'd be confusing which message belongs to which program. Think of the *port* like a mailbox in an apartment building: all the residents (aka programs) share the same street address (your computer) but each have their own mailbox (or port).

Let's start our server instance and have it listen on port `9292`:

```ruby
require 'socket'
tcp_server = TCPServer.new(9292)
```

Then tell that server to accept a request and store it into a variable we'll call `request`:

```ruby
client = tcp_server.accept
request = client.read
```

Note that when the program runs it'll hang on that `read` method call waiting for a request to come in. When it arrives it'll get `read`, stored into `request`, then we want to print it out:

```ruby
puts request.inspect
```

Then send back a response:

```ruby
client.print("HTTP/1.1 302 Found\r\n")
client.print("Location: http://turing.io\r\n")
client.print("Content-Type: text/html; charset=UTF-8\r\n")
client.print("Content-Length: 219\r\n")
client.print("\r\n")
client.print("<HTML><HEAD></HEAD><BODY>It works!</BODY>\r\n")
client.close
```

And close up the server:

```ruby
tcp_server.close_read
tcp_server.close_write
```

Save that file and run it. Open your web browser and enter the address `http://127.0.0.1:9292`. If everything worked then your browser should show the words *It works!*. Flip over to the terminal where your ruby program was running and you should see the request outputted to the terminal.

You just built a web server.

[TODO: Validate that this really works. Post a second file or Gist with the whole code together.]

## The Project

You're going to build a web application capable of:

* Receiving a request from a user
* Comprehending the request's intent and source
* Generating a response
* Sending the response to the user

### Version 0 - Hello, World

Build a web application/server that:

* listens on port 9292
* responds to HTTP requests
* responds with a valid HTML response that displays the words `Hello, World! (0)` where the `0` increments each request until the server is restarted

### Version 1 - Outputting Diagnostics

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

### Version 2 - Supporting Paths

Now let's react to the `path` that the user specifies:

* If they request the root, aka `/`, respond with just the debug info from V1.
* If they request `/hello`, respond with "Hello, World! (0)" where the `0` increments each time the path is requested, but not when any other path is requested.
* If they request `/datetime`, respond with today's date and time in this format: `11:07AM on Sunday, October November 1, 2015`.
* If they request `/shutdown`, respond with "Total Requests: 12" where `12` is the aggregate of all requests. It also causes the server to exit / stop serving requests.

### Version 3 - Supporting Parameters

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

### Version 4 - Verbs & Parameters

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

### Version 5 - Response Codes

We use the HTTP response code as a short hand way to explain the result of the request. Here are the most common HTTP status codes:

* `200 OK`
* `301 Moved Permanently`
* `401 Unauthorized`
* `403 Forbidden`
* `404 Not Found`
* `500 Internal Server Error`

Let's modify your game from Version 4 to use status codes:

* Most requests, unless listed below, should respond with a `200`.
* When you submit the `POST` to `/new_game` and there is no game in progress, it should start one and respond with a `301` redirect.
* When you submit the `POST` to `/new_game` but there is already a game in progress, it should respond with `403`.
* If an unknown path is requested, like `/fofamalou`, the server responds with a `404`.
* If the server generates an error, then it responds with a `500`. Within the response let's present the whole stack trace. Since you don't write bugs, create an `/force_error` endpoint which just raises a `SystemError` exception.

## Extensions

## Rubric

## Addendum Content

There is content from previous versions not germane to the assignment above [available here](https://github.com/turingschool/curriculum/blob/master/source/projects/http_yeah_you_know_me-addendum.markdown).
