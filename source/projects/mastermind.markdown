---
layout: page
title: Mastermind
---

In this project you'll use Ruby to build an implementation of the classic game Mastermind.

## Introduction

### Learning Goals

* Use TDD to drive development
* Implementing a REPL interface
* Breaking logic into components

### Restrictions

None: you may use any libraries or tools.

### Getting Started

1. One team member creates a repository named "mastermind"
2. Add the other team members as collaborators
3. Clone the repo to your local machines

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
(g)reen, (b)lue, and (y)ellow.
What's your guess?
{% endirb %}

They can then enter a guess in the form `rrgb`

* If it's fewer than four letters, tell them it's too short
* If it's longer than four letters, tell them it's too long
* If they guess the secret sequence, enter the *end game* flow below
* Otherwise give them feedback on the guess like this:

{% irb %}
'RRGB' has 3 of the correct elements with 2 the correct positions
You've taken 1 guess

{% endirb %}

Then let them guess again, repeating the game flow loop.

### End Game

When the user correctly guesses the sequence, output the following:



## Extensions

### Multiple Difficulty Levels

* Beginner = 4 characters, 4 colors
* Intermediate = 6 characters, 5 colors
* Advanced = 8 characters, 6 colors

### Record Tracking

### Visual Interface

### Two-Player Mode

### Package & Polish

* Bundle it into an installable gem
* Add a command-line `mastermind` runner

## Evaluation Rubric
