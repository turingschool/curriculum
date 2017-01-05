# Flashcards

In this project, you'll write a flashcard program that is used through the command line. A user will be able to see the questions, take guesses, and see a final score at the end of the round.

In order to build good habits, we've broken the project up into small classes to demonstrate objects that have a single responsibility. As you work through each iteration, use TDD to drive out the desired behavior.

The rubric for this project is included at the bottom of this file.

# Iteration 1: Card Basics

First, we'll need a card object. Use TDD to drive the creation of an object that has this interaction pattern:

```ruby
card = Card.new("What is the capital of Alaska?", "Juneau")
card.question
=> "What is the capital of Alaska?"
card.answer
=> "Juneau"
```

# Iteration 2: Checking Guesses

Users will enter an guess, and we need to know if the guess is correct. Let's use TDD to create this interaction pattern:

```ruby
card = Card.new("What is the capital of Alaska?", "Juneau")
guess = Guess.new("Juneau", card)
guess.card
=> #<Card:0x007ffdf1820a90 @answer="Juneau", @question="What is the capital of Alaska?">
guess.response
=> "Juneau"
guess.correct?
=> true
guess.feedback
=> "Correct!"
```

```ruby
card = Card.new("Which planet is closest to the sun?", "Mercury")
guess = Guess.new("Saturn", card)
guess.card
=> #<Card:0x007ffdf1820a90 @answer="Mercury", @question="Which planet is closest to the sun?">
guess.response
=> "Saturn"
guess.correct?
=> false
guess.feedback
=> "Incorrect."
```

# Iteration 3: Storing Cards in a Deck

Let's store the cards in a deck. Use TDD to drive the creation of an object that has this interaction pattern:

```ruby
card_1 = Card.new("What is the capital of Alaska?", "Juneau")
card_2 = Card.new("The Viking spacecraft sent back to Earth photographs and reports about the surface of which planet?", "Mars")
card_3 = Card.new("Describe in words the exact direction that is 697.5° clockwise from due north?", "North north west")
deck = Deck.new([card_1, card_2, card_3])
deck.cards
=> [card_1, card_2, card_3]
deck.count
=> 3
```

# Iteration 4: The Round

A round will be the object that processes responses and records guesses. Use TDD to drive out this behavior:

```ruby
card_1 = Card.new("What is the capital of Alaska?", "Juneau")
card_2 = Card.new("Approximately how many miles are in one astronomical unit?", "93,000,000")
deck = Deck.new([card_1, card_2])
round = Round.new(deck)
round.deck
=> #<Deck:0x007ffdf181b9c8 @cards=[...]>
round.guesses
=> []
round.current_card
=> #<Card:0x007ffdf1820a90 @answer="Juneau", @question="What is the capital of Alaska?">
round.record_guess("Juneau")
=> #<Guess:0x007ffdf19c8a00 @card=#<Card:0x007ffdf1820a90 @answer="Juneau", @question="What is the capital of Alaska?">, @response="Juneau">
round.guesses.count
=> 1
round.guesses.first.feedback
=> "Correct!"
round.number_correct
=> 1
round.current_card
=> #<Card:0x007ffdf1820a90 @answer="93,000,000", @question="Approximately how many miles are in one astronomical unit?">
round.record_guess("2")
=> #<Guess:0x007ffdf19c8a00 @card=#<Card:0x007ffdf1820a90 @answer="93,000,000", @question="Approximately how many miles are in one astronomical unit?">, @response="2">
round.guesses.count
=> 2
round.guesses.last.feedback
=> "Incorrect."
round.number_correct
=> 1
round.percent_correct
=> 50
```

# Iteration 5: Building out the runner

So far we've focused on modelling the data, classes, and methods that make up our game. However we haven't done much to put any kind of useable **interface** onto the game. In this iteration, let's remedy this by adding a simple Command-Line-Interface to the game.

A few key points to keep in mind as you work on this iteration:

* We'll abandon TDD for this bit -- the techniques for testing this kind of input/output behavior are somewhat involved and are beyond the scope of this project
* Use `puts` to display a line of text output to the user
* Use `gets` to read a line of text input from the user (this will be important to allow users to enter guesses)
* In this iteration we'll introduce a new file called a "runner" -- its job is to serve as the main entry point to our program by starting up a new game

**First**, create your runner file:

```
touch flashcard_runner.rb
```

Inside of this file, write the code to do the following:

* Create some Cards
* Put those card into a Deck
* Create a new Round using the Deck you created
* **Start** the round using a new method called `start` (`round.start`)

When we start the round by running `ruby flashcard_runner.rb`, it should produce the following interaction from the command line:

**Keep in mind** that your existing objects should already contain, more or less, the data and methods needed to manage this process. Your challenge in this iteration is to build out the input/output messaging to support the user's card experience *using your existing pieces to store and manage all the necessary data*.

```
Welcome! You're playing with 4 cards.
-------------------------------------------------
This is card number 1 out of 4.
Question: What is 5 + 5?
10
Correct!
This is card number 2 out of 4.
Question: What is the capital of Alaska?
Anchorage
Incorrect.
This is card number 3 out of 4.
Question: What color is the ocean?
blue 
Correct!
This is card number 4 out of 4.
Question: What is street is Turing on?
Blake
Correct!
****** Game over! ******
You had 3 correct guesses out of 4 for a score of 75%.
```

# Iteration 6: Loading Text Files

Right now, we're hardcoding the flashcards into our runner. Wouldn't it be nice to have a whole text file of questions and answers to use?

Let's build an object that will read in a text file and generate cards. Go back to using TDD for this iteration.

Assuming we have a text file `cards.txt` that looks like this:

```
What is 5 + 5?,10
What is the capital of Alaska?,Juneau
What color is the ocean?,blue
What is street is Turing on?,Blake
```

Then we should be able to do this:

```ruby
filename = "cards.txt"
cards = CardGenerator.new(filename).cards
=> [#<Card:0x007f9f1413cbe8 @answer="10", @question="What is 5 + 5?">,
 #<Card:0x007f9f1413c788 @answer="Juneau", @question="What is the capital of Alaska?">,
 #<Card:0x007f9f1413c2b0 @answer="blue", @question="What color is the ocean?">,
 #<Card:0x007f9f14137da0 @answer="Blake", @question="What is street is Turing on?">]
```

Modify your program so that when you run `ruby flashcard_runner.rb`, it uses cards from `cards.txt` instead of hardcoded cards.

# Extensions

### Accepting Card Files

Prompt the user to enter a filename for the cards to use. Check whether or not the text file exists. If it does not, prompt the user to enter a new filename.

Additionally, allow the user to enter a filename as a command line argument (ie `$ ruby flashcards.rb cards.txt`). Again, if the file does not exist, return a message and prompt for a new filename.

### Saving Results

At the end of the round, save the results to another text file. The results should include the question, answer, user response, and whether or not it was correct *for each card*. Use [Date](http://ruby-doc.org/stdlib-2.3.1/libdoc/date/rdoc/Date.html) and [Date#strftime](http://ruby-doc.org/stdlib-2.3.1/libdoc/date/rdoc/Date.html#method-i-strftime) to generate a dynamic results file name. For example, when I finish the game, a file would be generated `results-2016-05-10-4:45pm.txt`.

### Extra Practice

Put incorrectly guessed cards back into the iteration to be asked again until the user guesses correctly.

### Hints

Build in hint functionality. If a user enters "hint" when it's time to guess, the game should display a hint. In order to make this functional, you'll need to modify the text file you take in to include a hint.

# Evaluation Rubric

The project will be assessed with the following guidelines:

### 1. Functional Expectations

* 4: Application fulfills all expectations of iterations 1 - 6 with no bugs, crashes, or missing functionality *as well as* two extensions.
* 3: Application fulfills expectations of iterations 1 - 6 with no bugs, crashes, or missing functionality.
* 2: Application is usable but has some missing functionality.
* 1: Application crashes during normal usage.

### 2. Test-Driven Development

* 4: Application is broken into components which are well tested in both isolation and integration using appropriate data.
* 3: Application is well tested but does not balance isolation and integration tests, using only the data necessary to test the functionality.
* 2: Application makes some use of tests, but the coverage is insufficient given projet requirements.
* 1: Application does not demonstrate strong use of TDD.

### 3. Encapsulation / Breaking Logic into Components

* 4: Application is expertly divided into logical components each with a clear, single responsibility. 
* 3: Application effectively breaks logical components apart but breaks the principle of SRP.
* 2: Application shows some effort to break logic into components, but the divisions are inconsistent or unclear.
* 1: Application logic shows poor decomposition with too much logic mashed together.

### 4. Fundamental Ruby & Style

* 4:  Application demonstrates excellent knowledge of Ruby syntax, style, and refactoring.
* 3:  Application shows strong effort towards organization, content, and refactoring.
* 2:  Application runs but the code has long methods, unnecessary or poorly named variables, and needs significant refactoring.
* 1:  Application generates syntax error or crashes during execution.

### 5. Enumerable & Collections

* 4: Application consistently makes use of the best-choice Enumerable methods
* 3: Application demonstrates comfortable use of appropriate Enumerable methods
* 2: Application demonstrates functional knowledge of Enumerable but only uses the most basic techniques
* 1: Application demonstrates deficiencies with Enumerable and struggles with collections
