---
layout: page
title: JavaScript Outside of the Browser
section: JavaScript & AJAX
---

## What is Node?

Node.js is a server-side platform built on Chrome's V8 JavaScript runtime. It uses non-blocking I/O and asynchronous events. It's lightweight, efficient, and commonly used for real-time web applications.

### History

Node.js was released by Ryan Dahl in 2009. Ryan didn't set out to create a server-side JavaScript implementation. It was the asynchronous, non-blocking part that he was interested in. Ryan originally tried to accomplish this using C, Lua, and Haskell. Ryan turned his attention to JavaScript when Google open-sourced its V8 JavaScript engine.

## Getting Started

### Installing Node

The easiest way to install Node is to Head over to the [official website][node] and download the installer. Alternatively, you can use [Homebrew][hb] or [nvm][].

[node]: http://nodejs.org/
[hb]: http://thechangelog.com/install-node-js-with-homebrew-on-os-x/
[nvm]: https://github.com/creationix/nvm

Installing Node should automatically install [npm][] as well. You can test to see if it's installed by typing `which npm` into the terminal.

[npm]: http://npmjs.org

### The Node REPL

Node comes with a REPL built-in. Unlike Ruby, this isn't a separate binary like `irb`. You can begin the Node REPL by typing `node` at the command line.

Try the following:

* `2 + 2;`
* `console.log('Hello');`
* `var x = 42;`
* `x`
* `var hello = function () { return 'hello'; };`
* `console.log(hello());`

Press `^C` twice to exit the REPL.

### Running a Node Program from the Command Line

Create a new file called `sample.js` with the following content:

``` js
var hello = function(){
  return "hello, world";
}

console.log(hello());
```

Then run it from the terminal:

``` bash
node sample.js
```

## Modules and CommonJS

Node has a [simple module system][nodemodules] based on the [CommonJS module specification][cjs]. Node files and modules have a one-to-one correspondence.

[nodemodules]: http://nodejs.org/docs/latest/api/modules.html#modules_modules
[cjs]: http://wiki.commonjs.org/wiki/Modules/1.1


To require a module, `foo.js`, you would do the following:

``` js
var foo = require('./foo.js');
```

The file extension is optional and the variable name is arbitrary. You can call it anything you'd like, but you must store it in a variable. The following is also valid:

``` js
var bar = require('./foo');
```

You must explicitly include a module in every file you use it in. Requiring a module in a top-level file will not make it available throughout your application.

### Requiring Built-in Modules

Node has an intentionally small standard library. The standard library is documented in the [Node API Documentation][apidocs].

[apidocs]: http://nodejs.org/documentation/api/

The standard library can be required from any Node.js program. You do not have to give a relative path. To use the HTTP library, require it as follows:

``` js
var http = require('http');
```

### Using Events and EventEmitter

You can also require specific parts of a module.

EventEmitter is a class that is used throughout Node (e.g. in the `http` module) and many third-party libraries and allows Node applications to respond to events that happen during the lifetime of the application. A server would want to respond requests or connections. In this case, a connection to the server would be considered an event.

```js
var EventEmitter = require('events').EventEmitter;
```

The `EventEmitter` class allows you to create an object that can listen for and respond to events.

Create a file named `events.js` with the following content:

```js
var EventEmitter = require('events').EventEmitter;

var server = new EventEmitter();

server.on('connect', function () {
  console.log('A client has connected.');
});

server.on('disconnect', function () {
  console.log('A client has disconnected.');
});

server.emit('connect');
server.emit('disconnect');
```

Run the file using `node events.js`.

### A Simple HTTP Server

Create a file `server.js`.

The built-in `http.Server` module inherits from `EventEmitter`.

```js
var http = require("http");

var server = http.createServer()

server.listen(3000, function () {
  console.log('The HTTP server is listening at Port 3000.');
});

server.on('request', function(request, response) {
  response.writeHead(200, {"Content-Type": "text/plain"});
  response.write("Hello World");
  response.end();
});
```

When the server receives a request, a "request" event is emitted and the server responds with a simple HTTP response.

Try it in your terminal `node server.js`

In traditional web servers, a new thread is created every time a request is received. The program exits after the request is sent. In Node, your server runs on a single thread that waits for requests. This means that we can store data in variables and this state will persist between requests. Let's modify our server to take advantage of this:

```js
var http = require("http");

var server = http.createServer()

server.listen(3000, 'localhost');

var counter = 0;

server.on('request', function(request, response) {
  response.writeHead(200, {"Content-Type": "text/plain"});
  response.write("Hello World\n");
  response.write("This is Request #" + ++counter + ".");
  response.end();
});
```

We can use `curl` to test the server.

```sh
curl http://localhost:3000/
```

Our server should respond with the following:

```sh
Hello World
This is Request #1.
```

The request number will increment upon further requests. If you use a web browser, you'll notice that the request number might increment by 2 each time you make a request on the server. This is because some browsers make a request for a favicon each time as well.

### Creating Modules

Creating modules in Node is simple, but you must explicitly export any functionality that you want to make available.

Create two files: `foo.js` and `bar.js`.

`bar.js` should have the following content:

```js
exports.addTwo = function (addend) {
  return addend + 2;
};

var addThree = function (addend) {
  return addend + 3;
};
```

`foo.js` should have the following content:

```js
var bar = require('./bar');

console.log(bar.addTwo(2)); // Logs 4.

// Since we only exported `addTwo`, attempting to use `addThree` will throw an exception.

console.log(bar.addThree(2)); // TypeError: Object #<Object> has no method 'addThree'
```

If you are only exporting one function or object, you can use `module.exports` instead of defining properties on the `exports` object.

Replace the contents of `bar.js` with the following:

```js
module.exports = function (addend) {
  return addend + 2;
};
```

Replace the contents of `foo.js` with the following:

```js
var addTwo = require('./bar');

console.log(addTwo(2)); // Logs 4.
```

## package.json

`package.json` is a manifest that contains information about your Node application/module and its dependencies. You can create a `package.json` file by hand or you can let npm guide you through the process using the following command:

``` bash
npm init
```

npm will ask you a series of questions about your application.

`package.json` can contain any data you want, but certain properties have particular meanings in Node.

Here is an example of a `package.json` manifest.

```plain
{
  "name": "example-application",
  "version": "0.0.0",
  "description": "An example Node.js application.",
  "main": "index.js",
  "scripts": {
    "test": "mocha ./test"
  },
  "author": "Jumpstart Lab",
  "license": "MIT"
}
```

For more information on `package.json`, please refer to [Nodejitsu's `package.json` cheatsheet][pcs].

[pcs]: http://browsenpm.org/package.json

## npm

[npm][] is the package manager for node.

npm creates a `node_modules` folder in your current directory and downloads modules and their dependencies into that folder.

Modules in your `node_modules` folder can be required without using relative paths.

From the command line, type the following:

```
npm install request
```

This will install the `request` module and all of its dependencies into your local `node_modules` folder.

The following command will record the dependency in your `package.json`:

``` bash
npm install request --save
```

The example `package.json` from above should now look as follows:

```plain
{
  "name": "example",
  "version": "0.0.0",
  "description": "An example Node application.",
  "main": "index.js",
  "scripts": {
    "test": "mocha ./test"
  },
  "author": "Jumpstart Lab",
  "license": "MIT",
  "dependencies": {
    "request": "^2.40.0"
  }
}
```

The `node_modules` directory is typically not checking into version control (by way of `.gitignore`). This means that you when you clone a repository, you won't get the dependencies along with it.

The following command scans `package.json` for any dependencies and installs them.

```bash
npm install
```

Sometimes you want a library in development that you don't necessarily need in production. In this case, you would use the following command:

```bash
npm install jasmine-node --save-dev
```

This will install the module and add it to your `package.json` as a `devDependency`. The example `package.json` file now looks like this:

```plain
{
  "name": "example",
  "version": "0.0.0",
  "description": "An example Node application.",
  "main": "index.js",
  "scripts": {
    "test": "mocha ./test"
  },
  "author": "Jumpstart Lab",
  "license": "MIT",
  "dependencies": {
    "request": "^2.40.0"
  },
  "devDependencies": {
    "jasmine-node": "^1.14.5"
  }
}
```

In addition to creating web servers in Node, you can also create command line utilities. If we wanted to install Jasmine as a command line utility, we would need to install it globally.

```bash
sudo npm install -g jasmine-node
```

The `-g` flag signifies that you'd like to install the binary globally. By default, you'll need to use `sudo` to install global binaries.
