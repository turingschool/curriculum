---
layout: page
title: Javascript Basics
---

### Functions

As we saw in the previous lesson, code can be encapsulated into a function and then run from a different point. Let's add another function and have one call the other:

```js
function message() {
  return 'hey there, world!';
}
function sayHello() {
  alert(message());
}
```

When `sayHello` runs, it makes an alert, but it gets the text for the alert from another function, `message`. `message` does something new: `return`. Return will send data back to the place the function was called. That means that the returned string gets plugged in to the `alert` function. Pretty neat!

Now, it wouldn't be fun if functions always did the same thing, so let's add a parameter:

```js
function message(name) {
  return 'hey there, ' + name + '!';
}
function sayHello() {
  alert(message('your name'));
}
```

Now the `message` function takes a parameter, `name`. It can use the name when building its string. Where does it get the name? From the place it was called in `sayHello`. When we call the function, we can put parameters inside the parenthesis.

### Variables

Let's change the name a different way: with a variable. A variable in Javascript is different from a variable in math. In Javascript, a variable is more like a bucket that can hold a value. Then you can check the bucket later on to see what the value is, or you can set a different value inside the bucket. Here's how to use a variable:

```js
var name = 'Joe';
function message() {
  return 'hey there, ' + name + '!';
}
function sayHello() {
  alert(message());
  name = 'Bob';
  alert(message());
}
```

The `message` function uses the value of the name variable to make the message. Then inside `sayHello` we alert with the first name (Joe) then we change the name and alert again. This time, when `message` checks the name, it's been set to Bob.

### Conditionals

In Javascript, you can decide whether or not to perform an action by using a conditional. Conditionals are things like `if`, `else`, and `switch`. Let's take a look at using an if/else with our code:

```js
var name = 'Joe';
function message() {
  if (name === 'Joe') {
    return 'hey buddy!';
  } else {
    return 'do I know you?';
  }
}
function sayHello() {
  alert(message());
}
```

If you reload the page, it will say 'hey buddy!' because name is Joe. But try changing the name variable to something else and reloading the page.

### Looping

Sometimes, you have to process a lot of items. For example, let's say we needed to greet three people. First, let's see how we can put those people into an `Array`:

```js
var names = ['Joe', 'Bob'];
alert(names[0]);
alert(names[1]);
```

Arrays are lists of items. You can get to a value in an array by asking by `index`, which is the position in the array. Indexes start at 0 and count up. So `names[0]` is `'Joe'` and `names[1]` is `'Bob'`.

However, if we wanted to write code that doesn't need to know how many names are in the array, we would have to use a loop:

```js
var names = ['Joe', 'Bob'];
for (i in names) {
  alert(names[i]);
}
```

This is a `for` loop. It will iterate through each index in the array and assign the index to the `i` variable. `i` could be anything we want. We could have called it `position` or something else, because it is a variable.

There is another kind of `for` loop, and also a `while` loop, as shown below:

```js
var names = ['Joe', 'Bob'];
for (var i = 0; i < names.length; i++) {
  alert(names[i]);
}

var i = 0;
while(i < names.length) {
  alert(names[i]);
  i++;
}
```

The above syntax for a `for` loop is more complicated than the previous syntax, but it is also more powerful, as you could change the way Javascript performs the looping. `while` loops are usually used in scenarios where you want to perform the same action over and over until something in the system changes.

{% exercise %}

### Experiment

Experiment with your code for a bit. 

1. Try modifying the names array, or loop over different content in a different way. 
1. Try using more than one variable to combine them into a more complicated message based on conditionals.

{% endexercise %}