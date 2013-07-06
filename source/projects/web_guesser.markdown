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

* Save it in SublimeText
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