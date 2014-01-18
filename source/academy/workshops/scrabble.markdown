---
layout: page
title: Scrabble
---

## Expectations

* Work on the exercise defined below for 30 minutes with your facilitator
* The facilitator may change the spec or ask additional questions to assess your understandings/skills
* As you work, you may:
  * Ask questions of your facilitator
  * Reference external public resources (ie: Google, Ruby API, etc)
  * Use the tooling most comfortable to you (Editor/IDE, testing framework, support tools like Guard, etc)
* As you work, you should not:
  * Copy code snippets other than those present in this description
  * Seek live support from individuals other than your facilitator
* After you complete the exercise, please exercise discretion with your classmates to allow them an authentic evaluation experience

## Getting Started

Because of the compressed timeline, we've created a starter repo with some of the grunt work taken care of. Begin by:

* forking the starter repo on GitHub: https://github.com/gSchool/scrabble
* cloning your fork to your local machine
* run `bundle` to install dependencies

You will also need to have the `gSchool` repository as a remote:

```plain
git remote add upstream git@github.com:gSchool/scrabble.git
git fetch upstream
git reset --hard upstream/master
git push origin master
```

Create a branch to write the scrabble code from the most recent master:

```plain
git checkout -b assessment-1
```

## Fundamental Exercises

Let's use test-driven development to build pieces of a Scrabble-like game.

### Word Scoring

Create functionality to score words based on the following letter values:

```plain
Letter                           Value
A, E, I, O, U, L, N, R, S, T       1
D, G                               2
B, C, M, P                         3
F, H, V, W, Y                      4
K                                  5
J, X                               8
Q, Z                               10
```

Or, represented by a Ruby hash:

```ruby
{
  "A"=>1, "B"=>3, "C"=>3, "D"=>2,
  "E"=>1, "F"=>4, "G"=>2, "H"=>4,
  "I"=>1, "J"=>8, "K"=>5, "L"=>1,
  "M"=>3, "N"=>1, "O"=>1, "P"=>3,
  "Q"=>10, "R"=>1, "S"=>1, "T"=>1,
  "U"=>1, "V"=>4, "W"=>4, "X"=>8,
  "Y"=>4, "Z"=>10
}
```

Create your solution:

* using Test-Driven Development with MiniTest or RSpec
* insensitive to case
* such that an empty word or `nil` scores `0`
* using this interaction model:

{% irb %}
> Scrabble.score("hello")
=> 8
> Scrabble.score("")
=> 0
> Scrabble.score(nil)
=> 0
{% endirb %}

### Highest Score

Implement a `highest_score_from` method that works like the examples below.

{% irb %}
> Scrabble.highest_score_from(['home', 'word', 'hello', 'sound'])
=> "home"
{% endirb %}

Note that it's better to use fewer tiles, so if the top score is tied between multiple words, pick the one with the fewest letters:

{% irb %}
> Scrabble.highest_score_from(['hello', 'word', 'sound'])
=> "word"
{% endirb %}

But there is a bonus for using all seven letters. If one of the highest scores uses all seven letters, pick that one:

{% irb %}
> Scrabble.highest_score_from(['home', 'word', 'silence'])
=> "silence"
{% endirb %}

But if the there are multiple words that are the same score and same length, pick the first one in supplied list:

{% irb %}
> Scrabble.highest_score_from(['hi', 'word', 'ward'])
=> "word"
{% endirb %}

## Evaluation

Subjective evaluation will be made on your work/process according to the following criteria:

#### 1. Ruby Syntax & API

* 4: Developer is able to write Ruby structures with a minimum of API reference, debugging, or support
* 3: Developer is able to write Ruby structures, but needs some support with method names/concepts or debugging syntax
* 2: Developer is generally able to write Ruby, but spends significant time debugging syntax or looking up elementary methods/concepts
* 1: Developer struggles with basic Ruby syntax
* 0: Developer is ineffective at writing any Ruby of substance

#### 2. Ruby Style

* 4: Developer writes code that is exceptionally clear and well-factored
* 3: Developer solves problems with a balance between conciseness and clarity and often extracts logical components
* 2: Developer writes effective code, but does not breakout logical components
* 1: Developer writes code with unnecessary variables, operations, or steps which do not increase clarity
* 0: Developer writes code that is difficult to understand

#### 3. Blocks & Enumerations

* 4: Developer is able to immediately select and implement the best-choice enumerator methods with blocks
* 3: Developer demonstrates skillful usage of blocks and can effectively work-through enumerable method implementation and refactoring
* 2: Developer uses some enumerator methods, but struggles to choose the right one for the job or demonstrates weak understanding of block usage
* 1: Developer uses enumerator methods, but struggles to take full advantage of the block style (ie: building unnecessary data structures, variables, etc)
* 0: Developer demonstrates a lack of understanding of enumerations or blocks

#### 4. Testing

* 4: Developer excels at taking small steps and using the tests for *both* design and verification
* 3: Developer writes tests that are effective validation of functionality, but don't drive the design
* 2: Developer uses tests to guide development, but implements more functionality than the tests cover
* 1: Developer is able to write tests, but they're written after or in the middle of implementation
* 0: Developer does not use tests to guide development

#### 5. Workflow

* 4: Developer is a master of their tools, effeciently moving between phases of development with almost no mouse usage
* 3: Developer demonstrates comfort with their tools and makes significant use of keyboard shortcuts
* 2: Developer smoothly moves between tools, but is dependent on mouse-driven interaction
* 1: Developer gets work done, but wastes significant time or screen real estate
* 0: Developer struggles to effectively use the Terminal, the file system, or their editor without direct support

#### 6. Collaboration

* 4: Developer *actively seeks* collaboration both before implementing, while in motion, and when stuck
* 3: Developer lays out their thinking *before* attacking a problem and integrates feedback through the process
* 2: Developer asks detailed questions when progress slows or stops
* 1: Developer is able to integrate unsolicited feedback but does not really collaborate
* 0: Developer needs more than two reminders to "think out loud" or struggles to articulate their process 
