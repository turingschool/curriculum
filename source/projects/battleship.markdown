---
layout: page
title: Battleship
---

In this project you'll use Ruby to build an implementation of the classic game Battleship.

## Introduction

### Learning Goals / Areas of Focus

* Proficiently use TDD to drive development
* Practice breaking a program into logical components
* Learn to implement a REPL interface
* Apply previously learned Enumerable techniques in a real context

## Base Expectations

You are to build a playable game of Battleship that runs in a REPL interface.

### Starting a Game

* The player starts the game by running `ruby battleship.rb`
* Then they see:

{% irb %}
Welcome to BATTLESHIP

Would you like to (p)lay, read the (i)nstructions, or (q)uit?
>
{% endirb %}

* If they enter `p` or `play` then they enter the *ship layout* described below.
* If they enter `i` or `instructions` they should be presented with a short explanation of how
the game is played.
* If they enter `q` or `quit` then the game should exit

### Ship Layout

Once the user starts a game they should see:

{% irb %}
I have laid out my ships on the grid.
You now need to layout your two ships, one that is two units long and the
second which is three units long, on a grid with A1 at the top left and D4 at the
bottom right.
Enter the squares for the two-unit ship:
{% endirb %}

Then they enter coordinates like this:

```text
A1 A2
```

Which places the two element ship on squares A1 and A2. Then it asks for the
coordinates for the three-unit ship. Note that:

* Ships cannot wrap around the board
* Ships cannot overlap
* Ships can be laid horizontally or vertically

Then they enter the *game flow* sequence.

### Game Flow

Once the ships are laid out the game starts with the Player Shoots Sequence.

#### Player Shoots Sequences

{% irb %}
Your turn! Here's what you know:

===========
  1 2 3 4
A

B

C

D
===========

Enter a coordinate to shoot at:
{% endirb %}

Then they enter a coordinate:

* If the coordinate has already been shot at, reject the guess and ask them to
shoot again
* If the coordinate misses the opponent ships, mark it with a `M` on the map.
* If the coordinate "hits" an opponent ship, mark it with an `H` on the map and
enter the Hit Ship sequence below

Then move to the Enemy Shot sequence.

#### Hit Ship Sequence

* If the hit did not sink the ship, just tell them that they hit an enemy ship
* If the hit sunk the ship, tell them they sunk it and the size of the ship.
* If the hit sunk the ship and it was the last enemy ship, they've won the game
and it should exit the program.

#### Enemy Shot Sequence

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

Use a file on the file system (like CSV, JSON, etc) to track completed
games across runs of the program. When the user wins the game, output a message like this:

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

Note that they're ranked first by number of guesses then by time.

### Package & Polish

Your game won't be very popular if it's hard to install and run.

#### Add a Command Line Wrapper

Create an executable script that allows the user to just run `mastermind`
from their terminal without directly executing Ruby.

#### Build a Gem

Wrap your code into a Ruby gem and publish it on Rubygems.org with a name like
`mastermind-jcasimir` based on your GitHub user name.

### Other Ideas
* Add a `history` instruction to the gameplay which can be called before entering a guess and it'll display
all previous guesses and results in a compact form
* Visual Interface - add colors and ASCII graphics to make a more compelling
visual experience
* Two-Player Mode - Add a game mode where players alternate guesses and whoever
gets the sequence right first wins. Consider having their guesses hidden.

## Evaluation Rubric

The project will be assessed with the following rubric:

### 1. Fundamental Ruby & Style

* 4:  Application demonstrates excellent knowledge of Ruby syntax, style, and refactoring
* 3:  Application shows strong effort towards organization, content, and refactoring
* 2:  Application runs but the code has many long methods (>8 lines) and needs significant refactoring
* 1:  Application generates syntax error or crashes during execution

### 2. Enumerable & Collections

* 4: Application consistently makes use of the best-choice Enumerable methods
* 3: Application demonstrates comfortable use of several Enumerable techniques
* 2: Application demonstrates functional knowledge of Enumerable but only uses the most basic techniques
* 1: Application demonstrates deficiencies with Enumerable and struggles with collections

### 3. Test-Driven Development

* 4: Application is broken into components which are well tested in both isolation and integration
* 3: Application is well tested but does not balance isolation and integration tests
* 2: Application makes some use of tests, but the coverage is insufficient
* 1: Application does not demonstrate strong use of TDD

### 4. REPL Interface

* 4: Application's REPL goes above and beyond expectations to improve the gameplay
* 3: Application's REPL is clear and pleasant to use
* 2: Application's REPL has some inconsistencies or rough edges
* 1: Application's REPL has enough problems as to make play difficult

### 5. Breaking Logic into Components

* 4: Application is expertly divided into logical components such that individual pieces could be reused or replaced without difficulty
* 3: Application effectively breaks logical components apart with clear intent and usage
* 2: Application shows some effort to break logic into components, but the divisions are inconsistent or unclear
* 1: Application logic shows poor decomposition with too much logic mashed together
