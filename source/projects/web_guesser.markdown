---
layout: page
title: WebGuesser
sidebar: true
---

In this introductory level project, you'll use Sinatra to build a number guessing game.

#### Goals

It will:

* Generate a random number on startup
* Have a web page where you can enter a guess
* Tell you whether your guess was...
  * Way too high
  * Too high
  * Correct
  * Too low
  * Way too low

## Iteration 0: Generating the Number

When we start a project we like to work in interations. You can think of an iteration like a draft when you're writing a paper. The goal of Iteration 0 is to get the program doing *something* successfully.

In this iteration, let's focus on:

* Beginning the Sinatra app
* Generating the random number
* Storing that number
* Displaying the number

### Setup the Application

In your Command Prompt:

* Use `cd` to get to your `projects` directory
* Make a new directory with `mkdir web_guesser`
* Change into that directory with `cd web_guesser`
* Create new git repository with `git init`
* Create our server file with `touch web_guesser.rb`

Then go over to SublimeText and open that `web_guesser.rb` file.

### Hello, World

Let's focus first on getting the server running. Start off your file with this:

```ruby
require 'sinatra'

get '/' do
  "Hello, World!"
end
```

And save it in SublimeText

### Start the Server

* Go back to your Command Prompt
* Start the server with `ruby web_guesser.rb`
* See output like this:

```plain
INFO  WEBrick 1.3.1
INFO  ruby 1.9.3 (2013-02-22) [x86_64-darwin12.3.0]
== Sinatra/1.3.6 has taken the stage on 4567 for development with backup from WEBrick
INFO  WEBrick::HTTPServer#start: pid=3616 port=4567
```

That says that the server started listening on port `4567`. 

Go to your web browser and open `http://localhost:4567` and you should see the output "Hello, World." Your web application and server are running!

## Iteration 1: Generating the Number

Our program should generate the secret number when it first starts up. Let's start with a number between 0 and 100.

### Using `rand`

You've probably seen the `rand` method before. It takes one argument: the upper bound of numbers you want to generate. So `rand(4)` could generate a `0`, `1`, `2`, or `3`.

Can you figure out how to use `rand` in your program to:

* Generate a number between `0` and `100`
* Output it on the page so, instead of Hello, World, it says "The secret number is X" where X is the secret number
* Make sure that when you refresh the web page you see the same number each time

### Sinatra and Code Changes

With a Sinatra application, changes you make to the server file are **not** automatically reloaded. So every time you make a change you need to stop and restart the server.

#### Setup `sinatra/reloader`

That's no fun. Let's add on a library that can automatically reload the code when changes are made. In your command prompt:

* Stop your server if it's running with `Ctrl-C`
* Install the `sinatra-contrib` gem by typing `gem install sinatra-contrib`

Then, go back to SublimeText and add a second `require` statement underneath the existing one:

```ruby
require 'sinatra'
require 'sinatra/reloader'
```

#### Test It Out

* Start your server from the command prompt
* Visit the web page and see your line like "The secret number is X"
* Go to your `web_guesser.rb` and change the capitalization to "The SECRET NUMBER is X"
* Refresh your browser and the text should change *without* having to stop/start the server

#### Thinking About Reloading

If you've done everything properly up to this point...

* A random number is generated when the server file is loaded
* Accessing the web page does *not* cause the server file to reload
* Making changes to `web_guesser.rb` causes it to automatically reload

Therefore...

* If you refresh the web page the number should not change
* If you make changes to the code, the number will change

That's just fine because when someone's actually playing the game we won't be changing the server code at the same time. We're ready to start guessing!

## I2: Using ERB and HTML

Let's move toward letting the user actually put in a guess and give feedback.

### A Web Form

In HTML the way you allow the user to enter data is through a web form.

But wait, we aren't even rendering HTML! Our server is just spitting back raw text. Let's output HTML instead.

### Rendering a Template

We're going to separate the HTML code out from our Ruby code to make things more clear.

* Create a folder within the `web_guesser` directory named `views`
* Inside that `views` folder, create a file named `index.erb`
* Cut the secret number line from `web_guesser.rb` and paste it into `index.erb`
* Where that line used to be in `web_guesser.rb`, instead put `erb :index`
* Save both files
* Refresh your web browser

You should then see something like this:

```plain
"The SECRET NUMBER is #{number}"
```

If you don't see that, use the error messages to help you debug the issue.

### What is ERB?

When we named the file `.erb` we were telling Sinatra that we're creating an ERB file. ERB stands for **E**mbedded **R**u**b**y -- it's a way of mixing plain text and Ruby together.

But it has different syntax than Ruby strings. By default, everything in an ERB file is assumed to be plain text that should be output to the browser.

#### Ruby Injection

But if we have some Ruby code that we want to run, we put in what's called a ruby injection. Try this in your ERB file:

```erb
The SECRET NUMBER is <%= rand(100) %>
```

The `<%=` marks the beginning of Ruby code and the `%>` ends it. Sinatra will run the Ruby inside those markers and output the results in that spot.

Refresh your browser and you should see the number appear.

#### Passing Variables

But if you refresh your browser again the number will change. That's no good -- it means the random number is being regenerated each request.

Instead of generating the number in the ERB file, we want to take the number that was already generated in `web_guesser.rb` and pass it into the ERB template.

Change your ERB template to output a variable named `number`:

```erb
The SECRET NUMBER is <%= number %>
```

Then, in your `web_guesser.rb`, you need to pass the local variable into the ERB template like this:

```ruby
erb :index, :locals => {:number => number}
```

Translated to English, this means "render the ERB template named `index` and create a local variable for the template named `number` which has the same value as the `number` variable from this server code."

### Writing HTML

Our current output to the browser isn't really valid HTML. The browser that we're using is "repairing" it so that it can be displayed.

Let's instead output valid HTML ourselves. Rewrite your template so it looks like this, which has the minimum valid HTML tags:

```erb
<html>
  <head></head>
  <body>
    <p>
      The SECRET NUMBER is <%= number %>
    </p>
  </body>
</html>
```

Refresh your browser and you should see ... no change. But if you view the page source (different on each browser), you should see that full HTML structure.

## I3: Guessing Numbers

At first this game will not be very challenging. We're going to let the user guess a number **and** we're going to print out the secret number at the same time!