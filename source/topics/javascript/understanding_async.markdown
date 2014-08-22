---
layout: page
title: Understanding Asynchronous Code
section: JavaScript & AJAX
---

Asynchronous events and non-blocking I/O are two of the core principles of Node. In a blocking environment, if you open a file or make an HTTP request, the program pauses until that information is received. This blocks further execution of the program. In a non-blocking environment, the program execution continues and it's up to you to handle the data as they're received.

Here is an example of blocking code in Ruby.

```rb
require 'open-uri'

open("http://tutorials.jumpstartlab.com/")
puts "The page has been loaded."

puts "This is a second message."
```

This program runs as you'd expect:

1. It fetches the webpage
2. It prints `"The page has been loaded."`
3. It prints `"This is the second message."`

Let's take a look at the same code in Node (you made need to run `npm install request` first):

```js
var request = require('request');

request('http://tutorials.jumpstartlab.com', function (error, response, body) {
  console.log('The page has been loaded.');
});

console.log('This is the second message.');
```

This program will run slightly differently:

1. It makes a request to fetch the webpage and moves on.
2. It prints `'This is the second message.'`
3. When it receives the data from the webpage, it fires it's callback, which prints `'The webpage has been loaded.'`

Let's take a look at another example:

```js
var request = require('request');

var webpage;

request('http://tutorials.jumpstartlab.com', function (error, response, body) {
  webpage = body;
});

console.log(webpage);
```

This program will print `undefined` to the console because Node will have moved on before `request` has received a response from the webpage.

You'll have to deal with the webpage in the callback itself:

```js
var request = require('request');

var webpage;

request('http://tutorials.jumpstartlab.com', function (error, response, body) {
  webpage = body;
  console.log(webpage);
});
```
