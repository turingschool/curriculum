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

# Iteration 4: Building out the runner

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
Question: What is Rachel's favorite animal?
panda
Incorrect.
This is card number 3 out of 4.
Question: What is Mike's middle name?
nobody knows
Correct!
This is card number 4 out of 4.
Question: What cardboard cutout lives at Turing?
Justin Bieber
Correct!
****** Game over! ******
You had 3 correct guesses out of 4 for a score of 75%.
```

# Iteration 5: Loading Text Files

Right now, we're hardcoding the flashcards into our runner. Wouldn't it be nice to have a whole text file of questions and answers to use? 

Let's build an object that will read in a text file and generate cards. Go back to using TDD for this iteration. 

Assuming we have a text file `cards.txt` that looks like this:

```
What is 5 + 5?,10
What is Rachel's favorite animal?,red panda
What is Mike's middle name?,nobody knows
What cardboard cutout lives at Turing?,Justin bieber
```

Then we should be able to do this: 

```ruby
filename = "cards.txt"
cards = CardGenerator.new(filename).cards
=> [#<Card:0x007f9f1413cbe8 @answer="10", @question="What is 5 + 5?">,
 #<Card:0x007f9f1413c788 @answer="red panda", @question="What is Rachel's favorite animal?">,
 #<Card:0x007f9f1413c2b0 @answer="nobody knows", @question="What is Mike's middle name?">,
 #<Card:0x007f9f14137da0 @answer="Justin bieber", @question="What cardboard cutout lives at Turing?">]
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
