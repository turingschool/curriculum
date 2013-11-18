---
layout: page
title: History of JavaScript
section: JavaScript & AJAX
---

### JavaScript Origins

* 1995 Internet Explorer & Netscape Navigator battle for market share
* MS implements VBScript (based on Visual Basic) for light programming in the browser
* Netscape wants to offer a similar alternative and hops on the popularity of Java (a language for "real" programmers) causing mass confusion
* Standards process started in 1996 as ECMAScript
* "JavaScript" trademark is owned by...

### Ajax

* Asynchronous JavaScript and XML
* XMLHttpRequest created by Microsoft in 1999
* Gmail in 2004 and Google Maps in 2005 put XMLHttpRequest in popular use
* Now typically using JSON as the transport, AJAJ

### V8 Engine

* Released with Chrome in 2008
* Compiles JavaScript to native machine code
* Optimizes code on the fly
* Opened the door for Node.js

### Node.js

* Started by Ryan Dahl in 2009
* V8 engine plus a core library
* Emphasis on asynchronous & non-blocking operations

A "hello world" application:

```
var http = require('http');
 
http.createServer(
  function (request, response) {
    response.writeHead(200, {'Content-Type': 'text/plain'});
    response.end('Hello World\n');
  }
).listen(8000);
 
console.log('Server running at http://localhost:8000/');
```

### Node-based Frameworks

* Express.js is like Sinatra: http://expressjs.com/api.html
* [Geddy.js](http://geddyjs.org/tutorial) and [Derby.js](http://derbyjs.com/) are more MVC-like frameworks
* [Tower.js](http://tower.github.io/guide) provides ActiveRecord-like access