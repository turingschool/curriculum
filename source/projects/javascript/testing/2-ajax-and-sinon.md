---
layout: page
title: AJAX and Sinon.js
---

Javascript really gets its strengths from creating dynamic web pages, and a necessary component of that is AJAX. AJAX stands for Asynchronous Javascript and XML, and it is a technique which uses javascript to fetch data from a web server. It happens asynchronously, which means you can continue to run javascript code while the request is still pending. The XML part was the original use of AJAX, but nowadays people use all kinds of content-types as the return value from the server. The most common is JSON (Javascript Object Notation) but HTML is often used when it's simply some dynamic template data that should be inserted into the DOM.

## AJAX Basics

### XHR

XHR (XML HTTP Request) is the browser's implementation of asynchronous data requests. It's the "raw layer" like canvas that is part of a browser's native library. Like cavnas, it has a lot of low-level functions that are a bit painful to use, and it also has slightly different implementations across different browsers.

We aren't going to cover XHR, as very few projects ever deal with it directly.

### $.ajax

jQuery is the ultimate library for cross-browser compatibility, and it contains some great methods for making ajax requests. Here is an example ajax call to POST data to a server:


