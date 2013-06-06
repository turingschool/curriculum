---
layout: page
title: HelloJQ
---

The first step in any new programming language is to output **Hello, World**. 

Dumb convention from the history of software development? Sure! Will you be *forever cursed* if you don't start with Hello, World? Definitely!

So we'd better take care of that, here goes.

### I0: Plain Old HTML

Our project is to create some plain old HTML then, on the fly, have jQuery inject the "Hello, World".  Let's start with this basic HTML in a file named `index.html`:

```html
<html>
  <head>
    <title>HelloJQ</title>
  </head>
  <body>
    <h1 class='target'>Hello, sad and plain HTML world.</h1>
  </body>
</html>
```

Open that in your browser and you should just see a simple H1 with the text you entered.

### I1: Incorporating jQuery

Let's first load the jQuery library.  We'll pull it straight from Google's superfast servers for now by adding this line inside your `head` tags:

```html
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.1/jquery.min.js"></script>
```

Refresh your page and...well...it'll look the same.  Did the library load?  

In Chrome you can open the developer console by opening the developer tools. It can be found in the application menu *VIEW > DEVELOPER > DEVELOPER TOOLS*.  Go to the RESOURCES tab, enable resource tracking, then look to see if it loads the jQuery library.  If there's an error you'll see a red X in the bottom right corner of the developer pane.  If there's no error then you're ready to move on.

![image](hellojq-developer-tools-error.png)

### I3: An Inline Script

The simplest way to write Javascript is to do so right in the markup.  Below the `script` tags which load jQuery, add this second set of script tags:

```html
<script type='text/javascript'>
    $(function (){
        $('h1.target').text("Hello, World! jQuery Rocks!");
    });
</script>
```

Refresh your browser and your H1 text should switch up.  You're now a jQuery programmer, kinda.

What is all that?  Let's look at it line by line:

```html
<script type='text/javascript'>
```

Tell the browser we're about to give it some Javascript, then...

```javascript
$(function (){
```

The `$` is an alias for the jQuery library itself.  jQuery is made to work on the DOM, the content of the HTML document, but the Javascript is usually loaded in the HEAD of the document.  By default most browsers are going to start executing Javascript as soon as they receive it.  If our script runs before the content of the page loads, however, it won't find the object we're looking to replace.

Almost all jQuery scripts start out with this line.  `$` calls jQuery, and the jQuery function takes a function to run on the start of the page.  This has become such a common paradigm that it is the default behavior of `$()` when a function is passed as the first argument.  Then the open parenthesis wraps the parameter to ready and the `function` keyword starts declaring a new function.  The empty parentheses mean that this anonymous function won't have any parameters, then the `{` starts the body of the function.  A lot for one line, right?

Why do we need to pass a function instead of just some instructions? If we just put in instructions they will be executed when the script is first read by the browser.  If we want the browser to wait until some event happens before running the code, we need to put it into a function.

Next we have...

```javascript
$('h1.target').text("Hello, World! jQuery Rocks!");
```

Again `$` is the jQuery library and we pass it the parameter `'h1.target'`.  This is a css selector which finds all `h1` objects in the DOM that have the class name `target`.  Then for each one of them it executes the `.text` method. The `.text` method when given a parameter will change the object to have that text. Calling the method without the parameter will return the current text in the object.

So to read this line in English we might say "Hey jQuery, find all H1 elements with the class name target and set their containing text to the string 'Hello, World! jQuery Rocks!'."

Then, finally, we have these two lines:

```html
    });
</script>
```

The first line has a `}` which closes the function, then a `)` which closes the parameters to the `$()` method and a semicolon marking the end of the line.  The second line closes the @script@ tag.

### I4: Moving to an External Script

If we're just writing a few lines it's fine to leave it in the head of our document, but for serious use we'll want to pull our jQuery code out into it's own file.  Create a file named `application.js` in the project directory and move all these lines over there:

```javascript
$(function (){
    $('h1.target').text("Hello, World! jQuery Rocks!");
});
```

Then, in your HTML file, change the second set of script tags to this:

```html
<script src='application.js'></script>
```

Refresh your browser and it should work the same as before.

### Complete HelloJQ

Here are my complete files at the end:

#### application.js

```javascript
$(function (){
    $('h1.target').text("Hello, World! jQuery Rocks!");
});
```

#### index.html

```html
<html>
  <head>
    <title>HelloJQ</title>
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.1/jquery.min.js"></script>
    <script src="application.js"></script>
  </head>
  <body>
    <h1 class='target'>Hello, sad & plain HTML world.</h1>
  </body>
</html>
```
