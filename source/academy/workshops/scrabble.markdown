---
layout: page
title: Scrabble
---

## Expectations

* Work on the exercise defined below for 40 minutes with your facilitator
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

* forking the starter repo on Github: https://github.com/gSchool/scrabble
* cloning your fork to your local machine
* run `bundle` to install dependencies

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
{"A"=>1, "B"=>3, "C"=>3, "D"=>2, "E"=>1, "F"=>4, "G"=>2, "H"=>4, "I"=>1, "J"=>8, 
 "K"=>5, "L"=>1, "M"=>3, "N"=>1, "O"=>1, "P"=>3, "Q"=>10, "R"=>1, "S"=>1, "T"=>1, 
 "U"=>1, "V"=>4, "W"=>4, "X"=>8, "Y"=>4, "Z"=>10}
```

Create your solution:

* using Test-Driven Development with MiniTest or RSpec
* insensitive to case
* such that an empty word or `nil` scores `0`
* using this API:

{% irb %}
> Scrabble.score("hello")
=> 8
> Scrabble.score("")
=> 0
> Scrabble.score(nil)
=> 0
{% endirb %}

### Highest Score

Implement a `highest_score_from` method that works like the examples below. Don't think too hard about the fact that you couldn't have all these letters in your hand at the same time :)

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

### Simple Players

Build `Player` objects to allow the following interactions:

{% irb %}
> player1 = Player.new("Frank")
=> #<Player:0x007fa4a7a05cf0> 
> player2 = Player.new("Katrina")
=> #<Player:0x007fa4a7a144f8>
> player1.name
=> "Frank"
{% endirb %}

### Keeping Score

Add functionality to the `Player` objects so score can be tracked and compared:

{% irb %}
> player1.plays("hello")
=> 8
> player2.plays("word")
=> 8
> player1.plays("home")
=> 9
> player2.plays("sound")
=> 6
> player1.score
=> 17
> player2.score
=> 14
> player1.leading?(player2)
=> true
{% endirb %}

### Tracking Letters

Players should now be able to keep track of their letters:

{% irb %}
> player1.letters = ['a']
=> ['a']
> player1.add_letter('w')
=> ['a', 'w']
> player1.add_letters(['i', 'n', 'd'])
=> ['w', 'a', 'i', 'n', 'd']
> player1.plays("win")
=> 6
> player1.letters
=> ['a', 'd']
{% endirb %}

### Checking Words

{% irb %}
> player1.letters
=> ['w', 'a', 'n', 'd', 'x', 'e', 'j']
> player1.can_play?("wand")
=> true
> player1.can_play?("wind")
=> false
> player1.plays('wind')
=> RuntimeError: Frank cannot play 'wind', has letters ['w', 'a', 'n', 'd', 'x', 'e', 'j']
{% endirb %}

### Letter Multipliers

Develop support for letter multipliers by position following this API:

{% irb %}
> Scrabble.score("hello")
=> 8
> Scrabble.score("hello", [nil, :double, :single, nil, :triple])
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
> Scrabble.score("hello")
=> 8
> Scrabble.score("hello", [nil, :double, :single, nil, :triple], :single)
=> 11
> Scrabble.score("hello", [nil, :double, :single, nil, :triple], :double)
=> 22
> Scrabble.score("hello", [], :double)
=> 16
{% endirb %}

#### Optional Challenge

Allow flexible parameters such that the letter multiplier array can be omitted entirely, but the word multiplier still takes effect:

{% irb %}
> Scrabble.score("hello", :double)
=> 16
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

* 4: Developer is able to craft Ruby objects and methods that follow the principles of DRY, Single Responsibility Principle, short methods, and short lines
* 3: Developer generally writes clean Ruby with some breakdowns in DRY, SRP, method length, or line length
* 2: Developer needs support to craft methods following SRP or DRY
* 1: Developer writes Ruby without regard to DRY, SRP, or other Ruby conventions
* 0: Developer is ineffective and using Ruby style

#### 3. Blocks & Enumerations

* 4: Developer is able to wield appropriate Ruby enumerator methods and blocks to process collections of data
* 3: Developer uses enumerator methods, but struggles to choose the right one for the job
* 2: Developer uses enumerator methods, but struggles to take full advantage of the block style (ie: building unnecessary data structures, variables, etc)
* 1: Developer demonstrates a lack of understanding of enumerations or blocks
* 0: Developer cannot process collections of data

#### 4. Testing

* 4: Developer effectively applies the ideas of TDD to structure development
* 3: Developer is able to write tests effectively, but they're sometimes written after or in the middle of implementation
* 2: Developer writes tests that are ineffective or do not adequately exercise the functionality
* 1: Developer struggles to write tests to exercise their implementation without significant support
* 0: Developer is unable to write tests

#### 5. Workflow

* 4: Developer is able to effectively use Git, terminal, the file system, and their editor to get the work done
* 3: Developer is inefficient with the basics of Git, terminal, the file system, and their editor, but can get work done
* 2: Developer needs some support/prompting in basic usage of Git, Terminal, the file system, or their editor
* 1: Developer struggles to effectively use Git, Terminal, the file system, or their editor
* 0: Developer is unable to make significant progress due to difficulties with Git, Terminal, the file system, or editor

#### 6. Collaboration

* 4: Developer actively seeks and engages with collaboration both while in motion and when stuck
* 3: Developer is able to integrate feedback when stuck to get over hurdles
* 2: Developer is hesitant to collaborate or solicit feedback
* 1: Developer struggles to articulate a process or resists feedback
* 0: Developer is unable to communicate a process and collaborate
