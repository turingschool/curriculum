---
layout: page
title: JS Outside the Browser
section: JavaScript & AJAX
---

### Setup

```plain
brew install node
```

### REPL

* Start `node`
* Try using `alert`
* Try using `console.log`
* Create a variable
* Use an `if` statment
* Add an `else`
* Write a function (without return)
* Refer to the function by name
* Call the function
* Re-write the function with return
* Call it
* Ctrl-D to Exit

### Executable

Create a `sample.js` file with the following content:

```javascript
var hello = function(){
  return "hello, world";
}

console.log(hello());
```

Then run it from the terminal:

```plain
node sample.js
```
