# Iteration 1: Card Basics

First, we'll need a card object. Use TDD to drive the creation of an object that has this interaction pattern:

```ruby
card = Card.new("What is the capital of Alaska?", "Juneau")
card.question
=> "What is the capital of Alaska?"
card.answer
=> "Juneau"
```

# Iteration 2: Checking Answers

Users will enter an answer, and we need to know if the answer is correct. Let's use TDD to create this interaction pattern:

```ruby
card = Card.new("What is the capital of Alaska?", "Juneau")
answer = Answer.new("Juneau", card)
answer.card
=> <Card >
answer.response
=> "Juneau"
answer.correct?
=> true
```

```ruby
card = Card.new("Which planet is closest to the sun?", "Mercury")
answer = Answer.new("Saturn", card)
answer.card
=> <Card >
answer.response
=> "Saturn"
answer.correct?
=> false
```

# Iteration 3: Storing Cards in a Deck

Let's store the cards in a deck. Use TDD to drive the creation of an object that has this interaction pattern:

```ruby
card_1 = Card.new("What is the capital of Alaska?", "Juneau")
card_2 = Card.new("", "")
card_3 = Card.new("", "")
deck = Deck.new([card_1, card_2, card_3])
deck.cards
=> [card_1, card_2, card_3]
deck.count
=> 3
```

# Iteration 4: The Round

A round will be the object that processes responses and records answers. Use TDD to drive out this behavior: 

```ruby
card_1 = Card.new("What is the capital of Alaska?", "Juneau")
card_2 = Card.new("", "")
deck = Deck.new([card_1, card_2])
round = Round.new(deck)
round.deck
=> <Deck >
round.answers
=> []
answer_1 = round.record_answer("Juneau", card_1)
=> <Answer >
round.answers
=> [answer_1]
round.give_feedback(answer_1)
=> "Correct!"
round.number_correct
=> 1
answer_2 = round.record_answer("", card_2)
=> <Answer >
round.answers
=> [answer_1, answer_2]
round.give_feedback(answer_2)
=> "Incorrect."
round.number_correct
=> 1
round.percent_correct
=> 50
```

# Iteration 4: Building out the runner

We are going to skip TDD for this bit. First, we'll create a runner file which is what we'll run from the command line:

```
touch flashcard_runner.rb
```

Inside of this file:

```ruby
# write necessary code in order to be able to call 

round.start
```

Which produces the following interaction from the command line when running `ruby flashcard_runner.rb`: 

```
Welcome! You're playing with 4 cards.
-------------------------------------------------
This is card number 1 out of 4.
Question: Sample question 1?
sample answer1
Correct!
This is card number 2 out of 4.
Question: Sample question 2?
sample answer8
Incorrect.
This is card number 3 out of 4.
Question: Sample question 3?
sample answer3
Correct!
This is card number 4 out of 4.
Question: Sample question 4?
sample answer4
Correct!
****** Game over! ******
You had 3 correct answers out of 4 for a score of 75%.
```


# Extensions

1. Check whether or not the CSV file exists. If it does not, prompt the user to enter a new filename.
1. Instead of prompting the user for a filename, accept a filename as a command line argument (ie `$ ruby flashcards.rb card-data.csv`)
1. Output your results into JSON format. 
1. Allow both CSVs and text files containing JSON to be used for card data.
1. Use [Time.now](http://ruby-doc.org/core-2.2.3/Time.html#method-c-now) to generate a dynamic results file name.
1. Put incorrectly answered cards back into the iteration to be asked again.
1. Build in hint functionality. If a user enters "hint" when it's time to answer, the game should display a hint. In order to make this functional, you'll need to modify the CSV file you take in. 