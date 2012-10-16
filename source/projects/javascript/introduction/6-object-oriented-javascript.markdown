---
layout: page
title: Object Oriented Javascript
---

So far, our charting library has been very functionally organised.  We have top level functions on the main area of the page, and they all reference each other in a disorganized way.  In this chapter, we're going to revisit our core functions and organize them into object-oriented classes.

### Prototypical Classes

Javascript's class system is "Prototypical" because when classes are created, they have a "Prototype" object that is copied for each instance.  Let's look at an example:

```js
var Person = function(name) {
  this.name = name;
}
Person.prototype = {
  sayHello: function() {
    alert("Hello, I am "+this.name);
  }
}

var joe = new Person('Joe');
joe.sayHello();
```

First, we are setting up the `Person` variable to store a function.  This function is known as the `constructor` or `initializer` because it is called when a new person is created.  It takes a `name` argument which it simply sets on itself to use later.

Next, we define the `prototype` attribute on the function.  By defining a `prototype`, when `new` is called, the new object will have a copy of the prototype attached to it.  Meaning that any objects on the prototype are available on the object itself.

We can then call `joe.sayHello()`, which will run the `sayHello` function on the prototype in the context of `joe`, so that `this.name` exists from the constructor step.


Add a few more methods and some more constructor arguments to the person class. What happens if you make one of the prototype attributes something other than a function?


### A Note on Inheritance

Javascript does not natively support inheritance, since classes can only have one prototype. However, many libraries like [underscore.js](http://underscorejs.org) provide a way to extend an existing prototype with new methods.  Some libraries even support a system of prototype method chaining to support `super`.

### The Chart Class

The first class we'll make is a `Chart` class that will support some of our common functions used across all our charts:

```js
var Chart = function(context) {
  this.context = context;
};
Chart.prototype = {
  rectangle: function(color, x, y, width, height) {
    this.context.fillStyle = color;
    this.context.fillRect(x, y, width, height);
  }
}
```

Now that we have the chart class, we can use it in our `ready` function like this:

```js
var context = document.getElementById('drawing').getContext('2d');
var chart = new Chart(context);
chart.rectangle('red', 0, 0, 300, 200);
```

On your own, add the `text` method to the `Chart` class, and then call it from the `ready` function.


### The Bar Chart Class

Next, we can create a `BarChart` class to encapsulate the Bar Chart drawing logic.  First, we'll setup our constructor:

```js
var BarChart = function(context, data) {
  this.context = context;
  this.data = data;
}
```

A Bar Chart will need an additional option when constructed: the data it needs to draw. Other than that, it just needs a context like our Chart class. Now let's write the prototype:

```js
BarChart.prototype = {
  rectangle: Chart.prototype.rectangle,
  bar: function(x, y) {
    this.rectangle("rgb(64, 64, 128)", 0, x*12, y*10, 10);
  },
  draw: function() {
    for (i in this.data) {
      this.bar(i, this.data[i]);
    }
  }
}
```

First off, we're copying (actually, just referencing) the `Chart` class's rectangle function. This way we can bring in functionality from the `Chart` class to use in our `BarChart` class. Next, we've got a `bar` function that calls our `rectangle` function just like it did in the previous lesson, except we're calling it on `this`, since our function is now encapsulated in the class.

Lastly, we have a `draw` function that does the data loop for us. The only difference is calling `this.bar` and `this.data`. That means our `ready` function can simply be:

```js
var context = document.getElementById('drawing').getContext('2d');
var barChart = new BarChart(context, [4, 8, 12, 1, 7]);
barChart.draw();
```

{% exercise %}

### Experiment: Pie Chart and Line Chart

On your own, convert your pie chart methods and line chart methods into classes. Once you have them set up, try some of the following challenges:

1. Add a `color` parameter to the bar chart constructor so you can set the color when you call new
  1. Next, if a color parameter is not passed in, default to black. (HINT: what is the value of `color` when it is not sent in to the constructor as a parameter?)
1. Add a starting x and y to the constructor for your charts to tell it where to start drawing that chart on the screen. Then draw one of each chart on the canvas side by side.
1. Add a `setData` function to one of your charts that overwrites its `data` attribute and re-draws itself.

{% endexercise %}