---
layout: page
title: Brief Introduction to CoffeeScript
section: JavaScript & AJAX
---

With Rails 3.1, CoffeeScript has become the preferred way of writing JavaScript. Most of the community is just starting to build familiarity with the language, and we weren't JS experts to begin with! Let's work through small examples and show off some of the key ideas.

## Background

CoffeeScript is a light language that compiles down to JavaScript. Because it is a language that compiles to another language, some might classify it as a *transcompiler* instead of just a compiler. CoffeeScript's syntax is heavily inspired by Python and Ruby.  For the most part, statements in CoffeeScript correspond one-to-one with their equivalent in JavaScript.

CoffeeScript was created out of love for the JavaScript language, but also out of frustration with the JavaScript syntax.  The JavaScript syntax has a tendency to become cumbersome, verbose, and arguably, syntactically messy. The CoffeeScript syntax on the other hand, improves the readability and writabilty of equivalent code that would have otherwise been written in JavaScript.

CoffeeScript's succinct syntax offers developers an enjoyable experience, but it also includes other features that makes development more natural.  For example, it includes a simple syntax for object oriented programming, and it includes Python-like array and object comprehensions that make it easier to iterate and interact with lists and objects.

## Setup

### Local Installation

Note that some of these commands may require `sudo` depending on permissions and folder access.

First, we must install the CoffeeScript compiler.  One of the easiest ways to do this is to first install Node.js and the Node Package Manager (NPM).  The following example uses Homebrew for Mac OS X.

{% terminal %}
$ brew install node
$ curl http://npmjs.org/install.sh | sh
{% endterminal %}

For other means of installing Node and the Node Package Manager, see https://github.com/joyent/node and http://npmjs.org. For the best compatibility with CoffeeScript and other packages, install node version 0.4 rather than 0.5.

After we have the Node Package Manager installed, we can use it to install the CoffeeScript compiler.

{% terminal %}
$ npm install --global coffee-script
{% endterminal %}

This will install a new executable called `coffee` that we can use to both compile CoffeeScript scripts to JavaScript or to run an interactive CoffeeScript REPL (Read Eval Print Loop).

### Online Evaluation

For small experiments like those we'll do here, you can write and evaluate your CoffeeScript directly on the project's home page. Visit http://jashkenas.github.com/coffee-script/ and click the *Try CoffeeScript* link up top.

You'll get a window where you can write CoffeeScript on the left, see the equivalent JavaScript on the right, and click *RUN* to execute the code.

## Experiments

Let's start by playing with CoffeeScript's interactive REPL. If you're running an interpreter locally, load it with:

{% terminal %}
$ coffee
{% endterminal %}


This will open a `coffee>` prompt waiting for a line of CoffeeScript to interpret. It's similar to using Ruby's IRB terminal.

If you're using the online interpreter, open that and enter any lines we have as `coffee>` on the *left* side of the interpreter window.

### Hello

Let's first create a new variable.

    coffee> name = "John Doe"

Upon hitting `Enter`, CoffeeScript will print the return value of the last statement.  In this case, it's the value of the variable.

    coffee> name = "John Doe"
    John Doe

Next, let's use that variable and print it along with a message.

    coffee> console.log "Hello, #{name}!"
    Hello, John Doe!

Here, we used the `name` variable that we created and used it inside another string that we passed to `console.log` function.  The `console.log` printed the resulting string to the screen.  This variable substitution within a string is called string interpolation, and CoffeeScript borrows this behavior from the Ruby language.

### Compiling to JavaScript

When running CoffeeScript on your system, you can use the `coffee` command to compile CoffeeScript to JavaScript.

Create a file called `hello.coffee` that contains the same commands we used above.

    # hello.coffee
    name = "John Doe"
    console.log "Hello, #{name}!"

By passing this file to the `coffee` command, we can convert this to JavaScript.

    $ coffee -c hello.coffee

This will create a new file named `hello.js`.  Let's take a look.

    $ cat hello.js
    (function() {
      var name;
      name = "John Doe";
      console.log("Hello, " + name + "!");
    }).call(this);

If you're familiar with JavaScript, you might notice that the resulting code is wrapped in an anonymous function. CoffeeScript does this to help protect the global namespace in JavaScript.  We'll touch on this more when we talk about variables.

## Significant Whitespace

Just like Python, CoffeeScript has significant whitespace.  There is no need for curly braces or semi-colons, but you do need to ensure proper *2-space nesting conventions*.

    if sheepInMeadow and cowsInTheCorn
      blowHorn()
    else
      lookAfterSheep()

## Variables

In our first `hello.coffee` example, we saw that CoffeeScript compiled our example while wrapping everything in an anonymous function.  Variable scoping in JavaScript can sometimes be a tricky thing to master, so CoffeeScript takes some precautions to make sure our variables are only defined (or in scope) when we expect them to be.

In JavaScript, when we want to scope a variable only to the local function block, we must prefix each local variable declaration with the `var` keyword.

    // JavaScript local variable
    var local = "local variable";

If we do not remember to do this, we instead create global variables which might accidentally clobber another global variable somewhere else.

    // Whoops, a Global JavaScript variable.
    global = "global variable";

Because global variables can lead to more confusing and buggy code, we try to _avoid them_ as much as possible.  CoffeeScript avoids this problem by making all variable declarations not only local to the current function body, but even to the file itself.  This is why compiled CoffeeScript wraps each file in an anonymous function.

Let's define several variables in CoffeeScript and see what the resulting JavaScript looks like.

    # CoffeeScript
    one   = 1
    two   = 2
    three = 3

The resulting JavaScript automatically wraps everything in an anonymous function to prevent defining global variables and also automatically prefixes the variable definitions with the `var` keyword.

    // Equivalent JavaScript
    (function() {
      var one, three, two;
      one = 1;
      two = 2;
      three = 3;
    }).call(this);

This variable safety is one way that CoffeeScript handles lexical scoping of variables for us.  Lexical scoping in CoffeeScript works effectively the same as Ruby’s scope for local variables.

## Functions

Functions in CoffeeScript are defined by a list of parameters, an arrow, and the function body.  Let's define a function variable that represents the area of two sides to a rectangle.

    area = (x, y) -> x * y

The function body can also exist on subsequent indented lines.

    area = (x, y) ->
      x * y

All functions implicitly return the last value within the function body, so we could write a new `square` function the reuses the `area` function above.

    square = (x) -> area(x, x)

If a function has no parameters, you can forego the list of parameters in the function definition.

    noop = ->
      console.log("I'm a function that doesn't do much.")

### Default Parameter Values

We can also specify default values for each function parameter.

    hello = (name = "John") ->
      console.log("Hello, #{name}!")

    hello()         # prints "Hello, John!"
    hello("Jane")   # prints "Hello, Jane!"

When we call functions with parameters, the parentheses around the parameter (or argument) list is optional.

    hello "Jane"    # prints "Hello, Jane!"

However, when we call a function without any parameters, we must still supply the parentheses.

    hello()         # The parentheses are required

## CoffeeScript is a Language

That's just the tip of the iceberg. CoffeeScript started as an experiment in language design, and it's quickly making major inroads among web developers. While Rails apps can exist without it, the JavaScript-driven interactive applications of tomorrow will use it extensively.

## References

* CoffeeScript Documentation: http://jashkenas.github.com/coffee-script/
* Pragmatic Programmers "CoffeeScript": http://pragprog.com/book/tbcoffee/coffeescript
