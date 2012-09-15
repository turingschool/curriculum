---
layout: page
title: Canvas Basics
---

### Create a canvas element

Let's change our `<body>` again to use a canvas tag:

```html
<h1>Learning Canvas</h1>
<canvas id='drawing' width="600" height="400"></canvas>
```

Now, we should have a nice canvas on our page, but it starts out blank. Time to draw!

### Draw a rectangle

To draw a rectangle, we need to get the context element from the dom, then run a few functions on it:

```js
function ready() {
  var canvas = document.getElementById("drawing");
  var context = canvas.getContext("2d");
  context.fillStyle = "#333333";
  context.fillRect(0,0,300,200);
}
```

Let's walk through this. First, we get the canvas element by its `id` like we did in the previous lesson. Next, we run the `getContext` function that the canvas has on it. This will get us a context to draw on in two dimensions. There is a three dimensional context too, but it's more difficult to use. Next, we set the canvas's fill style to a gray color. This doesn't do any drawing yet, it's more like choosing a color in photoshop. Last, we'll call the `fillRect` function to draw a rectangle. This function has four parameters: x position, y position, width, and height.

Let's tweak some of those parameters. Try a few different colors, even using rgba syntax like `rgba(32, 64, 128, 0.5)`. Trying making a rectangle of a different size or position. Try making more rectangles at different positions.

### Rectangle function

To make our coding life easier, let's make a rectangle function. We'll need to move our variables outside the ready function so the rectangle function can use it, plus we'll want to allow the rectangle properties to be passed in as parameters.

```js
var context;
function rectangle(color, x, y, width, height) {
  context.fillStyle = color;
  context.fillRect(x, y, width, height);
}
function ready() {
  var canvas = document.getElementById("drawing");
  context = canvas.getContext("2d");
  rectangle("#333333", 0, 0, 300, 200);
  rectangle("#999999", 100, 100, 300, 200);
}
```

Now it's a lot easier to make rectangles by using our simple rectangle function.

### Text

Let's add another function for drawing text, using the canvas function `fillText`:

```js
function text(message, color, x, y) {
  context.fillStyle = color
  context.font = "30px sans-serif";
  context.fillText(message, x, y);
}
function ready() {
  var canvas = document.getElementById("drawing");
  context = canvas.getContext("2d");
  rectangle("#333333", 0, 0, 300, 200);
  rectangle("#999999", 100, 100, 300, 200);
  text("Hello World", "FF0000", 50, 50);
}
```

The `fillText` function works pretty similar to the rectangle function, except it needs a font. Now we have all the basic tools we need to draw stuff with canvas.

