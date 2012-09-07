---
layout: page
title: Jasmine
---

Unit testing your code is a great way to increase code quality and prevent regressions. In this section we'll use the Jasmine javascript unit testing framework to test some example code.

## Setup

The first thing we're going to do is setup the Jasmine test framework.

### Download

Download Jasmine from GitHub:

[https://github.com/pivotal/jasmine/downloads](https://github.com/pivotal/jasmine/downloads)

This chapter is written against Jasmine 1.2.0, but feel free to try the latest stable version.

Unzip the archive that you downloaded.

### Test Suite Scaffold

Open up `SpecRunner.html` from the unzipped folder. Let's look through this file. First of all, it's an HTML file. Jasmine runs its tests by running JavaScript in the browser. Let's walk through the `head` of the document.

```html
<link rel="stylesheet" type="text/css" href="lib/jasmine-1.2.0/jasmine.css">
<script type="text/javascript" src="lib/jasmine-1.2.0/jasmine.js"></script>
<script type="text/javascript" src="lib/jasmine-1.2.0/jasmine-html.js"></script>
```

First, we're incuding the Jasmine CSS stylesheet so that our tests are displayed in a nice format. Then we're including the core `jasmine.js` library. This contains all of Jasmine's testing code. Then, we're including the `jasmine-html.js` file, which is for running Jasmine via the browser. There is also a Jasmine Ruby gem for running the tests in a ruby project.

```html
<script type="text/javascript" src="spec/SpecHelper.js"></script>
<script type="text/javascript" src="spec/PlayerSpec.js"></script>
```

Next up, we're including the sample specs that come with Jasmine as an example. Spec is short for specification, and this is where all the testing code is. We're including `SpecHelper.js` which is where they have put common testing code to be used in all the specs. We're also including `PlayerSpec.js` which is the spec for a `Player` (which we'll see in a minute).

```html
<script type="text/javascript" src="src/Player.js"></script>
<script type="text/javascript" src="src/Song.js"></script>
```

Last of the included scripts is the source code. We have a `Player` file and a `Song` file. This is where we would include all of our code to be testing.

Now let's take a look at Jasmine's bootstrapping function:


```js
(function() {
  var jasmineEnv = jasmine.getEnv();
  jasmineEnv.updateInterval = 1000;

  var htmlReporter = new jasmine.HtmlReporter();

  jasmineEnv.addReporter(htmlReporter);

  jasmineEnv.specFilter = function(spec) {
    return htmlReporter.specFilter(spec);
  };

  var currentWindowOnload = window.onload;

  window.onload = function() {
    if (currentWindowOnload) {
      currentWindowOnload();
    }
    execJasmine();
  };

  function execJasmine() {
    jasmineEnv.execute();
  }

})();
```

This is Jasmine's default bootstrapping function which sets up the Jasmine environment and the html output, then runs all the tests when the window is loaded. It also preserves the existing `window.onload` if there is one. It's a bit complicated, and can actually be simplified down to this for simple test suites that don't use a default `window.onload`:

``` js
var jasmineEnv = jasmine.getEnv();
jasmineEnv.addReporter(new jasmine.HtmlReporter());
window.onload = function() {
  jasmineEnv.execute();
};
```

This simply sets up the environment, adds the html reporter, and boots jasmine when the window has loaded. However this does not have any spec filtering (but we're not using that anyways.

### Check it out

Open the `SpecRunner.html` file in your browser and check it out. It is formatting the tests in such a way that you can read what they do and if they passed or failed (they all pass in this case).


## Writing a Spec with BDD

### Behavior Driven Development

Behavior Driven Development, or BDD, is a style of development where you define a piece of code's behavior with tests and then use those tests to drive the coding itself. You don't actually write the code until you have a test that is failing that requires you to write code to make it pass.

What differentiates BDD from TDD (test-driven development) is that BDD specifically concerns itself with the actions that a piece of code takes in order to accomplish its task. The best way to explain it is with an example, so let's write some tests.

### Add our Spec

First off, remove the script tags that include `spec/...` and `src/...`, because we're going to write our own specs and code.

We're going to BDD a `Circle` class that draws a circle in canvas. Add the following line to the `head` of `SpecRunner.html`:

```html
<script type="text/javascript" src="spec/CircleSpec.js"></script>
```

Next, open up `spec/CircleSpec.js` and write:

```js
describe("Circle", function() {
  it("should run", function() {
    expect(true).toBeTruthy();
  });
});
```

The first line, `describe` tells Jasmine what piece of code we're going to be testing against. It takes a function as a second argument, which will have all the test code in it that tests `Circle`.

Next, there is the `it` function, which describes a specific behavior. Here we are just making sure it works, so our description is simple, `"should run"`. `it` also takes a function, and inside that are the individual expectations.

`expect` takes anything, and then returns an object with matchers on it. Here we use the `toBeTruthy` matcher, which checks that what was passed in `=== true`. So, this test checks that `true === true`.

Refresh `SpecRunner.html` and you should get output like:

```
Passing 1 spec
  Circle
    should run
```

### Describe our first behavior

Now that we have our circle spec running, let's describe our first behavior. You can delete the "should run" section, since it was just to make sure it was connected properly. Instead, let's test our dimensions:

```js
describe("Circle", function() {
  it("should have an x coordinate", function() {
    var circle = new Circle(47);
    expect(circle.x).toEqual(47);
  });
});
```

Refresh `SpecRunner.html`. You should see the following error:

```
ReferenceError: Circle is not defined
```

When running our spec, the first error it encoutered is that `Circle` does not exist. Now it's time to write some source code.

Open `SpecRunner.html` and include a Circle.js source file:

```html
<script type="text/javascript" src="src/Circle.js"></script>
```

Open up `src/Circle.js` and write:

```js
function Circle() {}
```

Why only that? Why didn't we write all the code? We want our test to drive development of only what's necessary. This is enough to fix the current error, so we'll leave it at that. This way, instead of guessing what the next problem is, we'll let our test tell us.

Save the file and re-run the test suite (by refreshing `SpecRunner.html`). You should now see:

```
Expected undefined to equal 47.
```

Also, farther down the stack trace should be a line that references `CircleSpec` and it will look something like:

```
at null.<anonymous> (file://path/to/spec/CircleSpec.js:4:22)
```

That means the error is line 4 character 22 of `CircleSpec.js`. Which points to the line that expects the x coordinate to equal 47. This means that we need to set the x coordinate in the constructor, like this:

```js
function Circle(x) {
  this.x = x;
}
```

Re-run the spec, and it should pass.

### More behaviors

On your own, add a y coordinate and a radius. For each one, BDD the feature by writing a new `it(...)` for each attribute and an expectation inside it similar to the x coordinate.
