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

## Program Interface

Your program will be expected to:

1. Be run from the command line
2. Read puzzles from the file system
3. Solve puzzles
4. Output the solution to the terminal

## Puzzle Format

To keep things simple, we'll just represent puzzles as text files
containing 9 lines of 9 columns each. So an example puzzle will look
like this:

```
8  5 4  7
  5 3 9  
 9 7 1 6
1 3   2 8
 4     5
2 78136 4
 3 9 2 8
  2 7 5  
6  3 5  1
```

and its solution would look like:

```
826594317
715638942
394721865
163459278
948267153
257813694
531942786
482176539
679385421
```

## Template

For your project, use this [template](https://github.com/turingschool/robodoku-template)
as a starting point.

We'll eventually run a spec harness against your completed code, so it's important that you
follow the template's patterns for input/output.

The usage (from your project's root) will look like:

```
ruby lib/sudoku.rb puzzles/easy.txt
=> 826594317
715638942
394721865
163459278
948267153
257813694
531942786
482176539
679385421
```

Beyond that, the internals of your implementation are completely up to you.

## Evaluation Rubric

The project will be assessed with the following rubric:

### 1. Functional Expectations

* 4: Application can solve all puzzles from the spec harness as well as additional "hard" puzzles
* 3: Application can solve the "easy" and "medium" Sudoku puzzles provided by the spec harness
* 2: Application can solve trivial "easy" Sudoku puzzles
* 1: Application can't solve any puzzles

### 2. Test-Driven Development

* 4: Application is broken into components which are well tested in both isolation and integration using appropriate data
* 3: Application is well tested but does not balance isolation and integration tests, using only the data necessary to test the functionality
* 2: Application makes some use of tests, but the coverage is insufficient
* 1: Application does not demonstrate strong use of TDD

### 3. Encapsulation / Breaking Logic into Components

* 4: Application is expertly divided into logical components each with a clear, single responsibility
* 3: Application effectively breaks logical components apart but breaks the principle of SRP
* 2: Application shows some effort to break logic into components, but the divisions are inconsistent or unclear
* 1: Application logic shows poor decomposition with too much logic mashed together

### 4. Fundamental Ruby & Style

* 4:  Application demonstrates excellent knowledge of Ruby syntax, style, and refactoring
* 3:  Application shows strong effort towards organization, content, and refactoring
* 2:  Application runs but the code has long methods, unnecessary or poorly named variables, and needs significant refactoring
* 1:  Application generates syntax error or crashes during execution

### 5. Enumerable & Collections

* 4: Application consistently makes use of the best-choice Enumerable methods
* 3: Application demonstrates comfortable use of appropriate Enumerable methods
* 2: Application demonstrates functional knowledge of Enumerable but only uses the most basic techniques
* 1: Application demonstrates deficiencies with Enumerable and struggles with collections

