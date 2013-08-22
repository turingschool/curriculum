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

When we start a project we like to work in iterations. You can think of an iteration like a draft when you're writing a paper. The goal of Iteration 0 is to get the program doing *something* successfully.

In this iteration, let's focus on:

* Beginning the Sinatra app
* Generating the random number
* Storing that number
* Displaying the number

### Setup the Application

In your Command Prompt:

* Install Sinatra with `gem install sinatra`
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

### Commit to Git

Let's commit our code. From the command prompt:

* `git add .` to add the new file
* `git commit -m "I0: first sinatra server"` to commit the code

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

### Commit to Git

Let's commit our code. From the command prompt:

* `git add .` to add the new file
* `git commit -m "I1: generates a random number"` to commit the code

## I2: Using ERB and HTML

Let's move toward letting the user actually put in a guess and give feedback.

### HTML & Forms

In HTML, the way you allow the user to enter data is through a web form.

But wait, we aren't even rendering HTML! Our server is just spitting back raw text. Let's output HTML instead.

### Rendering a Template

We're going to separate the HTML code out from our Ruby code to make things more clear.

* Create a folder within the `web_guesser` directory named `views`
* Inside that `views` folder, create a file named `index.erb`
* Cut the secret number line from `web_guesser.rb` and paste it into `index.erb` (the line inside your get "/" method)
* Where that line used to be in `web_guesser.rb`, instead put `erb :index`
* Save both files

Refresh your web browser

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

### Commit to Git

Let's commit our code. From the command prompt:

* `git add .` to add the new file
* `git commit -m "I2: uses an ERB template and HTML"` to commit the code

## I3: Guessing Numbers

At first this game will not be very challenging. We're going to let the user guess a number **and** we're going to print out the secret number at the same time!

### Writing an HTML Form

Now that we're rendering HTML we can create an HTML form. It goes like this:

```html
<form>
  <input type='text' name='guess' />
  <input type='submit' value='Guess!' />
</form>
```

In that code you'll see:

* Opening and closing `form` tags that mark the beginning and end of the form
* An `input` which has the `type` set to `text`. This will create a small text box that the user can type into
* An `input` which has the `type` set to `submit`. This will create a button that the user can click to submit the form. The `value=` attribute specifies the text that we want to appear on the button.

Refresh your browser and you should see the box and button appear. Go ahead and guess a number.

### Reacting to the Guess

Nothing really happens when you guess a number. But you can see the guess in the URL now, which probably looks like `http://localhost:4567/?guess=14`. Let's go back to the `web_guesser.rb` and figure out what to do with that guess.

#### Working with `params`

Inside your `get` block, add this line:

```
throw params.inspect
```

Refresh the browser and you should see a `RuntimeError`. On the second line it shows you the error message like `{"guess"=>"14"}`.

Using `throw` like this can be an quick way to understand what data looks like inside the server. What we see here is that the `params` method returns us a Ruby hash with the key `"guess"` and the value `"14"`. That 14 is what I had entered in the form.

So if we write `params["guess"]` we'll get back a string representation of the guess that the user entered in the form.

Now that we're done debugging, remove that `throw params.inspect` line.

#### Too High?

Let's tell the user when their guess is too high. Here's the pseudocode for what we want to happen on the server:

```plain
if the guess is too high
  set the message to "Too high!"
end
render the ERB template and pass in the number AND the message
```

Can you figure out how to do that? Some things to keep in mind:

* The value you get from `params['guess']` will be a string. To compare it to an integer, first convert it to an integer.
* You can pass multiple local variables to the ERB template by specifying multiple key/value pairs inside the locals hash
* You can use a new ERB injection in the `index.erb` to output the message.

When it's working correctly:

* A too low guess has no message
* A too high guess has output like this:

```plain
Too high!

The SECRET NUMBER is 32
```

#### Too low?

Once that's working, implement the logic so you get a message `Too low!` when the guess is too low.

#### Correct

With too high and too low in place, add a message `"You got it right!"` when the guess is correct.

#### Way Too

When the guess is more than five numbers too high, print a message `"Way too high!"`.

When the guess is more than five number too low, print a message `"Way too low!"`.

#### Remove the Answer

Finally, only display "The SECRET NUMBER is" line when they guess correctly.

#### Refactor

Once it's working...

1. Try to generally simplify your guess checking code
2. Pull all the checking out to it's own method so your `get` block looks like this:

```ruby
get '/' do
  guess = params["guess"]
  message = check_guess(guess)
  erb :index, :locals => {:number => number, :message => message}
end
```

To make it work as expected, you can assign the secret number to a constant:

```ruby
SECRET_NUMBER = rand(100)
```

Then the `check_guess` number could use that `SECRET_NUMBER` constant and it wouldn't change between requests.

For bonus points, do this with [Sinatra's settings feature](http://www.sinatrarb.com/configuration.html).

#### Play!

Have one of your classmates try out your guessing game!

### Commit to Git

Let's commit our code. From the command prompt:

* `git add .` to add the new file
* `git commit -m "I3: number guessing game complete"` to commit the code

## I4: Extensions

You can guess numbers, eh? Let's make it a little more interesting.

### Colorizing the Output

You could embed some CSS in your HTML to change the color. For instance, adding this `<style>` tag to the `<head>` will make the background red:

```html
<html>
  <head>
    <style>
      body {
        background: red;
      }
    </style>
  </head>
<body>
<!-- the rest of your code below -->
```

Can you make it so the background is:

* Bright red when the guess is way too high or way too low
* A light red (closer to white) when the guess is just a little bit high or low
* Green when the guess is correct

When it works correctly, commit your files to Git!

### Guess Limiting

Can you make it so they only get five guesses before a new number is generated? Some tips:

* Create a class variable with `@@` that keeps track of how many guesses they have remaining
* When subtract one from that each guess
* If the guesses reach zero, then...
  * Generate a new number
  * Set the number of guesses back to five
  * Show them a message that they've lost and a new number has been generated
* If they guess correctly, then...
  * Generate a new number
  * Set the number of guesses back to five
  * Show the message that they've guessed correctly

When it works correctly, commit your files to Git!

### Cheat Mode

Right now, our guess URLs look like this:

```
http://localhost:4567/?guess=56
```

Let's build a cheat mode. When the user manually changes the URL to look like this:

```
http://localhost:4567/?guess=56&cheat=true
```

They unlock the cheat mode. When cheat is true, the page should always print out the secret number so they can get it right on the next guess.

When it works correctly, commit your files to Git!
