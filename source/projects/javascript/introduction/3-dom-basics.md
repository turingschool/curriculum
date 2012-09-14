---
layout: page
title: DOM Basics
---

### Output to the DOM

First, we're going to need a place to put our output. Let's change the body of our page:

```html
<body onload='ready()'>
  <h1>Learning Javascript</h1>
  <pre id='output'></pre>
</body>
```

The pre has the id `output`, which will let us grab it from Javascript. Next, let's setup our body and function to run when the page is ready:

```js
function ready() {
  alert('ready to go');
}
```

Now, we can use some of the DOM functions to grab the `pre` and change its content:

```js
function ready() {
  document.getElementById('output').innerHTML = "Hello <strong>there</strong>";
}
```

That's a pretty long way to just output some text. Let's make a function to do it for us:

```js
function output(message) {
  document.getElementById('output').innerHTML = message;
}
function ready() {
  output("Hello friend");
}
```

Now let's output multiple messages:

```js
function output(message) {
  document.getElementById('output').innerHTML = message;
}
function ready() {
  output("Hello friend");
  output("Hello enemy");
}
```

This time, it will say "Hello enemy", and "Hello friend" got overwritten. We'd really like `output` to append to the pre each time, so we'll use Javascript's `+=` operator, which will append to the string:

```js
function output(message) {
  document.getElementById('output').innerHTML += message + '<br>';
}
```

We also add a `<br>` so that it breaks the line for each message.

### Output based on Data

Now it's time to join all of our powers together to output information to the dom based on some data:

```js
var data = [4, 2, 9, 7];
function ready() {
  for (i in data) {
    output(data[i]);
  }
}
```

Now, let's do something crazy: a loop inside a loop!

```js
var data = [4, 2, 9, 7];
function ready() {
  for (i in data) {
    var number = data[i];
    var message = ""
    while (number > 0) {
      message += "|";
      number--;
    }
    output(message);
  }
}
```

So, what's going on here? First, we get the number from the array and set it to the `number` variable. Then, we create a `message` variable that starts off as an empty string. Next, we are going to keep looping as long as the number is 0. Each time we loop, we add a `|` to the message, and we decrement the number with `--`. `number--` is like saying `number = number - 1`. Once `number` hits 0, we output the message. So, each step of the loop looks like this:

<table class='table'>
  <tr>
    <th>Step</th>
    <th>number</th>
    <th>message</th>
  </tr>
  <tr><td>1</td><td>4</td><td>""</td></tr>
  <tr><td>2</td><td>3</td><td>"|"</td></tr>
  <tr><td>3</td><td>2</td><td>"||"</td></tr>
  <tr><td>4</td><td>1</td><td>"|||"</td></tr>
  <tr><td>5</td><td>0</td><td>"||||"</td></tr>
</table>

And, we will do this for every element in our data array. The result: a bar chart, circa 1985!

<pre>
||||
||
|||||||||
|||||||
</pre>