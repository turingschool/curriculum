---
layout: page
title: Mastermind
---

In this project you'll use Ruby to build an implementation of the classic game Mastermind.

## Introduction

### Learning Goals

* Use TDD to drive development
* Implement a REPL interface
* Practice using Enumerable techniques
* Breaking logic into components

## Base Expectations

You are to build a playable game of Mastermind.

### Starting a Game

* The player starts the game by running `ruby mastermind.rb`
* Then they see:

{% irb %}
Welcome to MASTERMIND

Would you like to (p)lay, read the (i)nstructions, or (q)uit?
>
{% endirb %}

* If they enter `p` or `play` then they enter the *game flow* described below.
* If they enter `i` or `instructions` they should be presented with a short explanation of how
the game is played.
* If they enter `q` or `quit` then the game should exit

### Game Flow

Once the user starts a game they should see:

{% irb %}
I have generated a beginner sequence with four elements made up of: (r)ed,
(g)reen, (b)lue, and (y)ellow. Use (q)uit at any time to end the game.
What's your guess?
{% endirb %}

They can then enter a guess in the form `rrgb`

* If it's `'q'` or `'quit'` then exit the game
* If it's fewer than four letters, tell them it's too short
* If it's longer than four letters, tell them it's too long
* If they guess the secret sequence, enter the *end game* flow below
* Otherwise give them feedback on the guess like this:

{% irb %}
'RRGB' has 3 of the correct elements with 2 in the correct positions
You've taken 1 guess

{% endirb %}

Then let them guess again, repeating the game flow loop.

### End Game

When the user correctly guesses the sequence, output the following:

{% irb %}
Congratulations! You guessed the sequence 'GRRB' in 8 guesses over 4 minutes,
22 seconds.

Do you want to (p)lay again or (q)uit?
{% endirb %}

If they enter `'p'` or `'play'` then restart the game. `'q'` or `'quit'` ends
the game.

## Extensions

If you're able to finish the base expectations, add on one or more of the
following extensions:

### Difficulty Levels

When the user is getting ready to start a game, ask them what difficulty
level they'd like to play with the following adaptations:

* Beginner = 4 characters, 4 colors
* Intermediate = 6 characters, 5 colors
* Advanced = 8 characters, 6 colors

### Record Tracking & Top 10

Use a file on the file system (CSV, plain, JSON, whatever) to track completed
games. When the user wins the game, output a message like this:

{% irb %}
Congratulations! You've guessed the sequence! What's your name?

> Jeff

Jeff, you guessed the sequence 'GRRB' in 8 guesses over 4 minutes,
22 seconds. That's 1 minute, 10 seconds faster and two guesses fewer than the
average.

=== TOP 10 ===
1. Jeff solved 'GRRB' in 8 guesses over 4m22s
2. Jeff solved 'BRGG' in 11 guesses over 4m45s
3. Jorge solved 'BBBB' in 12 guesses over 4m15s
4. Jorge solved 'GGBB' in 12 guesses over 5m12s
{% endirb %}

Note that they're ranked first by guesses then by time.

### Package & Polish

Your game won't be very popular if it's hard to install and run.

#### Add a Command Line Wrapper

Create an executable script that allows the user to just run `mastermind`
from their terminal without directly executing Ruby.

#### Build a Gem

Wrap your code into a Ruby gem and publish it on Rubygems.org with a name like
`mastermind-jcasimir` based on your GitHub user name.

### Other Ideas

* Visual Interface - add colors and ASCII graphics to make a more compelling
visual experience
* Two-Player Mode - Add a game mode where players alternate guesses and whoever
gets the sequence right first wins. Consider having their guesses hidden.

## Evaluation Rubric

* Use TDD to drive development
* Implement a REPL interface
* Practice using Enumerable techniques
* Breaking logic into components

The project will be assessed with the following rubric:

### 1. Fundamental Ruby & Collections

* 4: Application consistently makes use of the best-choice Enumerable methods and strong Ruby style
* 3: Application demonstrates comfortable use of Enumerable and strong Ruby style
* 2: Application demonstrates functional knowledge of Enumerable with Ruby style that needs refactoring
* 1: Application demonstrates deficiencies with Enumerable and poor Ruby style

### 2. Test-Driven Development

* 4: Application is broken into components which are tested in both isolation and integration
* 3: Application is broken into components but does not balance isolation and integration tests
* 2: Application makes some use of tests, but the coverage is insufficient
* 1: Application does not demonstrate strong use of TDD

### 3. REPL Interface

* 4: Application's REPL goes above and beyond expectations to improve the gameplay
* 3: Application's REPL is clear and pleasant to use
* 2: Application's REPL has some inconsistencies / rough edges
* 1: Application's REPL has enough problems as to make play difficult

### 4. Breaking Logic into Components

* 4: Application is expertly divided into logical components such that individual pieces could be reused or replaced without difficulty
* 3: Application effectively breaks logical components apart with clear intent and usage
* 2: Application shows some effort to break logic into components, but the divisions are inconsistent or unclear
* 1: Application logic shows poor decomposition with too much logic mashed together
