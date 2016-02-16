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


```
Welcome to BATTLESHIP

Would you like to (p)lay, read the (i)nstructions, or (q)uit?
>
```

* If they enter `p` or `play` then they enter the *ship layout* described below.
* If they enter `i` or `instructions` they should be presented with a short explanation of how
the game is played.
* If they enter `q` or `quit` then the game should exit

### Ship Layout

Once the user starts a game they should see:

```
I have laid out my ships on the grid.
You now need to layout your two ships.
The first is two units long and the
second is three units long.
The grid has A1 at the top left and D4 at the bottom right.

Enter the squares for the two-unit ship:
```

Then they enter coordinates like this:

```text
A1 A2
```

Which places the two element ship on squares A1 and A2. Then it asks for the
coordinates for the three-unit ship. Note that:

* Ships cannot wrap around the board
* Ships cannot overlap
* Ships can be laid horizontally or vertically
* Coordinates must correspond to the first and last units of the ship.
(IE: You can't place a two unit ship at "A1 A3")

Then they enter the *game flow* sequence.

### Game Flow

Once the ships are laid out the game starts with the Player Shoots Sequence.

#### Player Shoots Sequences

The game first outputs a map:

```
Your turn! Here's what you know:

===========
. 1 2 3 4
A
B
C
D
===========

Enter a coordinate to shoot at:
```

Then they enter a coordinate:

* If the coordinate has already been shot at, reject the guess and ask them to
shoot again
* If the coordinate misses the opponent ships, output 'Shot Missed'. The next time you show the map, mark that location with an `O`.
* If the coordinate "hits" an opponent ship, enter the Hit Ship sequence below. The next time you show the map, mark that location with an `H`.

Then move to the Enemy Shoots sequence.

#### Enemy Shoots Sequence

```
My turn! Here's your map:

===========
. 1 2 3 4
A X X
B     Y
C     Y
D     Y
===========

```

Where `XX` and `YYY` represent the player's ships.

* The computer player randomly selects a location which has not been shot at, and
shoots at it.
* If the shot misses the player ships, output "Shot missed". Mark it with a `M` on the map.
* If the shot "hits" a player ship, enter the Hit Ship sequence. Mark it with an `H` on the map

Then move to the Player Shoots sequence.

#### Hit Ship Sequence

* If the hit did not sink the ship, tell them that they hit an enemy ship
* If the hit sunk the ship, tell them they sunk it and the size of the ship.
* If the hit sunk the ship and it was the last enemy ship, then enter the

#### End Game Sequence

When either the player or computer wins the game...

* Output a sorry or congratulations message
* Output how many shots it took the winner to sink the opponent's ships
* Output the total time that the game took to play

## Extensions

If you're able to finish the base expectations, add on one or more of the
following extensions:

### Difficulty Levels

When the user is getting ready to start a game, ask them what difficulty
level they'd like to play with the following adaptations:

* Beginner = 4x4 grid, 2-unit boat, 3-unit boat
* Intermediate = 8x8 grid, 2-unit boat, 3-unit boat, 4-unit boat
* Advanced = 12x12 grid, 2-unit boat, 3-unit boat, 4-unit boat, 5-unit boat

### Remote Play

Allow two players to play against each other across the network.

### Graphical Interface

Use Ruby-Processing to generate a graphical user interface that allows the
players to see the game and click the grid to shoot.

### Package & Polish

Your game won't be very popular if it's hard to install and run.

#### Add a Command Line Wrapper

Create an executable script that allows the user to just run `battleship`
from their terminal without directly executing Ruby.

#### Build a Gem

Wrap your code into a Ruby gem and publish it on Rubygems.org with a name like
`battleship-jcasimir` based on your GitHub user name.

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
