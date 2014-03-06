---
layout: page
title: Scrabble Intermediate
---

## Getting Started

Before beginning these exercises it's expected that you have either:

* Completed an implementation of the [Fundamental Scrabble]({% page_url scrabble %}) exercises.
* Cloned the "intermediate" branch from [the Scrabble GitHub repo](https://github.com/JumpstartLab/scrabble/tree/intermediate)

## Adding Players

### Players Have Names

Build `Player` objects to support the following interactions:

{% irb %}
$ player1 = Player.new("Frank")
=> #<Player:0x007fa4a7a05cf0>
$ player2 = Player.new("Katrina")
=> #<Player:0x007fa4a7a144f8>
$ player1.name
=> "Frank"
{% endirb %}

### Tracking Letters

Players should now be able to keep track of their letters:

{% irb %}
$ player1.letters
=> []
$ player1.add_letters('a')
$ player1.add_letters('w', 'i')
$ player1.letters
=> ['a', 'w', 'i']
$ player1.add_letters('n', 'd', 'x', 'f')
$ player1.letters
=> ['w', 'a', 'i', 'n', 'd', 'x', 'f']
{% endirb %}

### Checking Words

Check whether, based on the letters in their hand, a player can play a supplied word:

{% irb %}
$ player1.letters
=> ['f', 'l', 'i', 'e', 'x', 'j']
$ player1.can_play?("file")
=> true
$ player1.can_play?("fly")
=> false
$ player1.can_play?("fill")
=> false
{% endirb %}

### Playing Words

Given some letters, play words.

{% irb %}
$ player1.letters
=> ['u', 'h', 'g', 'j', 'i', 'x']
$ player1.plays("hi")
=> 5
$ player1.letters
=> ['u', 'g', 'j', 'x']
$ player1.plays("jug")
=> 11
$ player1.letters
=> ['x']
$ player1.plays('axe')
=> RuntimeError: Frank cannot play 'axe', has letters ['x']
$ player1.letters
=> ['x']
{% endirb %}

### Keeping Score

Add functionality to the `Player` objects so an aggregate score can be tracked and compared:

{% irb %}
$ player1.score
=> 0
$ player1.letters
=> ['e', 'i', 'h', 'n', 'w', 'o']
$ player1.plays("win")
=> 6
$ player1.score
=> 6
$ player1.plays("hoe")
=> 6
$ player1.score
=> 12
$ player1.plays("burrito")
=> RuntimeError: Frank cannot play 'burrito', has letters []
$ player1.score
=> 12
{% endirb %}

### Who is winning?

{% irb %}
$ player1.letters
=> ['a', 'k', 'p', 'i', 'u', 'q', 'y']
$ player2.letters
=> ['r', 'b', 'c', 'a', 'a', 'o', 't']
$ player1.plays("quip")
=> 15
$ player2.plays("taco")
=> 6
$ player1.plays("yak")
=> 10
$ player2.plays("bar")
=> 5
$ player1.leading?(player2)
=> true
$ player2.leading?(player1)
=> false
{% endirb %}

## Cheat Mode

Coming up with the words is too hard. Let's figure out how to cheat at Scrabble.

### Basic Word Search

On the mac there is a ginormous word list in `/usr/share/dict/words`. It has over 235,000 words in it. A similar list has been [generously open-sourced by Atebits](https://github.com/atebits/Words/blob/master/Words/en.txt).

Implement an API like this:

{% irb %}
$ player1.letters
=> ['c', 'a', 't']
$ player.possible_words
=> ["act", "at", "cat", "ta"]
{% endirb %}

### Player Word Search

Find the possible words for a given player's letters:

{% irb %}
$ player1.letters = ['a', 'p', 'p', 'l', 'e', 's', 't']
=> ['a', 'p', 'p', 'l', 'e', 's', 't']
$ player1.possible_words.count
=> 200
{% endirb %}

### Best Player Words

Find the top X words for a player:

{% irb %}
$ player1.letters = ['a', 'p', 'p', 'l', 'e', 's', 't']
=> ['a', 'p', 'p', 'l', 'e', 's', 't']
$ player1.top_words(3)
 => ["applets", "lappets", "stapple"]
{% endirb %}

## Back to Scoring

### Letter Multipliers

Develop support for letter multipliers by position following this API:

{% irb %}
$ Scrabble.score("hello")
=> 8
$ Scrabble.score("hello", [nil, :double, :single, nil, :triple])
=> 11
{% endirb %}

Where the second, optional parameter is an array of markers for each letter position.

* `nil` or `:single` mean a 1x score for that letter
* `:double` means a 2x score for that letter
* `:triple` means a 3x score for that letter
* Raises an `ArgumentError` if any other marker is passed in

### Word Multipliers

Develop support for word multipliers in addition to letter multipliers following this API:

{% irb %}
$ Scrabble.score("hello")
=> 8
$ Scrabble.score("hello", [nil, :double, :single, nil, :triple], :single)
=> 11
$ Scrabble.score("hello", [nil, :double, :single, nil, :triple], :double)
=> 22
$ Scrabble.score("hello", [], :double)
=> 16
{% endirb %}

### Bonus Score Bug

There's a bug with our word picking. Words that use all seven letters get a bonus of 50 points on top of the normal word score.

For example, if we ask for the highest score from the list `['tangent', 'exert']` we should get back `'tangent'` because of the 50 point bonus. But our current implementation returns `'exert'`. Can you...

* A) build a test that demonstrates the bug
* B) fix it

## Evaluation

Subjective evaluation will be made on your work/process according to the following criteria:

### 1. Ruby Syntax & API

* 4: Developer is able to write Ruby structures with a minimum of API reference, debugging, or support
* 3: Developer is able to write Ruby structures, but needs some support with method names/concepts or debugging syntax
* 2: Developer is generally able to write Ruby, but spends significant time debugging syntax or looking up elementary methods/concepts
* 1: Developer struggles with basic Ruby syntax
* 0: Developer is ineffective at writing any Ruby of substance

### 2. Ruby Style

* 4: Developer writes code that is exceptionally clear and well-factored
* 3: Developer solves problems with a balance between conciseness and clarity and often extracts logical components
* 2: Developer writes effective code, but does not breakout logical components
* 1: Developer writes code with unnecessary variables, operations, or steps which do not increase clarity
* 0: Developer writes code that is difficult to understand

### 3. Algorithmic Thinking

* 4: Developer independently breaks complex processes into logical sequences of small steps and validates progress along the way
* 3: Developer independently breaks down complex processes into an algorithm, but tries to validate the entire functionality at once
* 2: Developer can implement an algorithm once given an outline
* 1: Developer needs significant help designing and implementing an algorithm
* 0: Developer is unable to design an algorithm

### 4. Testing

* 4: Developer excels at taking small steps and using the tests for *both* design and verification
* 3: Developer writes tests that are effective validation of functionality, but don't drive the design
* 2: Developer uses tests to guide development, but implements more functionality than the tests cover
* 1: Developer is able to write tests, but they're written after or in the middle of implementation
* 0: Developer does not use tests to guide development

### 5. Workflow

* 4: Developer is a master of their tools, effeciently moving between phases of development with almost no mouse usage
* 3: Developer demonstrates comfort with their tools and makes significant use of keyboard shortcuts
* 2: Developer smoothly moves between tools, but is dependent on mouse-driven interaction
* 1: Developer gets work done, but wastes significant time or screen real estate
* 0: Developer struggles to effectively use the Terminal, the file system, or their editor without direct support

### 6. Collaboration

* 4: Developer *actively seeks* collaboration both before implementing, while in motion, and when stuck
* 3: Developer lays out their thinking *before* attacking a problem and integrates feedback through the process
* 2: Developer asks detailed questions when progress slows or stops
* 1: Developer is able to integrate unsolicited feedback but does not really collaborate
* 0: Developer needs more than two reminders to "think out loud" or struggles to articulate their process

