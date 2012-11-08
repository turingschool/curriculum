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

An *algorithm* is a series of steps used to create an outcome. For instance, a recipie is a kind of algorithm -- you follow steps and, hopefully, create some food.

There are many algorithms used in cryptography. One of the easiest goes back to the days of Ancient Rome.

Julius Caesar needed to send written instructions from his base in Rome to his soldiers thousands of miles away. What if the messenger was captured or killed? The enemy could read his plans!

Caesar's army used an algorithm called "ROT-13".

#### Building a Cipher

"ROT-13" is an algorithm that uses a cipher. A cipher is a tool which translates one piece of data to another. If you've ever used a "decoder ring", that's a cipher. The cipher has an input and an output.

Let's make a cipher for "ROT-13":

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
2. What is the decrypted version of a message "anqn"?

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

{% terminal %}
$ dir
Volume in drive C has no label
Volume Serial Number is 3C53-24A5

Directory of C:\Users\YOURUSERNAME

11/06/2012 12:00 &lt;DIR&gt; .
11/06/2012 12:00 &lt;DIR&gt; ..
11/08/2012 12:00 &lt;DIR&gt; encryptor.rb
...
{% endterminal %}


And it will output the files in the current directory. In that list you should see `encryptor.rb`.

If you *don't* see it, first make sure you saved the file in your editor. Then use `cd` to change to the correct directory.

##### On MacOS

From the command prompt, run this instruction:

{% terminal %}
$ ls
Desktop Downloads Movies Pictures encryptor.rb
Documents Library Music Public
{% endterminal %}

And it will output the files in the current directory. In that list you should see `encryptor.rb`.

If you *don't* see it, first make sure you saved the file in your editor. Then use `cd` to change to the correct directory.

#### Loading it in IRB

Now that you know you're in the right directory, run IRB:

{% terminal %}
$ irb
1.9.3p194 :001 >
{% endterminal %}

Then, at the IRB prompt, tell it to load your file:

{% irb %}
$ load './encryptor.rb'
=> true
{% endirb %}

##### Creating an Instance

Now that IRB has loaded your code, you can create an instance of the `Encryptor` class like this:

{% irb %}
$ e = Encryptor.new
=> #<Encryptor:0x007f7f39060440>
{% endirb %}

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

{% irb %}
$ sample = {"name" => "Jeff", "age" => 12}
=> {"name"=>"Jeff", "age"=>12} 
{% endirb %}

On the right side I've created a hash by using the `{` and `}`. Inside those curly brackets, I created two key-value pairs. The first one has the key `"name"` which points to a value `"Jeff"`. Then a comma separates the first pair from the second pair, then the key `"age"` points to the value `12`.

I can lookup values in that hash like this:

{% irb %}
$ sample["age"]
=> 12
$ sample["name"]
=> "Jeff"
{% endirb %}

#### Building the Cipher / Lookup Table

This part is going to be boring. That's common when we're building "the simplest thing that could possibly work"!

We need to write out a hash which has every letter of the alphabet and which letter it corresponds to in the cipher. Use your paper cipher as a guide. Here's how it starts within your `encryptor.rb`:

```ruby
class Encryptor
  def cipher
    {'a' => 'n', 'b' => 'o', 'c' => 'p', 'd' => 'q',
     'e' => 'r', 'f' => 's', 'g' => 't', 'h' => 'u',
     'i' => 'v', 'j' => 'w', 'k' => 'x', 'l' => 'y',
     'm' => 'z', 'n' => 'a', 'o' => 'b', 'p' => 'c',
     'q' => 'd', 'r' => 'e', 's' => 'f', 't' => 'g',
     'u' => 'h', 'v' => 'i', 'w' => 'j', 'x' => 'k',
     'y' => 'l', 'z' => 'm'}
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

{% irb %}
$ load './encryptor.rb'
=> true
$ e = Encryptor.new
=> #<Encryptor:0x007f7f39060440>
$ e.encrypt('m')
=> 'z'
{% endirb %}

Did it give you back `'z'`? If not, look for typos in your code or lookup table.

##### A Little Issue

In the same IRB window, try this:

{% irb %}
$ e.encrypt('M')
{% endirb %}

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

{% irb %}
$ load './encryptor.rb'
=> true
$ e = Encryptor.new
=> #<Encryptor:0x007f7f39060440>
$ e.encrypt('M')
=> 'z'
{% endirb %}

If it gives you back `"z"`, then everything is on track!

### Encrypting a Whole String

Our program is really sweet, as long as your message is only one letter and you don't need to ever decrypt it. Hmmmm....

#### An Experiment

Maybe it will magically work! Let's try this in IRB:

{% irb %}
$ e.encrypt("Hello")
{% endirb %}

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

{% irb %}
$ sample = "Hello World"
=> "Hello World"
$ sample.split
=> ["Hello", "World"]
{% endirb %}

When we don't pass in any parameters, `split` will cut the string wherever it sees a space.

What if we pass in a parameter? Try this:

{% irb %}
$ sample.split("o")
{% endirb %}

The output was pretty different. It cut the string wherever it found an `"o"`.

#### Splitting Into Letters

So how does this help our `Encryptor`? We can actually pass the parameter `""` to `split`. Try this out:

{% irb %}
$ sample.split("")
{% endirb %}

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

{% irb %}
$ results = []
$ results.push(6)
$ results.push(2)
$ results.push(9)
$ results
{% endirb %}

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

{% irb %}
$ load './encryptor.rb'
 => true
$ e = Encryptor.new
 => #<Encryptor:0x007f7f3913a3e8>
$ e.encrypt("Hello")
 => "uryyb"
{% endirb %}

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

{% irb %}
$ sample = ["a", "b", "c"]
=> ["a", "b", "c"]
$ sample.each do |letter|
$  letter.upcase
$ end
 => ["a", "b", "c"]
$ sample.collect do |letter|
$  letter.upcase
$ end
 => ["A", "B", "C"]
{% endirb %}

Do you see the difference in the outputs. When we use `.each`, we get back the original sample lettters. It's as though the `.upcase` never happened.

When we use `.collect` though, we get back the three letters capitalized. This array is the result of running the `.upcase` method and gathering the results.

To take it a step further, we could save the capitalized letters into a new array like this:

{% irb %}
$ capitals = sample.collect do |letter|
$  letter.upcase
$ end
 => ["A", "B", "C"]
$ capitals
 => ["A", "B", "C"]
{% endirb %}

Now we have an array named `capitals` which holds the same results.

##### Challenge: Using `.collect` in `.encrypt`

Now look at your code for `encrypt`. How can you use `.collect` instead of `.each` and get rid of the *two* lines of code?

Make sure that your `encrypt` method still works by testing it in IRB after you make the changes.

#### Decrypting

Encrypting is cool, but only if you can eventually decrypt the message.

There's this funny thing about decrypting ROT-13. There are 26 letters in the alphabet. Moving forward 13 letters is the same as moving backward 13 letters.

Write your own '`.decrypt`' method so that when tested you get output like this:

{% irb %}
$ load './encryptor.rb'
=> true
$ e.encrypt("Secrets")
 => "frpergf"
$ e.decrypt("frpergf")
=> "secrets"
{% endirb %}

Now your have a proper encryption/decryption tool.

### Encrypting with Math

What if the enemy figures out the cipher?

We could change the cipher at any time. For instance, we could decided to use a "ROT-8" and only rotate eight letters.

How would you do this given the current implementation? You'd have to retype the entire cipher - yuk.

Worse, what if you want your one encryption engine to support both ROT-13 and ROT-8? What about ROT-4? ROT-20? You might need to write 26 different ciphers.

That's ridiculous. Instead, let's figure out how to do our encryption and decryption using math. That way we can get rid of the cipher all together.

#### The Pseudocode

The structure of our program will stay exactly the same. The main method that has to change is `encrypt_letter`.

Instead of using the cipher for the lookup, this method needs to:

1. Accept both a letter and a number to positions to rotate as arguments
2. Convert the letter to an integer
3. Add the rotation to the integer
4. Convert the integer back to a string

#### Converting a Letter to an Integer

What do I mean by converting a string to an integer? It turns out that computers understand strings based on a *character map*.

A character map is a table which lists every letter and symbol available in the language. That includes everything from the uppercase B (`"B"`) to the little M (`"m"`) to the exclamation mark (`"!"`). Every character you can type is in the character map and has a corresponding number representation.

In Ruby, we can find the number representing each letter by calling the `.ord` method. For example:

{% irb %}
$ "a".oct
=> 0
$ "a".ord
=> 97
$ "b".ord
=> 98
$ "C".ord
=> 67
$ "D".ord
=> 68
$ "!".ord
=> 33
{% endirb %}

##### Challenge

What do those numbers tell you about the character map? If you were going to illustrate the lookup table of the whole character map, which order do lowercase letters, uppercase letters, and symbols come in?

#### Converting from an Integer to a String

The opposite of the `.ord` method is `.chr` like this:

{% irb %}
$ 35.chr
=> "#"
$ 55.chr
=> "7"
$ 85.chr
=> "U"
$ 105.chr
=> "i"
{% endirb %}

#### Passing in the Rotation Number

In programming we say that methods have a *signiture*. The signiture of the `encrypt_letter` method is currently this:

```ruby
def encrypt_letter(letter)
```

The signiture defines the name of the method and how many parameters it requires. Let's modify our method so it now takes two parameters: the letter to encrypt and the number of positions to move. The signiture would look like this:

```ruby
def encrypt_letter(letter, rotation)
```

The idea is that we'd now call this method like this:

{% irb %}
$ load './encryptor.rb'
 => true
$ e = Encryptor.new
=> #<Encryptor:0x007f7f391613f8>
$ e.encrypt_letter("a", 13)
=> "n"
$ e.encrypt_letter("a", 12)
=> "n"
{% endirb %}

When I pass in `"a"` and `"13"` it should rotate the letter thirteen spots and return `"n"`, which works.

But when I pass in `"a"` and `"12"` it should rotate only twelve spots and return `"m"`. This output is not correct!

#### Rewriting `encrypt_letter`

Ok, you have all the tools. Now it's up to you to rewrite the `encrypt_letter` method. Use `.ord` and `.chr` to do your conversions.

When it's done correctly you output should match this:

{% irb %}
$ e.encrypt_letter("a", 13)
=> "n"
$ e.encrypt_letter("a", 11)
=> "l"
$ e.encrypt_letter("a", 15)
=> "p"
{% endirb %}

#### Reworking `encrypt`

Now that the `encrypt_letter` expects two arguments, we need to rework `encrypt` to send it two arguments.

Currently the signiture of `encrypt` looks like this:

```ruby
def encrypt(string)
```

Change the method so it:

1. takes a second argument named `rotation`
2. passes that `rotation` into the call to `encrypt_letter`

##### Testing

When I test my method, here's the output:

{% irb %}
$ e.encrypt("Hello", 13)
=> "Uryy|"
$ e.encrypt("Hello World", 13)
=> "Uryy|-d|\x7Fyq"
{% endirb %}

That output is looking strange! Look at the second one, it has way too many characters. `"Hello World"` is 11 characters long, but that output looks longer...? Count it with your eye and you'll find the output is 13 characters long.

But what does Ruby think?

{% irb %}
$ "Hello World".length
=> 11
$ e.encrypt("Hello World", 13).length
=> 11
$ "Uryy|-d|\x7Fyq".length
=> 11
{% endirb %}

WHAT?!? Is Ruby lying to us?

No, there are just some special characters in the string. Specifically the "r" in "World". When we rotate it thirteen spots farther in the character map, it goes beyond the printable letters. Check this out:

{% irb %}
$ "r".ord
=> 114
$ "r".ord + 13
=> 127
$ ("r".ord + 13).chr
=> "\x7F"
$ ("r".ord + 13).chr.length
 => 1
{% endirb %}

The result of moving `"r"` thirteen spots is represented as `"\x7F"`. Even though it looks to us like four characters, the when Ruby sees the format `"\xYY" it considers that a special character with the code YY.

What's the takeaway here? Everything is OK! We don't have to understand what Ruby means by `"\x7f"` as long as we can later decrypt it.

### Writing `decrypt`

Speaking of which, we need to rework our `decrypt` method.

Depending how you wrote the method originally, this might be easy or it might be hard. Consider this:

Decrypting is the opposite of encrypting. In our current process encrypting means moving forward `rotation` number of spots in the character map. Decrypting is then moving backwards the same number of spots.

Implement your own version of `decrypt` that can successfully match these results:

{% irb %}
$ load './encryptor.rb'
=> true
$ e = Encryptor.new
=> #<Encryptor:0x00000108090b10>
$ encrypted = e.encrypt("Hello, World!", 10)
=> "Rovvy6*ay|vn+"
$ e.decrypt(encrypted, 10)
=> "Hello, World!"
$ encrypted = e.encrypt("Hello, World!", 16)
=> "Xu||\x7F<0g\x7F\x82|t1"
$ e.decrypt(encrypted, 16)
=> "Hello, World!"
{% endirb %}

Now our encryption engine can flexibly use any rotation number!

### Working with Files

Your encryption engine is cool for encrypting a few words, but what about a whole file? Using what we've already built, it's not too hard.

#### Experimenting with File I/O

Let's first play with "File I/O" in IRB. When we say "I/O" we mean "Input / Output".

We'll load a plain message in as input, then encrypt it, and output a new file with the encrypted message. We could then transmit that encrypted file, maybe as an email attachment, then our trusted correspondant can decrypt it back to a plain file.

File I/O in Ruby is much easier than many other programming languages. Let's do I/O backwards and output a file first.

##### File Handles

Whenever we work with files we create a *file handle*. You can think of this as a connection between the program and the file system which holds the files.

It wouldn't be acurate to say that a program holds or contains a file. Instead, we have this connection to the file system and can ask that connection to read in data from the file or write data out to it.

##### Outputting to a File

Let's start by outputting some text to a file. Try this in IRB:

{% irb %}
$ out = File.open("sample.txt", "w")
$ out.write("Hello, World!")
$ out.write("This is a file, hooray.")
$ out.close
{% endirb %}

When you run that then change back to SublimeText, you may see the `sample.txt` file pop up on the left side. If not, go to the FILE menu, click OPEN, and find `sample.txt`

What do you notice about this file? There's something that isn't quite right about how it writes out the text -- the two lines of text are on the same line of the output file.

Try the instructions above, but add a `\n` to the end of the strings that you write out. This is a special marker to create a "new line".

##### Reading a File

The first line of the previous example was this:

```ruby
out = File.open("sample.txt", "w")
```

See that `"w"`? What was that for? When we create a file handle, a connection to the file system, we have to tell Ruby what kind of connection we want. Are we going to *w*rite to the file (`"w"`), *r*ead from it (`"r"`), or both (`"rw"`)?

Previously we wanted to write to the file, so we used the mode `"w"`. Now we want to read from the file, so we'll use `"r"` like this:

```ruby
input = File.open("sample.txt", "r")
input.read
```

You'll see that the content of the file has been read back in, but it looks weird with the `"\n"` newlines in there. To see it printed with the lines broken apart, try this:

```ruby
input = File.open("sample.txt", "r")
puts input.read
```

##### File Cursor

Now for something strange. Assuming you just did the previous example, try running just this instruction again:

```ruby
puts input.read
```

What do you get out? Is that what you expected?

Probably not. When you open a file for reading you start with a "cursor".

Imagine you had a piece of paper with words on it. When you first look at the paper, you could put your finger on the first word on the page. This is your cursor.

If someone told you to read the page, you'd move the cursor along word by word, line by line, until you got to the end. When the cursor was on the last word, you'd stop.

File handles work the same way. When we first opened the file the cursor was on the first letter of the file. When we said `.read` it read back all the contents of the file.

But then the cursor was at the end of the file. If we call `.read` again we'll just get back `nil` because there's nothing left in the file.

If you wanted to read the file from the beginning again, you could do this:

```ruby
input.rewind
puts input.read
```

#### Creating a Secret Message

Now we need a message to encrypt.

Using SublimeText, create a new file by going to the FILE menu and clicking NEW FILE.

In this file, create a short secret message that is at least three lines long.

Once you have the content, save it with the name `secret.txt` in the same directory as your `encryptor.rb` program.

#### Writing an `encrypt_file` Method

Let's start a new method in `encryptor.rb` like this:

```ruby
def encrypt_file(filename, rotation)

end
```

This method will take in two parameters, the filename of the file to be encrypted and the number of letters to rotate.

##### Pseudocode

Add this pseudocode into the method as comments:

1. Create the file handle to the input file
2. Read the text of the input file
3. Encrypt the text
4. Create a name for the output file
5. Create an output file handle
6. Write out the text
7. Close the file

##### Implement It

You've seen all the components that you need here. Figure out how to implement this method on your own. Here are a few notes to help you:

1. Use the filename variable from the parameter with the `File.open` call. Remember to specify the right read/write mode.
2. Just call the same method you did before to read the contents. You'll need to save this into a variable.
3. Call your `.encrypt` method passing in the text from step 2 and the rotation parameter
4. Name the output file the same as the input file, but with `".encrypted"` on the end. So an input file named `"sample.txt"` would generate a file named `"sample.txt.encrypted"`. Store the name in a variable.
5. Create a new file handle with the name from step 4 and remember the correct read/write mode.
6. Use the `.write` method like before.
7. Call `.close` on the output file handle

##### Test It

Run your code from IRB:

{% irb %}
$ load './encryptor.rb'
=> true
$ e = Encryptor.new
=> #<Encryptor:0x007f7f3916be98>
$ e.encrypt_file("sample.txt", 5)
=> nil
{% endirb %}

You get back `nil` because the `.close` method you called on the output file returns `nil`.

Open the `sample.txt.encrypted` in SublimeText. Does it look like a bunch of junk? Hopefully so! No one is going to be able to read your secret message.

#### Writing a `decrypt_file` Method

But did it really work? We can't know until we write a `decrypt_file` method.

##### Method Signiture

The method should look like this:

```ruby
def decrypt_file(filename, rotation)

end
```

##### Pseudocode

The pseudocode is almost the same:

1. Create the file handle to the encrypted file
2. Read the encrypted text
3. Decrypt the text by passing in the text and rotation
4. Create a name for the decrypted file
5. Create an output file handle
6. Write out the text
7. Close the file

You know how to do most of this. Here are two tricky parts:

##### Step 1. Read File Handle

For the very first step, where you create the file handle, Ruby will fail to detect which language the file is written in because of all the strange characters. You need to put a little more information in the read/write mode declaration like this:

```ruby
input = File.open(filename, "r:ASCII-8BIT")
```

##### Step 4. Output Filename

For the output filename, it'd be nice if we could call it something like `"sample.txt.decrypted"`. You could create that string using the `.gsub` method like this:

```ruby
output_filename = filename.gsub("encrypted", "decrypted")
```

Other than that, you're on your own!

#### Testing the Whole Process

Let's see the whole thing work together:

{% irb %}
$ load './encryptor.rb'
$ e = Encryptor.new
$ e.encrypt_file("sample.txt", 11)
$ e.decrypt_file("sample.txt.encrypted", 11)
{% endirb %}

Then open `"sample.txt.decrypted"` and see how it looks.

If it matches your input file, then your encryption engine is complete!

## TODO: Continued Iteration Ideas

* Password protect the program using a 1-way hash. Explain what 1-way hashes are, walk through generating a hashed string of the password in IRB, embed that hash result in their program and add a puts/gets wrapper to the run loop to ask for and check the password.
* Add a shoes front-end
* Implement a different/better algorithm rather than rotation