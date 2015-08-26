---
layout: page
title: Mastermind
---

In this project you'll use Ruby to build an implementation of the classic game Mastermind.

## Introduction

### Learning Goals / Areas of Focus

* Apply principles of flow control across multiple methods
* Practice breaking a program into logical components
* Learn to implement a REPL interface
* Apply Enumerable techniques in a real context

*NOTE* that you are not expected to write automated software tests for this project.

## Base Expectations

You are to build a playable game of Mastermind that runs in a REPL interface.

### Starting a Game

* The player starts the game by running `ruby mastermind.rb`
* Then they see:

```
Welcome to MASTERMIND

Would you like to (p)lay, read the (i)nstructions, or (q)uit?
>
```

* If they enter `p` or `play` then they enter the *game flow* described below.
* If they enter `i` or `instructions` they should be presented with a short explanation of how
the game is played.
* If they enter `q` or `quit` then the game should exit

### Game Flow

Once the user starts a game they should see:

```
I have generated a beginner sequence with four elements made up of: (r)ed,
(g)reen, (b)lue, and (y)ellow. Use (q)uit at any time to end the game.
What's your guess?
```

They can then enter a guess in the form `rrgb`

* Guesses are case insensitive
* If it's `'q'` or `'quit'` then exit the game
* If it's `'c'` or `'cheat'` then print out the current secret code
* If it's fewer than four letters, tell them it's too short
* If it's longer than four letters, tell them it's too long
* If they guess the secret sequence, enter the *end game* flow below
* Otherwise give them feedback on the guess like this:

```
'RRGB' has 3 of the correct elements with 2 in the correct positions
You've taken 1 guess
```

Then let them guess again, repeating the game flow loop.

### End Game

When the user correctly guesses the sequence, output the following:

```
Congratulations! You guessed the sequence 'GRRB' in 8 guesses over 4 minutes,
22 seconds.

Do you want to (p)lay again or (q)uit?
```

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

```
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
```

Note that they're ranked first by number of guesses then by time.

### Package & Polish

Your game won't be very popular if it's hard to install and run.

#### Add a Command Line Wrapper

Create an executable script that allows the user to just run `mastermind`
from their terminal without directly executing Ruby.

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
* 3:  Application shows some effort toward organization but still has 6 or fewer long methods (> 8 lines) and needs some refactoring.
* 2:  Application runs but the code has many long methods (>8 lines) and needs significant refactoring
* 1:  Application generates syntax error or crashes during execution

### 2. Enumerable & Collections

* 4: Application consistently makes use of the best-choice Enumerable methods and collections
* 3: Application demonstrates comfortable use of several Enumerable techniques and collections
* 2: Application demonstrates functional knowledge of Enumerable but only uses the most basic techniques
* 1: Application demonstrates deficiencies with Enumerable and struggles with collections

### 3. REPL Interface and Game Functionality

* 4: Application's REPL goes above and beyond expectations and application includes one or more extensions
* 3: Application's REPL is clear and pleasant to use and application fulfills base expectations from the project spec
* 2: Application's REPL has inconsistencies and/or there are errors in base gameplay
* 1: Application's REPL has several issues or application fails to run

### 4. Breaking Logic into Components

* 4: Application consistently breaks concepts into logical classes and methods which encapsulate functionality.
* 3: Application consistently breaks concepts into logical methods to encapsulate functionality.
* 2: Application makes use of some methods, but the divisions or encapsulation are unclear.
* 1: Application makes use of just a few huge methods to control the bulk of the functionality.
