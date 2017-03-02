---
layout: page
title: Ruby in 100 Minutes
sidebar: true
pdf: false
alias: [ /ruby_in_100_minutes, /ruby ]
---

In this tutorial, we'll explore the fundamental syntax you need to get started programming with Ruby.

<div class="note">
<p>If you haven't already set up Ruby, visit <a href="/topics/environment/environment.html">the environment setup page for instructions</a>.</p>
</div>

## Ruby History

Ruby is thought of by many as a "new" programming language, but it was actually released back in 1994 by a developer known as Matz. Matz is a self-described "language geek" and was a particularly big fan of Perl. His idea for Ruby was to create a language that was flexible and powerful like Perl, but more expressive in its syntax -- even pushing towards English-like readability.

Ruby grew an audience quickly -- in Japan. Until 2000 there really wasn't any documentation about the language that wasn't in Japanese. So if you wanted to learn Ruby you had to learn Japanese first. Dave Thomas, a pioneer of agile programming, became enamored with Ruby and decided to create that documentation. He wrote what's affectionately known as ["The Pickaxe"](http://pragprog.com/book/ruby/programming-ruby), due to its cover image, which opened Ruby to the English-speaking world.

From there Ruby started growing in the English-speaking world, though slowly. It became popular with system administrators to write maintenance and "glue" scripts -- the kinds of things Perl had been used for. The US Ruby community numbered in the hundreds from 2000-2005.

In 2004-2005 a Chicago company named 37Signals hired a young developer to build a web application. They gave him almost total freedom for the implementation; they were only concerned with the design and functionality from the client-side. At the time the predominant web technologies were Perl CGI, PHP, Java's JSP, and Microsoft's ASP. They were each somewhat painful, so David, today known as DHH, went his own direction.

He wrote the application in Ruby. He relied on the core library and a handful of helper libraries, but more-or-less created the entire stack himself. He and 37Signals worked on the web app, today known as Basecamp, and released it.

Then, once Basecamp was built, DHH extracted the web framework out of it. This was a very different approach from Java/Sun or .NET/Microsoft where the web frameworks were handed down from on high. Instead, Rails was extracted from the real world. It focused on convention over configuration and making the common problems easy to solve.

That approach was a big hit and Rails has powered the growth of the Ruby community ever since. Now we have dozens of books on Amazon, nearly a hundred conferences around the world, and thousands of people employed as Ruby/Rails developers.

And if you want to learn Rails, you need to learn Ruby first!  Here goes...

## 1. Instructions & Interpreters

Ruby is an "interpreted" programming language, which means it can't run on your processor directly; it has to be fed into a middleman called the "virtual machine" or VM. The VM takes in Ruby code on one side and speaks natively to the operating system and processor on the other. The benefit to this approach is that you can write Ruby code once and, typically, execute it on many different operating systems and hardware platforms.

A Ruby program can't run on its own, you need to load the VM. There are two ways to execute Ruby with the VM: through IRB and through the command line.

### Running Ruby from the Command Line

Because you save your instructions into a file, running Ruby from the Command Line is the durable way to write Ruby code. That file can then be backed up, transferred, added to source control, etc.


#### An Example Ruby File

We might create a file named `my_program.rb` like this:

```ruby
class Sample
  def hello
    puts "Hello, World!"
  end
end

s = Sample.new
s.hello
```

Then we could run the program like this:

{% terminal %}
$ ruby my_program.rb
Hello, World!
{% endterminal %}

When you run `ruby my_program.rb` you're actually loading the `ruby` virtual machine which in turn loads your `my_program.rb`.

### Running Ruby from IRB

Ruby was one of the first languages to popularize what's called a "REPL": Read, Evaluate, Print, Loop. Think of it kind of like a calculator -- as you put in each complete instruction, IRB executes that instruction and shows you the result.

IRB is best used as a scratch pad for experimenting. Many developers keep an IRB window open while writing their "real" programs, using it to remember how a certain method works or debug a chunk of code.

Let's begin our experiments with IRB. **Start IRB by opening Terminal (Mac) or Command Prompt (Win) and typing `irb`**.

## 2. Variables

Programming is all about creating abstractions, and in order to create an abstraction we must be able to assign names to things. Variables are a way of creating a name for a piece of data.

In some languages you need to specify what type of data (like a number, word, etc) can go in a certain variable. Ruby, however, has a flexible type system where any variable can hold any kind of data.

### Creating & Assigning a Variable

In some languages you need to "declare" a variable before you assign a value to it. Ruby variables are automatically created when you assign a value to them. Let's try an example:

{% irb %}
$ a = 5
 => 5
$ a
 => 5
{% endirb %}

The line `a = 5` creates the variable named `a` and stores the value `5` into it.

#### Right Side First

In English we read left-to-right, so it's natural to read code left to right. But when evaluating an assignment using the single equals (`=`), Ruby actually evaluates the *right side first*. Take the following example:

{% irb %}
$ b = 10 + 5
 => 15
$ b
 => 15
{% endirb %}

The `10 + 5` is evaluated first, and the result is given the name `b`.

#### Flexible Typing

Ruby's variables can hold any kind of data and can even change the type of data they hold. For instance:

{% irb %}
$ c = 20
 => 20
$ c = "hello"
 => "hello"
{% endirb %}

The first assignment gave the name `c` to the number `20`. The second assignment changed `c` to the value `"hello"`.

#### Naming Variables

Most Ruby variables (local variables) have a few requirements imposed by the VM. They...

* always start with a lowercase letter (underscore is permitted, though uncommon)
* have no spaces
* do not contain most special characters like `$`, `@`, and `&`

In addition to those VM requirements, Rubyists have a few common style preferences for variable names:

* use *snake case* where each word in the name is lowercase and connected by underscores (`_`)
* are named after the meaning of their contents, not the type of their contents
* aren't abbreviated

Good variable names might be `count`, `students_in_class`, or `first_lesson`.

A few examples of **bad** Ruby variable names include:

* `studentsInClass` -- uses *camel-case* rather than *snake-case*, should be `students_in_class`
* `1st_lesson` -- variables can't start with a number, should just be `first_lesson`
* `students_array` -- includes the type of the data in the name, should just be `students`
* `sts` -- abbreviates rather than just using `students`

### Exercises

Use IRB to store values with each of the following variable names. Which names are good, which are actually invalid Ruby, and which are valid but go against Ruby style?

* `time_machine`
* `student_count_integer`
* `homeworkAssignment`
* `3_sections`
* `top_ppl`

## 3. Strings

In the real world, strings tie things up. Programming strings have *nothing* to do with real-world strings.

Programming strings are used to store collections of letters and numbers. That could be a single letter like `"a"`, a word like `"hi"`, or a sentence like `"Hello my friends."`.

### Writing a String

A Ruby string is defined as a quote (`"`) followed by zero or more letters, numbers, or symbols and followed by a closing quote (`"`). The shortest possible string is called the empty string: `""`. It's not uncommon for a single string to contain paragraphs or even pages of text.

### Substrings

Often with strings we want to pull out just a part of the whole -- this is called a substring. Try these examples in `irb`:

{% irb %}
$ greeting = "Hello Everyone!"
$ greeting[0..4]
$ greeting[6..14]
$ greeting[6..-1]
$ greeting[6..-2]
{% endirb %}

#### Positive and Negative Positions

The characters in a string each have a position number, starting with zero. So for a string `"Hi"`, the `"H"` is in position zero and the `"i"` is in position 1.

To pull out a substring, we use the starting and ending positions. Thus, `greeting[0..4]` above pulls out the letters in position zero, one, two, three, and four.

Ruby interprets negative positions to count back from the end of the string. So in `"Hi"`, the `"i"` is in position -1 and the `"H"` is in position -2.

So if a letter has both a positive and negative position number, which should you use? If you can use the positive numbers, do it; they're easier to reason about. But, if you're looking for something based on it being at the end of the string (like "What's the last character of this string?"), then use the negative positions.

### Common String Methods

Let's experiment with strings and some common methods in IRB.

#### `.length`

The length method tells you how many characters are in the string (including spaces):

{% irb %}
$ greeting = "Hello Everyone!"
 => "Hello Everyone!"
$ greeting.length
 => 15
{% endirb %}

**Try It:** Calculate the total length of your name

#### `.split`

Often you'll have string that you want to break into parts. For instance, imagine you have a sentence stored in a string and want to break it into words:

{% irb %}
$ sentence = "This is my sample sentence."
 => "This is my sample sentence."
$ sentence.split
 => ["This", "is", "my", "sample", "sentence."]
{% endirb %}

The `.split` method gives you back an Array, which we'll learn about in a later section. It cuts the string wherever it encounters a space (`" "`) character.

##### `.split` with an Argument

Sometimes, however, you'll want to split on a character other than a space. The `.split` method takes an argument, a piece of data that tells it how to do what it does.

{% irb %}
$ numbers = "one,two,three,four,five"
 => "one,two,three,four,five"
$ numbers.split
 => ["one,two,three,four,five"]
$ numbers.split(",")
 => ["one", "two", "three", "four", "five"]
{% endirb %}

In the first call to `split`, it tries to cut on spaces but there are none, so you get back an Array of the entire string. In the second try, though, we specify that the splitting should happen wherever there is a comma, so we get back an Array of the five individual words.

#### `.sub` and `.gsub`

These two methods can be used to replace parts of a string. They're like using "Find & Replace" in a word processor. `.sub`, short for *substitute*, replaces just a single occurence. `.gsub`, short for *global substitute*, replaces all occurences (like "Replace All").

For both `.sub` and `.gsub`, you'll need to specify two arguments: first, the substring you're wanting to replace, and second, the string you want to replace it with.

{% irb %}
$ greeting = "Hello Everyone!"
$ greeting.gsub("Everyone!","Friends!")
{% endirb %}

### Combining Strings and Variables

It is extremely common that we want to combine the value of a variable with a string. For instance, let's start with this example string:

```ruby
"Good morning, Frank!"
```

When we put that into IRB, it just spits back the same string. If we were writing a proper program, we'd want it to greet the user with their name, rather than `"Frank"`.

What we need to do is combine a variable with the string. There are two ways to do that.

#### String Concatenation

The simplistic approach is called *string concatenation*, which is joins strings together with the plus sign:

{% irb %}
$ name = "Frank"
$ puts "Good morning, " + name + "!"
{% endirb %}

In the first line, we set up a variable to hold the name. In the second line, we print the string `"Good morning, ` , combined with the value of the variable `name` and the string `"!"`.

#### String Interpolation

The second approach is to use *string interpolation*, where we stick data into the middle of a string.

Within the string we use the interpolation marker `#{}`. Inside those brackets we can put any variables or Ruby code which will be evaluated, converted to a string, and output in that spot of the outer string. String interpolation only works on a double-quoted string. 

Our previous example could be rewritten like this:

{% irb %}
$ name = "Frank"
$ puts "Good morning, #{name}!"
{% endirb %}

If you compare the output, you'll see that they give the exact same results. The interpolation style tends to be fewer characters to type and fewer open/close quotes and plus signs to forget.

##### Executing Code Inside Interpolation

You can also put any Ruby code or calculations inside the brackets when interpolating like this:

{% irb %}
$ modifier = "very "
$ mood = "excited"
$ puts "I am #{modifier * 3 + mood} for today's class!"
{% endirb %}

The snippet `modifier * 3 + mood` is evaluated first, then the result is injected into the outer string.

## 4. Symbols

Symbols are difficult to explain; they're halfway between a string and a number. You can recognize a symbol by a colon, followed by one or more letters, like `:flag` or `:best_friend`.

### Symbols for New Programmers

If you're new to programming, think of a symbol as a stripped down string that has barely any methods and no string interpolation. Compare the method list for a proper string versus a similar symbol like this:

{% irb %}
$ "hello".methods
$ "hello".methods.count
$ :hello.methods
$ :hello.methods.count
{% endirb %}

### Symbols for Experienced Programmers

If you're an experienced programmer, think of a symbol as a "named integer". It doesn't matter what actual value the symbol references. All we care about is that any reference to that value within the VM will give back the same value. Symbols are thus defined in a global symbol table and their value cannot change.

## 5. Numbers

There are two basic kinds of numbers: integers (whole numbers) and floats (have a decimal point).

Integers are much easier for both you and the computer to work with. You can use normal math operations with integers, including `+`, `-`, `/`, and `*`. Integers have a bunch of methods to help you do math-related things, which you can see by calling `5.methods`.

### Repeating Instructions

A common pattern in *other* languages is the `for` loop, used to repeat an instruction a set number of times. For example, in JavaScript you might write:

```javascript
for(var i = 0; i < 5; i++){
  console.log("Hello, World");
}
```

For loops are common, but they're not very readable. Because Ruby's integers, are objects they have methods. One of those is the `times` method to repeat an instruction a set number of times.

To rewrite the above loop in a Ruby style:

```ruby
5.times do
  puts "Hello, World!"
end
```

In this example, we're using both the `times` method and what's called a *block*. We'll discuss blocks in the next section, but go ahead and run this example in IRB to see what happens.

## 6. Blocks

Blocks are a powerful concept used frequently in Ruby. Think of them as a way of bundling up a set of instructions for use elsewhere.

### Starting & Ending Blocks

You just saw a block used with the `.times` method on an integer:

```ruby
5.times do
  puts "Hello, World!"
end
```

The block starts with the keyword `do` and ends with the keyword `end`. The `do`/`end` style is always acceptable.

#### Bracket Blocks

When a block contains just a single instruction, though, we'll often use the alternate markers `{` and `}` to begin and end the block:

```ruby
5.times{ puts "Hello, World!" }
```

### Blocks Are Passed to Methods

So what is a block actually used for? They're a parameter passed into a method call.

If, for instance, we just called `5.times`, Ruby wouldn't know what we want to be done five times. When we pass in the block we're saying "here are the instructions I want you to run each time".

There are *many* methods that accept blocks. For example, the `.gsub` method, which you saw on String earlier, will run a block once for each match:

{% irb %}
$ "this is a sentence".gsub("e"){ puts "Found an E!"}
Found an E!
Found an E!
Found an E!
 => "this is a sntnc"
{% endirb %}

Notice that the `Found an E!` line shows up three times because there were three Es in the string.

Why does the result say `"sntnc"`? That's a puzzle for you.

### Block Parameters

Often our instructions within a block need to reference the value that they're currently working with. When we write the block, we can specify a block parameter inside pipe characters:

```ruby
5.times do |i|
  puts "Hello, World!"
end
```

What value gets put into that block parameter is up to the method we're calling. In this case, the `times` method puts in the number of the current run. Try the block as it is above, observe the output, then try this:

```ruby
5.times do |i|
  puts "#{i}: Hello, World!"
end
```

While `.gsub` passes in the string that it found. Try this (with the bracket notation):

```ruby
"this is a sentence".gsub("e"){|letter| letter.upcase}
```

You'll see that `gsub` is using the result of the block as the replacement for the original match.

## 7. Arrays

Usually when we're writing a program, it's because we need to deal with a *collection* of data. Let's first look at the most common collection of data, the Array.

### A Visual Model

An *array* is a number-indexed list. Imagine you had a blank piece of paper and drew a set of three small boxes in a line:

```plain
 ---  ---  ---
|   ||   ||   |
 ---  ---  ---
```

You could number each one by its position left to right:

```plain
 ---  ---  ---
|   ||   ||   |
 ---  ---  ---
  0    1    2
```

Then put strings in each box:

```plain
 -------------  ---------  ----------
| "Breakfast" || "Lunch" || "Dinner" |
 -------------  ---------  ----------
       0            1           2
```

We have a three-element Array. Ruby arrays can grow and shrink, so if we added an element, it'd usually go on the end:

```plain
 -------------  ---------  ----------  -----------
| "Breakfast" || "Lunch" || "Dinner" || "Dessert" |
 -------------  ---------  ----------  -----------
       0            1           2           3
```

Note how the position of the last element is always one less than the number of elements.

If you asked the array for the element in position two, you'd get back `"Dinner"`. Ask for the last element and you'd get back `"Dessert"`.

### Arrays in Code

Here's how we would go through the same modeling in Ruby code:

{% irb %}
$ meals = ["Breakfast", "Lunch", "Dinner"]
 => ["Breakfast", "Lunch", "Dinner"]
$ meals << "Dessert"
 => ["Breakfast", "Lunch", "Dinner", "Dessert"]
$ meals[2]
 => "Dinner"
$ meals.last
 => "Dessert"
{% endirb %}

Observe that...

* the array was created by putting pieces of data between square brackets (`[]`) and separated by commas
* we add an element to the end of an array by using the "shovel operator" (`<<`)
* we fetch the element at a specific position by using square brackets (`[]`)
* there are convenience methods like `.last`

### Common Array Methods

There are lots of cool things to do with an array. Here are a few examples:

#### Explanation of `.sort`

The sort method will return a new array where the elements are sorted. If the elements are strings, they'll come back in alphabetical order. If they're numbers, they'll come back in ascending value order. Try these:

{% irb %}
$ one = ["this", "is", "an", "array"]
$ one.sort
$ one
{% endirb %}

You can rearrange the order of the elements using the `sort` method. You can iterate through each element using the `each` method. You can mash them together into one string using the `join` method. You can find the address of a specific element by using the `index` method. You can ask an array if an element is present with the `include?` method.

We use arrays whenever we need a list where the elements are in a specific order.

#### Others to Try

Try experimenting with these common methods on Array:

* `each`
* `collect`
* `first` and `last`
* `shuffle`

You can reference the documentation for more details here: http://www.ruby-doc.org/core-2.1.2/Array.html

## 8. Hashes

A hash is a collection of data where each element of data is addressed by a *name*. As an analogy, think about a refrigerator. If we're keeping track of the produce inside the fridge, we don't really care about what shelf it's on -- the order doesn't matter. Instead we organize things by *name*. Like the name "apples" might have the value 3, then the name "oranges" might have the value 1, and "carrots" the value 12. In this situation, we'd use a hash.

### Key/Value Pairs

A hash is an *unordered* collection where the data is organized into "key/value pairs". Hashes have a more complicated syntax that takes some getting used to:

{% irb %}
$ produce = {"apples" => 3, "oranges" => 1, "carrots" => 12}
$ puts "There are #{produce['oranges']} oranges in the fridge."
{% endirb %}

The *key* is used as the address and the *value* is the data at that address. In the `produce` hash we have keys, including `"apples"` and `"oranges"`, and values, including `12` and `3`. When creating a hash, the key and value are linked by the `=>` symbol, which is called a _rocket_. So hashes start with a curly bracket `{`, have zero or more entries made up of a _key_, a rocket, and a _value_ separated by commas, then end with a closing curly bracket `}`.

Try a few more steps:

{% irb %}
$ produce["grapes"] = 221
$ produce
$ produce["oranges"] = 6
$ produce
$ produce.keys
$ produce.values
{% endirb %}

In the first line of those instructions, we add a new value to the hash. Since the `"grapes"` key wasn't in the original hash, it's added with the value of `221`. Keys in the hash *must be unique*, so when we use the same syntax with `produce["oranges"]`, it sees that the key `oranges` is already in the list and it replaces the value with `6`. The `keys` and `values` methods will also give you just half of the pairs.

### Simplified Hash Syntax

We'll very commonly use symbols as the keys of a hash. When all the keys are symbols, then there is a shorthand syntax which can be used:

{% irb %}
$ produce = {apples: 3, oranges: 1, carrots: 12}
$ puts "There are #{produce[:oranges]} oranges in the fridge."
{% endirb %}

Notice that the keys end with a colon rather than beginning with one, even though these are symbols. This simplified syntax works with Ruby version 1.9 and higher. To find out which version of Ruby you have type "ruby -v" into the console.

## 9. Conditionals

Conditional statements evaluate to `true` or `false`. The most common conditional operators are `==` (equal), `>` (greater than), `>=` (greater than or equal to), `<` (less than), and `<=` (less than or equal to).

Some objects also have methods that return a `true` or `false`, so they're used in conditional statements. For example, every object has the method `.nil?` which is `true` only when the object is `nil`. Arrays have a method named `.include?`, which returns true if the array includes the specified element. The convention in Ruby is that a method that returns `true` or `false` should have a name ending in a `?`.

### Conditional Branching / Instructions

Why do we have conditional statements?  Most often it's to control conditional instructions, especially `if`/`elsif`/`else` structures. Let's write an example by adding a method like this in IRB:

```ruby
def water_status(minutes)
  if minutes < 7
    puts "The water is not boiling yet."
  elsif minutes == 7
    puts "It's just barely boiling"
  elsif minutes == 8
    puts "It's boiling!"
  else
    puts "Hot! Hot! Hot!"
  end
end
```

Try running the method with `water_status(5)`, `water_status(7)`, `water_status(8)`, and `water_status(9)`.

#### Understanding the Execution Flow

When the `minutes` is 5, here is how the execution goes: "Is it `true` that 5 is less than 7? Yes, it is, so print out the line `The water is not boiling yet.`".

When the `minutes` is 7, it goes like this: "Is it `true` that 7 is less than 7? No. Next, is it `true` that 7 is equal to 7? Yes, it is, so print out the line `It's just barely boiling`".

When the `minutes` is 8, it goes like this: "Is it `true` that 8 is less than 7? No. Next, is it `true` that 8 is equal to 7? No. Next, is it `true` that 8 is equal to 8? Yes, it is, so print out the line `It's boiling!`".

Lastly, when total is 9, it goes: "Is it `true` that 9 is less than 7? No. Next, is it `true` that 9 is equal to 7? No. Next, is it `true` that 9 is equal to 8? No. Since none of those are true, execute the `else` and  print the line `Hot! Hot! Hot!`.

#### `if` Possible Constructions

An `if` statement has...

* One `if` statement whose instructions are executed only if the statement is true
* Zero or more `elsif` statements whose instructions are executed only if the statement is true
* Zero or one `else` statement whose instructions are executed if no `if` nor `elsif` statements were true

Only _one_ section of the `if`/`elsif`/`else` structure can have its instructions run. If the `if` is `true`, for instance, Ruby will never look at the `elsif`. Once one block executes, that's it.

### Equality vs. Assignment

The #1 mistake people encounter when writing conditional statements is the difference between `=` and `==`.

* `=` is an _assignment_. It means "take what's on the right side and stick it into whatever is on the left side" -- it's _telling_, not _asking_

* `==` is a _question_. It means "is the thing on the right equal to the thing on the left?" -- it's _asking_, not _telling_

You can also combine conditional statements using logical operators. The most common are known as "logical and" and "logical or". In Ruby, you can write a "logical and" with double ampersands, like this: `&&`. You can write a "logical or" with double pipes, like this: `||`.

## 10. Nil & Nothingness

What is nothingness?  Is there nothingness only in outer space?  Really, when we think of "nothing", isn't it just the absence of something?  OK, that's too much philosophy...

`nil` is Ruby's way of referring to "nothingness."

If you have three eggs, eat three eggs, then you might think you have "nothing", but in terms of eggs you have "0". Zero is something, it's a number, and it's not nothing.

If you're working with words and have a string like "hello", then delete the "h", "e", "l"s, and "o". You might think you'd end up with nothing, but you really have "", which is an empty string. It's still *something*.

`nil` is Ruby's idea of nothingness. It's usually encountered when you ask for something that doesn't exist. When looking at arrays, for instance, we created a list with five elements, then asked Ruby to give us the sixth element of that list. There is no sixth element, so Ruby gave us `nil`. It isn't that there's a blank in that sixth spot (`""`), it's not a number `0`, it's nothingness -- `nil`.

A large percentage of the errors you encounter while writing Ruby code will involve `nil`. You thought something was there, you tried to do something to it, and you can't do something to nothing, so Ruby raises an error.

## 11. Objects, Attributes, and Methods

### Ruby is Object-Oriented

Ruby is an Object-Oriented programming language, which means that all the things we interact with inside the VM are objects. Each piece of data is an object. Objects hold information, called _attributes_, and they can perform actions, called _methods_.

For an example of an object, think about you as a human being. You have attributes like height, weight, and eye color. You have methods like "walk", "run", "wash dishes", and "daydream."  Different types of objects have different attributes and methods. In the next sections we'll look at a few specific kinds of objects common in Ruby.

### Classes and Instances

In Object-Oriented programming we define *classes*, which are abstract descriptions of a category or type of thing. It defines what attributes and methods all objects of that type have.

#### Defining a Class

For example, let's think about modeling a school. We'd likely create a class named `Student` that represents the abstract idea of a student. The `Student` class would define attributes like `first_name`, `last_name`, and `primary_phone_number`. It could define a method `introduction` that causes the student to introduce themself.

Try this in IRB:

```ruby
class Student
  attr_accessor :first_name, :last_name, :primary_phone_number

  def introduction
    puts "Hi, I'm #{first_name}!"
  end
end
```

You haven't yet seen the `attr_accessor` method, which is used to define attributes for instances of a class.

#### Creating Instances

The class itself doesn't represent a student; it's the *idea* of what a student is like. To represent an actual student we create an *instance* of that class.

Imagine you're a student. You're not an abstract concept, you're an actual person. This actual person is an *instance* of `Student` - it is a realization of the abstract idea. It has actual data for the attributes `first_name`, `last_name`, and `primary_phone_number`.

The *class* `Student`, on the other hand, has an abstract `first_name`, `last_name`, and `primary_phone_number` -- we can't determine them ahead of time.

### Running Ruby from a File

We rarely use IRB for defining classes. It's just a scratchpad, remember? Let's look at how to run Ruby from a file.

* Exit your IRB session (enter `exit`)
* Note which folder your terminal is currently in, this is your "working directory"
* Using a plain-text editor to create a file named `student.rb`.
* Save the file in your editor
* Run the file from your terminal:

{% terminal %}
$ ruby student.rb
{% endterminal %}

You should get no output since the file is blank.

#### Creating a Student Class

In your text editor, begin the structure of the class like this:

```ruby
class Student

end
```

Inside the class, we usually define one or more methods using the `def` keyword:

```ruby
class Student
  def introduction
    puts "Hi, I'm #{first_name}!"
  end
end
```

Notice that the `puts` line is counting on there being a method named `first_name` which returns the first name of the student. Let's add the three attributes we used earlier:

```ruby
class Student
  attr_accessor :first_name, :last_name, :primary_phone_number

  def introduction
    puts "Hi, I'm #{first_name}!"
  end
end
```

#### Run the File

Go back to your terminal and try running the file with `ruby student.rb`. You should again get no output.

Why? We defined a student class and said that a student has a method named `introduction` along with a few attributes -- but we didn't actually create instances of that `Student` class or call any methods.

#### Creating an Instance

Once we define a class, we would create an `instance` of that class like this:

```ruby
frank = Student.new
```

We're calling the `new` method on the class `Student` and storing it into the variable named `frank`. Once we have that instance, we can set or get its attributes and call its methods. '

Methods are called by using this syntax: `object.method_name`. So if you have a variable named `frank`, you would tell him to introduce himself by calling `frank.introduction`.

#### Creating an Instance in the File

At the bottom of your `student.rb`, after the closing `end` for the `Student` class, add the following:

```ruby
frank = Student.new
frank.first_name = "Frank"
frank.introduction
```

Save it, return to your terminal, and try `ruby student.rb` again. It should now output `Hi, I'm Frank!`

### Method Arguments

Sometimes methods take one or more _arguments_ that tell them _how_ to do what they're supposed to do. For instance, I might call `frank.introduction('Katrina')` for him to introduce himself to Katrina. Arguments can be numbers, strings, or any kind of object. Modify your method to take an argument:

```ruby
class Student
  attr_accessor :first_name, :last_name, :primary_phone_number

  def introduction(target)
    puts "Hi #{target}, I'm #{first_name}!"
  end
end

frank = Student.new
frank.first_name = "Frank"
frank.introduction('Katrina')
```

Now run your file again and you should see `Hi Katrina, I'm Frank`.

### Return Value

In Ruby, every time you call a method, you get a value back. By default, a Ruby method returns the value of the last expression it evaluated.

#### Adding `favorite_number`

Let's add a method named `favorite_number` to our class.


```ruby
class Student
  attr_accessor :first_name, :last_name, :primary_phone_number

  def introduction(target)
    puts "Hi #{target}, I'm #{first_name}!"
  end

  def favorite_number
    7
  end
end

frank = Student.new
frank.first_name = "Frank"
puts "Frank's favorite number is #{frank.favorite_number}."
```

Run that from your terminal and you should see `Frank's favorite number is 7`. The last line of the file is calling the `favorite_number` method. The last (and only) line of that method is just the line `7`. That then becomes the return value of the method, which is sent back to whomever called the method. In our case, that `7` comes back and gets interpolated into the string.

## You've Got the Vocabulary

Alright, that's a quick introduction to the language. Now you're ready to dive into your Ruby!
