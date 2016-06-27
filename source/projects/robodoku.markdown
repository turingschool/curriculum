---
layout: page
title: Robodoku
sidebar: true
---

# Robodoku

Some people get really into Sudoku. But solving the puzzles is just a matter
of executing an algorithm.

In this project, you'll build a program that can solve valid Sudoku puzzles.
For a puzzle to be valid it must have only one single solution.
No valid puzzle ever _requires_ "guessing" (although guessing may be a
useful technique while working toward a solution).

## Sudoku Rules / Terminology

We'll use the traditional board layout/style. A puzzle is made up of:

* a *spot* holds a single number 1-9
* a *board* is a 9x9 grid of spots. Boards are then subdivided into
  smaller units.
* a *square* is a 3x3 group of spots
* a *row* spans nine squares in a straight line left-to-right across the board
* a *column* spans nine squares in a straight line top-to-bottom across the board
* a *unit* is any collection of 9 squares grouped as either a *square*,
  *column*, or *row*.
* the *peers* of a *spot* are all the other spots with which it shares a
  *unit* (square, row, or column). Thus each spot has 20 peers.
* at puzzle-start, one or more spots are blank

For the puzzle to be solved, each *unit* (square, row, or column) must
contain exactly all the digits 1–9.

## Algorithmic Approach

Coming up with a sophisticated solution which solves all possible
puzzles out of the gate is quite hard. But the problem lends itself well
to deconstruction, and we'll see that we can come up with solutions to
solve _some_ puzzles without much difficulty. From there we can
gradually build up the algorithm to solve harder examples.

### Initial Technique -- Filling in Single-Possibility Cells

When the puzzle is solved, each spot must have a number. Here's an
outline for a relatively simplistic algorithm which should be able to
solve some puzzles:

* To start, each empty spot can conceivably be filled with any value
  1–9.
* However we know that possible values of a spot are constrained by what
  values are already filled by its peers. So we can eliminate all peer
  values from the possibilities for each spot.
* If a spot now has only one possibility left, then it must be the
  correct value for that spot.
* If there's more than one possibility left, we can move on, looking for other
  "solveable" spots whose values we can fill in.
* Once we've looked at each spot, make another pass, this time factoring
  in new information for any spots that were solved on the previous
  pass. Hopefully this allows us to start to fill in more spots that we
  were unable to solve before.
* If we fill in all the spots, we're done!

There are certainly more sophisticated techniques that we could
incorporate into our algorithm, and you'll likely need to do so to solve
all the puzzles required by your final implementation. But this should
serve as a sketch to get you started.

### Second Technique -- Filling in "Only-Candidate" Cells

Let's look at one more technique that we might use to enhance our solvers.
Sometimes we'll be able to rule out all possible values but one from a cell,
leaving us with one obvious choice.

We can also infer a lot from the possibilities of a cell's peers -- specifically
if we determine that a cell is the _only_ cell among its peers that could take on
a given number, then we can assume that must be the value for that cell and fill it in.

A rough algorithm for doing this might look like:

1. For a given cell, look at each of its peers
2. For each peer, grab its current possibilities
3. Then combine all of these peer possibilities into one list
4. Look at the combined peer possibilities, and see if there are any numbers _missing_
5. If we come up with a _single missing number_, then our current cell must be the
only cell among all of its peers that can take on that possibility. Thus we can assume
it must be the value of the cell.

## Program Interface

Your program will be expected to:

1. Be run from the command line
2. Read puzzles from the file system
3. Solve the **easy** puzzle provided with the robodoku template
4. Print the solution to the terminal

## Puzzle Format

To keep things simple, we'll just represent puzzles as text files
containing 9 lines of 9 columns each. So an example puzzle will look
like this:

```
   26 7 1
68  7  9 
19   45  
82 1   4 
  46 29
 5   3 28
  93   74
 4  5  36
7 3 18   
```

and its solution would look like:

```
435269781
682571493
197834562
826195347
374682915
951743628
519326874
248957136
763418259
```

## Template

For your project, use this [template](https://github.com/turingschool/robodoku-template)
as a starting point.

The puzzle will be provided in a file, and the filepath will be passed in as a command-line argument.

The usage (from your project's root) will look like:

```
ruby lib/sudoku.rb puzzles/easy.txt
435269781
682571493
197834562
826195347
374682915
951743628
519326874
248957136
763418259
```

Beyond that, the internals of your implementation are completely up to you.

## Evaluation Rubric

The project will be assessed with the following rubric:

### 1. Functional Expectations

* 4: Application can solve additional medium or hard puzzles.
* 3: Application can solve the easy puzzle provided with the project template
* 2: Application runs but fails to solve the easy puzzle
* 1: Application errors or fails to run

### 2. Encapsulation / Breaking Logic into Components

* 4: Application is expertly divided into logical components each with a clear, single responsibility
* 3: Application effectively breaks logical components apart but breaks the principle of SRP
* 2: Application shows some effort to break logic into components, but the divisions are inconsistent or unclear
* 1: Application logic shows poor decomposition with too much logic mashed together

### 3. Fundamental Ruby & Style

* 4:  Application demonstrates excellent knowledge of Ruby syntax, style, and refactoring
* 3:  Application shows strong effort towards organization, content, and refactoring
* 2:  Application runs but the code has long methods, unnecessary or poorly named variables, and needs significant refactoring
* 1:  Application generates syntax error or crashes during execution

### 4. Enumerable & Collections

* 4: Application consistently makes use of the best-choice Enumerable methods
* 3: Application demonstrates comfortable use of appropriate Enumerable methods
* 2: Application demonstrates functional knowledge of Enumerable but only uses the most basic techniques
* 1: Application demonstrates deficiencies with Enumerable and struggles with collections

