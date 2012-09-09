---
layout: page
title: AJAX and Sinon.js
---

Javascript really gets its strengths from creating dynamic web pages, and a necessary component of that is AJAX. AJAX stands for Asynchronous Javascript and XML, and it is a technique which uses javascript to fetch data from a web server. It happens asynchronously, which means you can continue to run javascript code while the request is still pending. The XML part was the original use of AJAX, but nowadays people use all kinds of content-types as the return value from the server. The most common is JSON (Javascript Object Notation) but HTML is often used when it's simply some dynamic template data that should be inserted into the DOM.

## AJAX Basics

### XHR

XHR (XML HTTP Request) is the browser's implementation of asynchronous data requests. It's the "raw layer" like canvas that is part of a browser's native library. Like canvas, it has a lot of low-level functions that are a bit painful to use, and it also has slightly different implementations across different browsers.

We aren't going to cover XHR, as very few projects ever deal with it directly.

### GETting data with $.ajax

jQuery is the ultimate library for cross-browser compatibility, and it contains some great methods for making ajax requests. Here is an example ajax call to GET data from a server:

```js
$.ajax('/circles').done(function(data) {
  console.log("got some data:", data)
});
```

In this example, if we assume a RESTful endpoint `data` would be a JSON array containing a list of circles in the system, like:

```
[
  { x: 1,  y: 1,  radius: 5 },
  { x: 12, y: 5,  radius: 8 },
  { x: 20, y: 15, radius: 2 }
]
```

Notice that since this is an asynchronous operation, the data is not immediately available. Instead, we pass a function to the `done` method on the object returned by `ajax`. The `done` method will be called with the data when the ajax request is complete. There is also `fail` for an error, and `always` for both cases.

So, let's make a class called `Circles` whose job will be to fetch circle data from the server and then call a callback with instantiated `Circle` objects. We would like to use it like this:

```js
Circles.fetch(function(circles) {
  for(i in circles) {
    var circle = new Circle(circles[i]);
    circle.draw();
  }
});
```

Start by making a spec file called `CirclesSpec.js` in the `spec/` directory. In here, write:

```js
describe("Circles", function() {
  it("should fetch from a server", function() {
    var callback = jasmine.createSpy('callback');
    var data = [
      {x: 0,  y: 0,  radius: 5},
      {x: 10, y: 10, radius: 10}
    ];
    spyOn($, 'ajax').andReturn({
      done:function(callback) { callback(data); }
    });

    Circles.fetch(callback);

    expect($.ajax).toHaveBeenCalledWith("/circles");

    var circles = callback.mostRecentCall.args[0];
    expect(circles.length).toEqual(data.length);

    for ( i in data ) {
      for ( f in data[i] ) {
        expect(circles[i][f]).toEqual(data[i][f]);
      }
    }
  });
});
```

Let's walk through this spec. First, we are describing our new object, `Circles`. Next, we have our `it` test for fetching against our server. Then, we're making a callback spy. If you glance forward to line 12, you can see this is the callback we're going to call `fetch` with. 

Lines 4-10 setup the fake data we'll respond with and set up the spy on `$.ajax` to return an object with `done` on it that calls the given callback with the data we provided.

After we call the `fetch` method, we start asserting. We check that `$.ajax` was called with the proper url first. Then we get the callback spy's most recent call so we can see what instantiated circles were passed back.

Then, we iterate over the data and the fields in the data to ensure that each of the circles returned matched the data.


On your own, implement `Circles.fetch` to pass this test. Don't forget to add script tags to the html function to include the spec file, your source file, and jQuery (via google's ajax apis with http:// on the front).

## Faking a server with Sinon.js


So, what do we think of the previous test and the solution? It certainly is doing a good job testing the `fetch` function on `Circles`, but it is also very verbose and spends most of its time setting up the relationship with `$.ajax`. On top of that, it is highly coupled with the implementation.

jQuery is a very flexible library, and instead of using `$.ajax(url).done(callback)`, we could have written:

```js
$.get('/circles', function(data) {
  // ...
});
```

And it would work perfectly well, but our test would fail completely. This is where Sinon steps in. Jasmine's spies are written to work with simple Javascript objects and functions, but Sinon takes it a step further.

Let's walk through writing a Jasmine test with a fake Sinon server. First, let's setup our test scaffold:

```js
describe("with fake server", function() {
  beforeEach(function () {
  });
  afterEach(function () {
  });
  it("fetches Circles", function () {
  });
});
```

Next, inside the `describe` we will set up our data as before, along with a variable to keep track of our fake server:

```js
describe("with fake server", function() {
  var data = [
    {x: 0,  y: 0,  radius: 5},
    {x: 10, y: 10, radius: 10}
  ];
  var server;
  // ...
});
```

When we start our test, we want to setup sinon's fake server, and when we end our test, we want to restore the original implementation:

```js
beforeEach(function () {
  server = sinon.fakeServer.create();
});

afterEach(function () {
  server.restore();
});
```

Inside our `it` function, first we setup the sinon server to respond to our expected request:

```js
server.respondWith("GET", "/circles", [
  200, {"Content-Type":"application/json"}, JSON.stringify(data)
]);
```

This tells sinon to respond to a GET request at the `/circles` url with a 200 (success). It should also add the response header for `Content-Type` that signifies JSON data. Then, the data returned should be a JSON string of our `data` variable. So, sinon will send our `data` back to anyone who fetches data from `/circles`.

Next, we will setup a jasmine spy as our callback and fetch from the server:

```js
var callback = jasmine.createSpy('callback')
Circles.fetch(callback);
server.respond();
expect(callback).toHaveBeenCalled();
```

We have to tell the sinon server to respond to any pending ajax requests at this point, and then we will check to see that our callback has been called.

Last, we can grab the results of the callback and compare them with our data to ensure the `fetch` method processed the data correctly:

```js
var circles = callback.mostRecentCall.args[0];
expect(circles.length).toEqual(2);

for (i in data) {
  for (f in data[i]) {
    expect(circles[i][f]).toEqual(data[i][f]);
  }
}
```

That makes sure that the x, y, and radius in our data matches our circles.

Run this test, and it should pass. Note that since your previous test was faking out `$.ajax`, you will have to remove that test (or at least commented it out) so that `$.ajax` reaches the Sinon server.

Try a few variations of jQuery's ajax functions:

```js
$.ajax("/circles").done(function(data) { ... });
$.get("/circles", function(data) { ... });
$.ajax({
  url: "/circles",
  success: function(data) {...}
})
```

Do they all work?


## A Quick Aside: Jasmine Matchers

One thing we'd like to check in our previous test is that `Circles.fetch()` actually gives us `Circle` objects back. A simple test in javascript would look like this:

```js
if (someCircle instanceof Circle) {
  alert("It's a circle!");
}
```

So, we could write this in Jasmine:

```js
expect(circle instanceof Circle).toBe(true);
```

But it would be way cleaner if we wrote this:

```js
expect(circle).toBeA(Circle);
```

To do that, we have to write a custom matcher. Add a `SpecHelper.js` file in `/spec` and include it in our test suite with a `<script>` tag. Then, add this to `SpecHelper.js`:

```js
beforeEach(function() {
  this.addMatchers({
    toBeA: function(expectedClass) {
      console.log("We should make sure that", this.actual, "is an instance of", expectedClass);
      return true;
    }
  });
});
```

Modify the contents of the `toBeA` function to return whether or not the object (`this.actual`) is an instance of the class (`expectedClass`).

Now, add in our check in our test:

```js
for (i in data) {
  // our new check
  expect(circles[i]).toBeA(Circle);
  for (f in data[i]) {
    expect(circles[i][f]).toEqual(data[i][f]);
  }
}
```

## POSTing data

Go over creating a new circle on the server, semi-guided (we do)

## Updating and deleting data

As an exercise, implement a PUT and a DELETE to update and delete the circles.
