---
layout: page
title: Encryptor
---

Have you ever wanted to send a secret message?

### The Plan

Today we use computers to mask messages every day. When you connect to a website that uses "https" in the address, it is running a special encoding on your transmissions that makes it very difficult for anyone to listen in between you and the server.

The science of masking and unmasking data is called *cryptography*. When you take readable data and mask it, we say that you're "encrypting" the data. When you turn it back into readable text, you're "decrypting" the data.

Let's build a tool named "Encryptor" that can take in our messages, encrypt them for transmission, then decrypt messages we get from others.

#### Encryption Algorithms

An "algorithm" is a series of steps used to create an outcome. For instance, a recipie is a kind of algorithm -- you follow steps and, hopefully, create some food.

There are many algorithms used in cryptography. One of the easiest goes back to the days of Ancient Rome.

Julius Caesar need to send written instructions from his base in Rome to his soldiers thousands of miles away. What if the messenger was captured or killed? The enemy could read his plans!

Caesar's army used an algorithm called "ROT-13". Here's how it works.

#### Building a Cipher

ROT-13 is an algorithm that uses a cipher. A cipher is a tool which translates one piece of data to another. If you've ever used a "decoder ring", that's a cipher. The cipher has an input and an output.

Let's make a cipher for ROT-13:

1. Take a piece of lined paper
2. In a column, write the letters A through Z in order down the left side.
3. On the first line, start a second column by writing the letter N next to your A
4. Continue down the alphabet, so you now write "O" to the right of "B"
5. When your second column gets to "Z", start over again with "A"

The left side of your cipher is the input, the right side is the output. 

#### Using the Cipher

You take each letter of your secret data, find it in the left column, and write down the letter on the right. Now you have an encrypted message.

To decrypt a secret message, find the letter on the right side and write down the letter on the left.

#### Exercises

1. What is the result when you encrypt the phrase "Hello, World"?
2. What is the decrypted version of a message "???"

TODO: Fix the message question

### Starting Encryptor

#### The Big Picture

We need an object which will perform the encryption and decryption operations. We will define a class then write methods in that class. From IRB we can load that class, create an instance of it, then tell it to do the work with our messages.

#### Setting up the Class

We'll create a class which does both the encrypting and decrypting. Let's start it off like this:

```ruby
class Encryptor

end
```

And save it in a file named `encryptor.rb`

#### Checking File Location

Go to your Command Prompt window and make sure it's currently in the same directory as your `encryptor.rb` file.

##### On Windows

From the command prompt, run this instruction:

```
dir
```

And it will output the files in the current directory. In that list you should see `encryptor.rb`.

If you *don't* see it, first make sure you saved the file in your editor. Then use `cd` to change to the correct directory.

##### On MacOS

From the command prompt, run this instruction:

```
ls
```

And it will output the files in the current directory. In that list you should see `encryptor.rb`.

If you *don't* see it, first make sure you saved the file in your editor. Then use `cd` to change to the correct directory.

#### Loading it in IRB

Now that you know you're in the right directory, run IRB:

```
irb
```

Then, at the IRB prompt, tell it to load your file:

```
load './encryptor.rb'
```

##### Creating an Instance

Now that IRB has loaded your code, you can create an instance of the `Encryptor` class like this:

```ruby
e = Encryptor.new
 => #<Encryptor:0x007f7f39060440> 
```

The second line there is the output you'll see in IRB. The numbers/letters at the end will be different.

### Writing an `encrypt` Method

We made a class, that's a start -- but it doesn't **do** anything!

We need to write an `encrypt` method.

#### The Simplest Thing That Could Work

In computer programming, you want to first do the simplest thing that could possibly work. Often this is a solution that's difficult to maintain as requirements change or somehow "cheating." But the idea is that you get it *working* first, then you make it *better*.

Let's build a really simple implementation of `encrypt` using a lookup cipher like you made on paper.

#### Lookup Tables

When you created the cipher on paper you made what's called a "lookup table". It's a tool which you use by having some value, finding it in the list, and getting out some related value.

For instance, when the *input* to your lookup table is `"A"`, then the output is `"N"`. Let's build a lookup table in Ruby.

The easiest way to build a lookup table is to use a Ruby *hash*. 

##### A Quick Reminder about Hashes

If you recall, a hash is a collection of *key-value pairs*. When you want to find data in a hash, you give it the *key* and it gives you back the matching *value*.

Try this in IRB:

```ruby
sample = {"name" => "Jeff", "age" => 12}
```

On the right side I've created a hash by using the `{` and `}`. Inside those curly brackets, I created two key-value pairs. The first one has the key `"name"` which points to a value `"Jeff"`. Then a comma separates the first pair from the second pair, then the key `"age"` points to the value `12`.

I can lookup values in that hash like this:

```ruby
sample["age"]
 => 12 
sample["name"]
 => "Jeff" 
```

#### Building the Cipher / Lookup Table

This part is going to be boring. That's common when we're building "the simplest thing that could possibly work"!

We need to write out a hash which has every letter of the alphabet and which letter it corresponds to in the cipher. Use your paper cipher as a guide. Here's how it starts within your `encryptor.rb`:

```ruby
class Encryptor
  def cipher
    {"a" => "n", "b" => "o", "c" => "p", "d" => "q",
     "e" => "r", "f" => "s", "g" => "t", "h" => "u",
     "i" => "v", "j" => "w", "k" => "x", "l" => "y",
     "m" => "z", "n" => "a", "o" => "b", "p" => "c",
     "q" => "d", "r" => "e", "s" => "f", "t" => "g",
     "u" => "h", "v" => "i", "w" => "j", "x" => "k",
     "y" => "l", "z" => "m"}  
  end
end
```

Make sure you use all *lowercase letters*. If you neatly line up your rows like I did, it will make it a lot easier to find any typos, missing quotes, or missing commas.

#### Encrypting One Letter

Whew, that was tiring! Let's see if it actually worked.

We'll need to write an `encrypt` method. It'll take in just one letter and give us back the corresponding letter from the cipher.

Add this **inside** your `Encryptor` class:

```ruby
def encrypt(letter)
  cipher[letter]
end
```

##### Try It Out

In your IRB window, run these instructions:

```
load './encryptor.rb'
e = Encryptor.new
e.encrypt("m")
```

Did it give you back `"z"`? If not, look for typos in your code or lookup table.

##### A Little Issue

In the same IRB window, try this:

```
e.encrypt("M")
```

Did you get back `nil`? Ugh! Remember that `nil` means "nothing" in Ruby. Our `encrypt` method is looking in the `cipher` for a key `"M"`, but it isn't finding it. As far as Ruby is concerned, `"M"` and `"m"` are totally different things.

What should we do? Add all the capital letters to our cipher? That'll take us another 10 minutes!!!

##### A Hack to Deal with Uppercase/Lowercase

Let's implement a hack (or a "cheat") and say that no matter whether the incoming letter is uppercase or lowercase, we're going to output lowercase. Spies who are using our advanced cryptography system can fix the letters to uppercase on their own!

What we'll do here is modify the `encrypt` method so it turns *every* input into lowercase *before* looking it up in the cipher. If you pass in `"a"` it will just stay as `"a"` and be found in the cipher. If you pass in `"A"` it will be changed to `"a"` and found in the cipher.

Let's change our `encrypt` method to use the `.downcase` method. This method turns any string into all lowercase letters.

```ruby
def encrypt(letter)
  lowercase_letter = letter.downcase
  cipher[lowercase_letter]
end
```

Then go to IRB and try it again:

```
load './encryptor.rb'
e = Encryptor.new
e.encrypt("M")
```

If it gives you back `"z"`, then everything is on track!

### Encrypting a Whole String

Our program is really sweet, as long as your message is only one letter and you don't need to ever decrypt it. Hmmmm....

#### An Experiment

Maybe it will magically work! Let's try this in IRB:

```
e.encrypt("Hello")
```

What did you get? Ugh. There's no magic in programming. We'll need to write more instructions.

#### A Theory

I know, let's just make a lookup table that has all the words in the English language and points to their encrypted version! Come back in 20 years when you're done typing that up.

Instead, let's encrypt one letter at a time. The *algorithm* will go like this:

1. Cut the input string into letters
2. Encrypt those letters one at a time, gathering the results
3. Join the results back together in one string

Let's do it!

#### Remember `.split`?

We looked at the `.split` method on Strings before. It can cut up strings like this:

```ruby
sample = "Hello World"
# => "Hello World" 
sample.split
# => ["Hello", "World"] 
```

When we don't pass in any parameters, `split` will cut the string wherever it sees a space.

What if we pass in a parameter? Try this:

```
sample.split("o")
```

The output was pretty different. It cut the string wherever it found an `"o"`.

#### Splitting Into Letters

So how does this help our `Encryptor`? We can actually pass the parameter `""` to `split`. Try this out:

```
sample.split("")
```

You should see an array of all the letters chopped into their own strings.

#### One Letter at a Time

Our existing `encrypt` method really just encrypts one letter. Let's *change the name* it to `encrypt_letter` like this:

```ruby
def encrypt_letter(letter)
  lowercase_letter = letter.downcase
  cipher[lowercase_letter]
end
```

#### A New `encrypt`

Then let's start a new, blank `encrypt` method:

```ruby
def encrypt(string)
  
end
```

When I'm writing a program that's a little complicated, it helps me to first write **pseudocode**. Pseudocode is English that's "shaped" like code. It's a way to chart out the idea of what you want the code to do before you write it.

Taking the ideas from above, we can write pseudocode in our `encrypt` method using comments. In Ruby, any line that starts with a `#` is ignored. So here's our "blank" `encrypt` with some pseudocode:

```ruby
def encrypt(string)
  # 1. Cut the input string into letters
  # 2. Encrypt those letters one at a time, gathering the results
  # 3. Join the results back together in one string
end
```

Let's tackle those one by one.

#### Cut the Input String

This part we know already. We can use split like this:

```ruby
letters = string.split("")
```

Now we've got an Array of letters.

#### Encrypt Those Letters

This is the tricky part. Let me show you the simplest way first, then the best way second.

##### Gathering Results with an Array

Imagine you had a bunch of math problems to solve and needed to turn in a list of the solution. What would you do?

Probably grab a piece of paper, do the problems one by one, and write down each answer on the paper as you finish the calculation. Right?

We can do that in Ruby, too. Let's experiment in IRB:

```ruby
results = []
results.push(6)
results.push(2)
results.push(9)
results
```

The first line creates a blank array named `results`. The next three lines `push` a value on to the end of that array. It's like adding a value to the end of your piece of paper. Then the last line is just there to show us the values in results.

Let's use this technique in `encrypt`:

```ruby
def encrypt(string)
  # 1. Cut the input string into letters
  letters = string.split("")

  # 2. Encrypt those letters one at a time, gathering the results
  results = []
  letters.each do |letter|
    encrypted_letter = encrypt_letter(letter)
    results.push(encrypted_letter)
  end

  # 3. Join the results back together in one string
end
```

#### Joining the Results

`results` holds an array of letters, but we want to finish with a single string. Remember how to mash all the elements of an array together into a string?

We need the `.join` method. Call `.join` on the results array as the last line of `.encrypt`.

#### Testing

Try this in IRB:

```
load './encryptor.rb'
# => true 
e = Encryptor.new
# => #<Encryptor:0x007f7f3913a3e8> 
e.encrypt("Hello")
# => "uryyb" 
```

Did yours work? If you didn't get the exact same output `"uryyb"` go back and figure out what's going wrong.

#### Refactoring

Whenever we program we want to do the simplest thing that could possibly work. But then once it works, we try to make the code better. We can make it better by making it shorter, easier to understand, or faster to run.

This process is called **refactoring**.

My `encrypt` method currently looks like this:

```ruby
def encrypt(string)
  # 1. Cut the input string into letters
  letters = string.split("")

  # 2. Encrypt those letters one at a time, gathering the results
  results = []
  letters.each do |letter|
    encrypted_letter = encrypt_letter(letter)
    results.push(encrypted_letter)
  end

  # 3. Join the results back together in one string
  results.join
end
```

I'd first remove all the comments. The code works, so I don't need the English words telling me what it does.

```ruby
def encrypt(string)
  letters = string.split("")

  results = []
  letters.each do |letter|
    encrypted_letter = encrypt_letter(letter)
    results.push(encrypted_letter)
  end

  results.join
end
```

##### The `.collect` method

The next piece I'm interested in is the middle section. Arrays in Ruby have a method named `.collect`.

The `.each` method that we're already using goes through the elements in the array and runs the block once for each element.

The `.collect` method does the same thing, *but* it also gathers the results of running the block into an array and gives you back that array.

Let's try an example in IRB:

```
sample = ["a", "b", "c"]
# => ["a", "b", "c"] 
sample.each do |letter|
  letter.upcase
end
# => ["a", "b", "c"] 
sample.collect do |letter|
  letter.upcase
end
# => ["A", "B", "C"] 
```

Do you see the difference in the outputs. When we use `.each`, we get back the original sample lettters. It's as though the `.upcase` never happened.

When we use `.collect` though, we get back the three letters capitalized. This array is the result of running the `.upcase` method and gathering the results.

To take it a step further, we could save the capitalized letters into a new array like this:


```
capitals = sample.collect do |letter|
  letter.upcase
end
# => ["A", "B", "C"] 
capitals
# => ["A", "B", "C"] 
```

Now we have an array named `capitals` which holds the same results.

##### Challenge: Using `.collect` in `.encrypt`

Now look at your code for `encrypt`. How can you use `.collect` instead of `.each` and get rid of the *two* lines of code?

Make sure that your `encrypt` method still works by testing it in IRB after you make the changes.

### Encrypting with Math

#### Turning Strings into Characters

#### Strings and Math

#### Back from Numbers to Characters

#### A Problem

#### The Character Map

#### The Modulus Operation

#### Modulus in `encrypt`

### Writing `decrypt`

#### It's The Opposite

#### The beauty of ROT-13

### Going Beyond ROT-13

#### `encrypt` with a Parameter

#### Rewriting `decrypt` with a Parameter

### Working with Files

#### Creating a Secret Message

#### Writing an `encrypt_file` Method

#### Basic File Input

#### Testing `encrypt_file`

#### Outputting to a File

### Challenge

#### Brute-Force Codebreaker

#### Going Beyond ROT-13

