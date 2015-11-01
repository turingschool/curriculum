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

That's HTTP.

### Base Expectation

You can make your own server if you can accept a request,
parse it (which means turn the string into something more useful, like a hash),
and write the response.

The format of the request and response is defined by something called "http",
which probably stands for something, but those words won't help you understand it,
so lets just talk about how it works, and then, if you need more context,
you can read the [wikipedia article](https://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol)
or the specification [https://tools.ietf.org/html/rfc2616](https://tools.ietf.org/html/rfc2616).


## The HTTP Request

### Example:

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

### Anatomy of a [Request](https://tools.ietf.org/html/rfc2616#section-5):

1. The first line aka [Request-Line](https://tools.ietf.org/html/rfc2616#section-5.1)
  1. The method aka verb ("POST")
  2. The path ("/to_braille")
  3. The HTTP version ("HTTP/1.1")
2. [Headers](https://tools.ietf.org/html/rfc2616#section-4.2)
  * Any number of "Key: Value" pairs
  * Some headers have meaning, eg `Content-Length` tells you how long the body is (20 characters)
3. [Body](https://tools.ietf.org/html/rfc2616#section-7.2)
  * 0 or more characters. We don't have to care what they represent as the server, we'll let the application deal with that.
  * We need to be careful to not read too far, or it will lock up our server. We can tell how much to read by checking the `Content-Length` header.
    If no `Content-Length` header is provided, the body should be assumed to be 0 characters.

### View an HTTP request

First, we'll start a server that prints requests and lets us type the responses in:

```
$ nc -l 9292
```

And now click this link: [http://localhost:9292/this/is/the/path](http://localhost:9292/this/is/the/path)

You can either quit out, or you can type a response like the following.
If you type the response, then be careful not to press return before typing
(then you would be on the second line), and remember it won't think you're done
giving it headers until it sees the empty line, so that last time, you'll have
to press return 2 times (once to end the header, and once for the empty line).

```
HTTP/1.1 302 Found
Location: http://turing.io

```


## The HTTP Response

### Example:

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

### Anatomy of a [Response](https://tools.ietf.org/html/rfc2616#section-6):

1. The first line aka [Status-Line](https://tools.ietf.org/html/rfc2616#section-6.1)
  1. The HTTP version "HTTP/1.1"
  2. The status code (eg 301)
  3. The reason phrase (eg "Moved Permanently") I call this the "status code for humans"
2. [Headers](https://tools.ietf.org/html/rfc2616#section-4.2)
  * Any number of "Key: Value" pairs
  * Ending when you find a blank line
3. [Body](https://tools.ietf.org/html/rfc2616#section-7.2)
  * You don't need to worry about setting the `Content-Length` or `Content-Type` fields,
    we'll let the app do that.

### View an HTTP response

We'll use a program called `curl` to make a request from the command line.
It normally prints just the body, but if we give it the `-i` flag, it will print
the whole response.

```
$ curl -i 'http://google.com'
```


## Getting comfortable

To familiarize yourself with this stuff, try making some requests using curl,
and look at them to see what all is interesting! The first one will be: `$ curl -i 'http://google.com'`

* http://google.com
* https://api.github.com/users/JoshCheek

Try writing some responses by hand using `nc -l 9292`
Can you do these things?

* Redirect the browser (status code of `302` and header named `Location`)
* Return this html `<h1>i am a header</h1>` (`Content-Type` header needs to be `text/html`, set the `Content-Length` header, and body, too)
* Try starting the server on a couple of different ports and hitting them in the browser
* Set a cookie (forgot what the header is, I think it's `Set-Cookie` with a key/value pair like `my_cookie=yummy`, then make a second request and see that the browser sends you back the cookie you set)
* Search for something on [http://www.amazon.com/](http://www.amazon.com/), then replace `www.amazon.com` with `localhost:9292`
  All that crap at the end of the path is called the query string. Take a guess where it's going to be in the request.
* See a form submission (edit any form on any page to point at your server -- another way is to start your Rails server,
  request the form, stop the server, start nc on that port, and then submit it)
* Render arbitrary other headers and see that they are present in the browser (the browser will typicall have a network tab where you can see info like this, search "help" for "dev tools" or something)
* Start nc on two different ports and redirect the browser from the one to the other, then you can see it come in twice.


## Accepting a request from Ruby

```ruby
# Tell my computer that web requests to http://localhost:9292 should be sent to me
require 'socket'
port       = 9292
tcp_server = TCPServer.new(port)

# Wait for a request
client = tcp_server.accept

# Read the request
first_line = client.gets
puts "The first line is: #{first_line}"

# Write the response
client.print("HTTP/1.1 302 Found\r\n")
client.print("Location: http://turing.io\r\n")
client.print("Content-Type: text/html; charset=UTF-8\r\n")
client.print("Content-Length: 219\r\n")
client.print("\r\n")
client.print("<HTML><HEAD></HEAD><BODY></BODY>\r\n")
client.close

# I'm done now, computer ^_^
tcp_server.close_read
tcp_server.close_write
```

## The interface you must support

### What does a webserver do?

* Receive the request
* Parse it into a Hash (this is called the `env` hash, more about it below)
* Call into the application, (Sinatra or Rails or whatever)
* The application returns the instructions for what to put in the response,
  an array with the status code, headers, body, eg:

  `[302, {'Location' => 'http://turing.io'}, ["<h1>hi</h1>"]]`
* Write the response

### The interface

We'll define the interface like this:

```ruby
# You'll need to pass this through to the TCPServer
port = 9292

# The app:
#   You're serving the code, the app is responsible for deciding what to do with the request.
#   An app is any object that has a method named `call`
#   that can receive a the hash you parsed from the request
#   and return an array with these three things in it
app = lambda do |env_hash|
  [302, {'Location' => 'http://turing.io'}, ["<h1>hi</h1>"]]
end

# For clarity:
env_hash = {} # What you parse from the request
app.call(env_hash) # => [200, {"Content-Type"=>"text/plain", "Content-Length"=>"5"}, ["hello"]]

# Your server takes the port and the app, starts up when we call start, closes the read / write when we call stop
server = HttpYeahYouKnowMe.new(port, app)
server.start # this will lock the computer up as it waits for the request to come in
server.stop
```

### The env hash

The keys to this hash are mostly pre-defined (as in: go hard code them into the hash).
Some of the headers might not be (I found a list [here](https://github.com/rack/rack/blob/028438ffffd95ce1f6197d38c04fa5ea6a034a85/lib/rack/lint.rb#L65)).
...don't worry about that stuff until after you get Sinatra working ;)

I do know that you can run the Sinatra framework
using this hash (rack.input should be the body, I think... you'll have to play with it to see!)

```ruby
require 'stringio'

# You for sure need these keys:
{"REQUEST_METHOD" => "GET", "PATH_INFO" => "/users/456", "rack.input" => StringIO.new}
```

To figure out what you're supposed to set the other keys to,
define a web app that will let you explore the keys,
and then hand it to a real server:

```
$ gem install rack puma
```

In a file called "config.ru"

```ruby
class LetsGoExploring
  def call(hash)
    status_code = 200
    headers     = {'Content-Type' => 'text/html;', 'Content-Length' => '15'}
    body        = ["<h1>Hello!</h1>"]

    require "pry"
    binding.pry

    [status_code, headers, body]
  end
run
```

Then run it with

```
$ rackup config.ru -p 9292
```

And now click this link: [http://localhost:9292/this/is/the/path](http://localhost:9292/this/is/the/path)


## Toplevel tests... Start Here

Because the server must wait until the request is made, it will lock the program up.
And since the program is locked up, it can't send the request!

To get around this, we have to use something called a thread.
But this project isn't about threads,
so I'm giving you the toplevel tests that you need to pass.

First make sure you have the gems we need

```ruby
$ gem install rspec mrspec rest-client
```

Then put the following code in `spec/acceptance_spec.rb`.
While working on this, you're going to need to parse HTTP requests
and generate HTTP responses.
You'll want to do that in other code that can be tested without the need for the server to be running.
You write those tests in rspec, or minitest,
because [mrspec](https://rubygems.org/gems/mrspec) can run them both
by just running `$ mrspec` from the root of your project.
Just use whichever you're most comfortable with.

```ruby
require_relative '../lib/http_yeah_you_know_me'
require 'rest-client' # you may need to `gem install rest-client`

RSpec.describe 'Acceptance test' do
  def run_server(port, app, &block)
    server = HttpYeahYouKnowMe.new(port, app)
    thread = Thread.new { server.start }
    thread.abort_on_exception = true
    block.call
  ensure
    thread.kill
    server.stop
  end


  it 'accepts and responds to a web request' do
    path_info = "this value should be overridden by the app!"

    app = lambda do |env_hash|
      path_info = env_hash['PATH_INFO']
      body      = "hello, class ^_^"
      [200, {'Content-Type' => 'text/plain', 'Content-Length' => body.length, 'omg' => 'bbq'}, [body]]
    end

    run_server 9292, app do
      response = RestClient.get 'localhost:9292/users'
      expect(response.code).to eq 200
      expect(response.headers[:omg]).to eq 'bbq'
      expect(response.body).to eq "hello, class ^_^"
      expect(path_info).to eq '/users'
    end
  end


  it 'handles multiple requests' do
    app = lambda { |env_hash| [200, {'Content-Type' => 'text/plain'}, []] }

    run_server 9292, app do
      expect(RestClient.get('localhost:9292/').code).to eq 200
      expect(RestClient.get('localhost:9292/').code).to eq 200
    end
  end


  it 'starts on the specified port' do
    app = lambda { |env_hash| [200, {'Content-Type' => 'text/plain', 'Content-Length' => 5}, ['hello']] }

    run_server 9292, app do
      expect(RestClient.get('localhost:9292/').body).to eq 'hello'
    end
  end
end
```

## Serving Your NightWriter

This code uses a Ruby web framework called Sinatra
to make a web interface to your NightWriter project.
First, get yours working using a real server,
then switch the `use_my_server`
variable to have it use your server instead of the real one.
You're going to have to edit it to work with your NightWriter instead of mine.

Install Sinatra with `gem install sinatra`
Put the file in `examples/night_writer.rb`
And then execute it with `ruby examples/night_writer.rb`

```ruby
# go to http://localhost:9292/to_braille

# require your code you used for NightWriter
# note that we are talking to it through a web interface instead of a command-line interface
# hope you wrote it well enough to support that ;)
require '/Users/josh/deleteme/night_writer/lib/night'

# require a webserver named Sinatra
require 'sinatra/base'

class NightWriterServer < Sinatra::Base
  get '/to_braille' do
    "<form action='/to_braille' method='post'>
      <input type='textarea' name='english-message'></input>
      <input type='Submit'></input>
    </form>"
  end

  post '/to_braille' do
    message = params['english-message']
    braille = Night::Write.call(message) # <-- change this to look like your night writer code
    "<pre>#{braille}</pre>"
  end
end


# switch this to use your server
use_my_server = false

if use_my_server
  require_relative 'lib/http_yeah_you_know_me' # <-- probably right, but double check it
  server = HttpYeahYouKnowMe.new(9292, NightWriterServer)
  at_exit { server.stop }
  server.start
else
  NightWriterServer.set :port, 9292
  NightWriterServer.run!
end
```


## Assessment Rubric

Coming eventually. Pass my acceptance tests and you'll be in a really really good spot :)

### 1. Overall Functionality

* 4: Serves your night wrighter (or some other project)
* 3: Passes my acceptance tests up above
* 2: Passes 2 of my acceptance tests up above
* 1: Passes 1 of my acceptance tests up above

### 2. Test-Driven Development

1 point for each of these:

* Your tests all pass
* You have tests on all behaviour of parsing requests and generating responses.
* Your tests describe the behaviour in human readable words (eg "it stores the first word in the REQUEST_METHOD key")
* Parsing / Generating code know nothing about sockets
  (it receives an IO object, but don't know it's a socket vs a file),
  and they know nothing about the app.
  Keep them simple, good code is identifiable because it makes everything look easy.

### 3. Code Sanitation

This one is pass / fail.
Your indentation must be right, according to the [indentation guide](https://gist.github.com/JoshCheek/b3c6a8d430b2e1ac8bb2).
Keep your indentation correct the whole time.
When you enter a class/method/block, you indent. When you leave, you outdent.
If this is hard, then add one of those tools that checks it for you.

### 4. Knowledge Retention

1 Point for each of these!

* You can recite the anatomy of a request and of a response, without any aid.
* Using `$ curl -i some-url` to see a response
  * You can show me a redirect
  * You can show me an html body
  * You can show me a JSON body, and tell me what header will be different from the HTML one
* Using `$ nc -l 9292` and typing in the response by hand
  * You can show me a GET request that was sent from your browser
  * You can show me a POST request that was sent from your browser (edit a form)
  * You can set a cookie
  * You can redirect the browser to [http://turing.io](http://turing.io/)
  * You can serve HTML and have it highlighted
  * You can serve the same HTML, but change 1 header to not have it highlighted

### 5. Adoration points

These don't go to anything, but I will give you mad adoration points if you practice until
you can delete your parsing code and then use your tests to rewrite it (one failure at a time,
stating out loud what each failure is going to be), in less than 10 minutes.
