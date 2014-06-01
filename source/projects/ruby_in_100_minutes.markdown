---
layout: page
title: Ruby in 100 Minutes
sidebar: true
pdf: false
alias: [ /ruby_in_100_minutes, /ruby ]
---

In this tutorial we'll explore the fundamental syntax you need to get started programming with Ruby.

<div class="note">
<p>If you haven't already set up Ruby, visit <a href="/topics/environment/environment.html">the environment setup page for instructions</a>.</p>
</div>

## Ruby History

Ruby is thought of by many as a "new" programming language, but it was actually released back in 1994 by a developer known as Matz. Matz is a self-described "language geek" and was a particularly big fan of Perl. His idea for Ruby was to create a language that was flexible and powerful like Perl, but more expressive in its syntax -- even pushing towards English-like readability.

Ruby grew an audience quickly -- in Japan. Until 2000 there really wasn't any documentation about the language that wasn't in Japanese. So if you wanted to learn Ruby you had to learn Japanese first. Dave Thomas, a pioneer of agile programming, became enamored with Ruby and decided to create that documentation. He wrote what's affectionately known as ["The Pickaxe,"](http://pragprog.com/book/ruby/programming-ruby) due to its cover image, which opened Ruby to the English-speaking world.

From there Ruby started growing in the English-speaking world, though slowly. It became popular with system administrators to write maintenance and "glue" scripts -- the kinds of things Perl had been used for. The US Ruby community numbered in the hundreds from 2000-2005.

In 2004-2005 a Chicago company named 37Signals hired a young developer to build a web application. They gave him almost total freedom for the implementation; they were only concerned with the design and functionality from the client-side. At the time the predominant web technologies were Perl CGI, PHP, Java's JSP, and Microsoft's ASP. They were each somewhat painful, so David, today known as DHH, went his own direction.

He wrote the application in Ruby. He relied on the core library and a handful of helper libraries, but more-or-less created the entire stack himself. He and 37Signals worked on the web app, today known as Basecamp, and released it.

Then, once Basecamp was built, DHH extracted the web framework out of it. This was a very different approach from Java/Sun or .NET/Microsoft where the web frameworks were handed down from on high. Instead, Rails was extracted from the real world. It focused on convention over configuration and making the common problems easy to solve.

That approach was a big hit and Rails has powered the growth of the Ruby community ever since. Now we have dozens of books on Amazon, nearly a hundred conferences around the world, and thousands of people employed as Ruby/Rails developers.

And if you want to learn Rails, you need to learn Ruby first!  Here goes...

## 1. Instructions & Interpreters

Ruby is an "interpreted" programming language which means it must can't run on your processor directly, it has to be fed into a middleman called the "virtual machine" or VM. The VM takes in Ruby code on one side and speaks natively to the operating system and processor on the other. The benefit to this approach is that you can write Ruby code once and, typically, execute it on many different operating systems and hardware platforms.

A Ruby program can't run on it's own, you need to load the VM. There are two ways to execute Ruby with the VM: through IRB and through the command line.

### Running Ruby from the Command Line

This is the durable way to write Ruby code because you save your instructions into a file. That file can then be backed up, transferred, added to source control, etc.


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

In English we read right-to-left, so it's natural to read code right to left. But when evaluating an assignment using the single equals (`=`), Ruby actually evaluates the *right side first*. Take the following example:

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

Ruby variables have a few requirements imposed by the VM. They...

* always start with a lowercase letter
* have no spaces
* do not contain most special characters like `$`, `@`, and `&`

In addition to those VM requirements, Rubyists have a few common style preferences for variable names:

* use *snake case* where each word in the name is lowercase and connected by underscores (`_`)
* are named after the meaning of their contents, not the type of their contents
* don't abbreviate

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

## 3. Running Ruby from a File

While running simple commands in IRB is easy, it becomes tiresome to do anything that spans multiple lines. So we are going to continue from here writing our remaining Ruby code in a text file.

* Exit your IRB session
* Note which folder your terminal is currently in, this is your "working directory"
* Using a plain-text editor like Notepad++ or Sublime Text, create a file named `personal_chef.rb`.
* Save the file in your editor
* Reopen `irb` from your terminal
* Now load the file:

{% irb %}
$ load 'personal_chef.rb'
{% endirb %}

## 4. Objects, Attributes, and Methods

In Ruby, everything is an object. Objects know information, called _attributes_, and they can do actions, called _methods_.

For an example of an object, think about you as a human being. You have attributes like height, weight, and eye color. You have methods like "walk", "run", "wash dishes", and "daydream."  Different kinds of objects have different attributes and methods. In the next sections we'll look at a few specific kinds of objects common in Ruby.

A class is an *abstract* idea, it defines what all objects of that type can know and do. Think of the chair you're sitting in. It's not an abstract chair, it is an actual chair. We'd call this actual chair an *instance* - it is a realization of the idea chair. It has measurable attributes like height, color, weight. The *class* chair, on the other hand, has an abstract weight, color, and size -- we can't determine them ahead of time.

In Ruby, we define an object using the `class` keyword. Here's an example defining the object  `PersonalChef`:

```ruby
class PersonalChef

end
```

Inside the class we usually define one or more methods using the `def` keyword like this:

```ruby
class PersonalChef
  def make_toast
    puts "Making your toast!"
  end
end
```

Inside the `def` and `end` lines we'd put the instructions that the chef should perform when we say `make_toast`.

Once we define a class, we create an `instance` of that class like this:

```ruby
frank = PersonalChef.new
```

We're calling the `new` method on the class `PersonalChef` and storing it into the variable named `frank`. Once we have that instance, we can set or get its attributes and call its methods. Methods are called by using this syntax: `object.method_name`. So if you have a person named `frank`, you would tell him to make toast by calling `frank.make_toast`.

#### Exercise

* Copy the above code that defines the `PersonalChef` into your text file.
* In `irb` run the commands:

{% irb %}
$ load 'personal_chef.rb'
$ frank = PersonalChef.new
$ frank.make_toast
{% endirb %}

### Getting more out of your Chef

* Add a new method named `make_milkshake` on `PersonalChef`
* In `irb` run the commands:

{% irb %}
$ load 'personal_chef.rb'
$ frank = PersonalChef.new
$ frank.make_toast
$ frank.make_milkshake
{% endirb %}

### Hiring more staff

* Create a new class called `Butler`
* Add a method named `open_front_door` on `Butler`
* Create an `instance` of that class and assign it to a variable named `jeeves`
* In `irb` run the commands:

{% irb %}
$ load 'personal_chef.rb'
$ jeeves = Butler.new
$ jeeves.open_front_door
{% endirb %}

### Method Parameters

Sometimes methods take one or more _parameters_ that tell them _how_ to do what they're supposed to do. For instance, I might call `frank.make_toast('burned')` for him to burn my toast. Or maybe he has another method where I call `frank.make_breakfast("toast","eggs")` for him to make both toast and eggs. Parameters can be numbers, strings, or any kind of object. When a method takes a parameter it'll look like this:

```ruby
class PersonalChef
  def make_toast(color)
    puts "Making your toast #{color}"
  end
end
```

Where the method is expecting us to pass in a `color` telling it how to do the method `make_toast`.

#### Exercise

* Copy the above code that defines the `PersonalChef` into your text file.
* In `irb` run the commands:

{% irb %}
$ load 'personal_chef.rb'
$ frank = PersonalChef.new
$ frank.make_toast('burnt')
{% endirb %}

### Milkshake Flavors

* Create a `make_milkshake` method, that has a flavor parameter,  
  `flavor`
* In `irb` run the commands:

{% irb %}
$ load 'personal_chef.rb'
$ frank = PersonalChef.new
$ frank.make_milkshake('chocolate')
{% endirb %}

### Ask your butler to also open all your doors

* Create a new method named `open_door` which accepts a parameter which is
  the name of the door to open.
* Ask `jeeves` to open the *front* door, the *back* door, the *closet* door.
* In `irb` run the commands:

{% irb %}
$ load 'personal_chef.rb'
$ jeeves = Butler.new
$ jeeves.open_door('front')
$ jeeves.open_door('back')
$ jeeves.open_door('closet')
{% endirb %}

### Return Value

In Ruby, every time you call a method you get a value back. By default, a Ruby method returns the value of the last expression it evaluated. If you called the `make_toast` method above, you should have seen the return value `nil`. The `puts` instruction always returns `nil`, so since that was the last instruction in your method, you saw `nil` when calling that method.

For the purposes of our next section I'm going to explicitly return the chef instance itself from the method. Imagine you are looking at your chef `frank`. You say "Frank, go make my toast", he tells you he's making the toast, then comes back to you to receive more instructions. He's "returning" himself to you. Here's how we implement it in code:


```ruby
class PersonalChef

  def make_toast(color)
    puts "Making your toast #{color}"
    return self
  end

  def make_eggs(quantity)
    puts "Making you #{quantity} eggs!"
    return self
  end

end
```

We do this because we often want to call multiple methods on an object one after the other -- this is called _method chaining_ . Still thinking about `frank`, we might want to call `make_toast` and `make_eggs` one after the other. We can call multiple methods by using the format `object.method1.method2.method3`. So for this example, we might say:

```ruby
frank.make_toast("burned").make_eggs(6)
```

To read that in English, we're telling `frank` to `make_toast` with the parameter `burned`, then _after that is completed_ telling him to `make_eggs` with the parameter `6`.

#### Exercise

* Write a `make_milkshake` method that also `return self`
* Now ask `frank` to make you toast, eggs, and then immediately make you a
  milkshake
* In `irb` run the commands:

{% irb %}
$ load 'personal_chef.rb'
$ frank = PersonalChef.new
$ frank.make_toast('burnt').make_eggs(6).make_milkshake('strawberry')
{% endirb %}

### Hunger Games

* Add another `make_toast`, `make_eggs` or `make_milkshake` to the end of that
  line above. Continue to keep adding toast and milkshake orders until you
  are sick to your stomach.

*Remember to reload the file*: `load 'personal_chef.rb'`

## 5. Strings

In Ruby a string is defined as a quote (`"`) followed by zero or more letters, numbers, or symbols and followed by another quote (`"`). Some simple strings would be `"hello"` or `"This sentence is a string!"`. Strings can be anything from `""`, the empty string, to really long sets of text. This whole tutorial, for instance, is stored in a string. Strings have a few important methods that we'll use.

These exercises should be accomplished in IRB.

### Length of a String

{% irb %}
$ greeting = "Hello Everyone!"
$ greeting.length
{% endirb %}

* **length**

    > Call `length` on a string to get back the number of characters in the
      string. For instance `"hello".length` would give you back `5`.


#### Exercise

* Find out the length of your first, middle, and last name
* Calculate the total length of your name

### Deleting letters from a String

{% irb %}
$ greeting = "Hello Everyone!"
$ greeting.delete('l')
{% endirb %}

* **delete**

    > Delete lets you specify a set of characters that should be removed from
    the original string. For instance, `"hello".delete("l")` would give you back
    `"heo"` after deleting all occurrences of `"l"`, or `"Good
    Morning!".delete("on")` would give you `"Gd Mrig!"`

#### Exercise

* Pick the letter you hate the most and remove it from your name


### gsub (Replacing letters in a String)

{% irb %}
$ greeting = "Hello Everyone!"
$ greeting.gsub("Everyone!","Friends!")
{% endirb %}

* **gsub**

    > Call `gsub` to replace a substring with a different string. For instance,
    `"hello".gsub("ll","y yo")` would give you back `"hey yoo"`.

#### Exercise

* Change the above the example to say hello just to you.


### Splitting a String

{% irb %}
$ t2 = "sample,data,from,a,CSV"
$ t2.split(",")
{% endirb %}

* **split**

    > The `split` method is somewhat complex because it's used to break a single
    string into an array of strings. For instance, I could call `"Welcome to
    Ruby".split(" ")` and it would find the two occurrences of `" "` (a blank
    space) and split the string at those points, giving you back an array like
    this: `["Welcome","to","Ruby"]`

### Getting a piece of a String

Often with strings we want to pull out just a part of the whole -- this is called a substring. Try out these examples in `irb`:

{% irb %}
$ greeting = "Hello Everyone!"
$ greeting[0..4]
$ greeting[6..14]
$ greeting[6..-1]
$ greeting[6..-2]
{% endirb %}

The numbers inside the `[]` brackets specify which of the characters you want pulled out. They're numbered starting with zero. So the first example pulls out the letters from zero, the beginning of the string, up to and including position four. The second example pulls from `6` up to `14`. The third one goes from `6` up to...`-1`?  If you specify a negative value, that is like counting back from the end. Using `-1` means the end of the string, so `6..-1` means "from `6` to the end of the string." The last example goes from `6` to the second to last character in the string.

### Combining Strings and Variables

It is extremely common that we want to combine the value of a variable with other strings. For instance, let's start with this simple example string:

```ruby
"Happy Saturday!"
```

When we put that into IRB it just spits back the same string. If we were writing a proper program, we might want it to greet the user when they start the program by saying `"Happy"` then the day of the week. So we can't just put a string like `"Happy Saturday!"` or it'd be saying Saturday even on Tuesday.

What we need to do is combine a variable with the string. There are two ways to do that. The first and easiest approach is called _string concatenation_ which is basically just adding strings together like this:

{% irb %}
$ today = "Saturday"
$ puts "Happy " + today + "!"
{% endirb %}

In the first line we set up a variable to hold the day of the week, then in the second line we print the string `Happy` combined with the value of the variable `today` and the string `!`. You might be thinking "What was the point of that since we still just wrote Saturday in the first line?"  Ok, well, if you were writing a real program you'd use Ruby's built-in date functions like this:

{% irb %}
$ require 'date'
$ today = Date.today.strftime("%A")
$ puts "Happy " + today + "!"
{% endirb %}

String concatenation works fine most of the time, but there is a gotcha that pops up. Try this:

{% irb %}
$ today = Date.today.strftime("%A")
$ day_of_year = Date.today.yday
$ puts "Happy " + today + "! It is the " + day_of_year + " day of the year."
{% endirb %}

You should get an error complaining that Ruby "can't convert Fixnum into String". What does that mean?  When Ruby is assembling the parts of that string it sees a string `"Happy "`, then a string in the variable `today`, then a string with the ! and a few words, then the variable `day_of_year`, then the string `"day of the year."`.

The problem is that Ruby knows how to add one string to another, but it's not sure how to add a string to a number. `day_of_year` contains a number, and when it tries to combine the strings with that number, Ruby isn't sure what to do. Thankfully, numbers have a method which converts them into a string so they can be combined with strings. That method is `.to_s` for "to string". Retry your example with this slight change:

{% irb %}
$ today = Date.today.strftime("%A")
$ day_of_year = Date.today.yday
$ puts "Happy " + today + "! It is the " + day_of_year.to_s + " day of the year."
{% endirb %}

Great, no errors and our output looks correct. Having to remember that `.to_s` whenever you use a number is a pain, though. There is another combination method that forces the "to string" conversion for you called _string interpolation_.

### String Interpolation

*String interpolation* is the process of sticking data into the middle of strings. We use the interpolation marker `#{}`. Inside those brackets we can put any variables or Ruby code which will be evaluated, converted to a string, and output in that spot. Our previous example could be rewritten like this:

{% irb %}
$ puts "Happy #{today}! It is the #{day_of_year} day of the year."
{% endirb %}

If you compare the output you'll see that this second method gives the exact same results. The code itself is a little more compact and I find it much easier to read.

You can also put any Ruby code or calculations inside the brackets when interpolating like this example:

{% irb %}
$ modifier = "very "
$ mood = "excited"
$ puts "I am #{modifier * 3 + mood} for today's class!"
{% endirb %}

#### Back to Frank

Write a `good_morning` method on the `PersonalChef` object that, when called, prints out a message like "Happy Wednesday, it's the 132 day of 2011."

## 6. Symbols

Symbols are difficult to explain. You can recognize a symbol because it starts with a colon then one or more letters, like `:flag` or `:best_friend`.

Think of it as a stripped down string that has barely any methods and no string interpolation. Compare the method list for a proper string versus a similar symbol like this:

{% irb %}
$ "hello".methods
$ "hello".methods.count
$ :hello.methods
$ :hello.methods.count
{% endirb %}

Symbols are used for passing information around inside our program. We'd never print a symbol out to a user -- for that we'd use a string.

When starting out with pure Ruby you might not use symbols very frequently. But when you graduate to Ruby on Rails, they are everywhere. If you see an object that looks like `:this`, you'll know it's a symbol.

## 7. Numbers

There are two basic kinds of numbers: integers (whole numbers) and floats (have a decimal point). For most programs, you can get away with just integers, and I recommend avoiding floats whenever possible. Integers are much easier for both you and the computer to work with.

You can use normal math operations with integers including `+`, `-`, `/`, and `*`. Integers have a bunch of methods to help you do math-related things, which you can see by calling `5.methods`.

### Iterating

A common function in *other* languages is the `for` loop, used to repeat an instruction a set number of times. An example:

```
  for(int i=0; i < 5; i++){
    printf "Hello, World"
  }
```

But that's not very readable unless you're familiar with the construct. In Ruby, because our integers are proper objects, we have the handy `times` method to repeat an instruction a set number of times.

### Revisiting Making Eggs

Let's take another look at Frank's `make_eggs` method. We can rebuild it to take advantage of the `times` method like this:

```ruby
def make_eggs(quantity)
  quantity.times do
    puts "Making an egg."
  end
  puts "I'm done!"
  return self
end
```

In this example we're using the `times` method with a `do`/`end` block. When we call the `times` method we need to tell it what to *do* that number of times. Ruby looks for the starting keyword `do` and the ending keyword `end`. Each instruction between the `do` and `end` will be executed this number of `times`. Try this example with multiple instructions:

Try reloading the file with `load "personal_chef.rb"` and executing the `make_eggs` method for `frank`.

## 8. Collections

Usually when we're writing a program it's because we need to deal with a *collection* of data. There are two main types of collections in Ruby: *arrays* and *hashes*.

### Arrays

An *array* is a number-indexed list. Picture a city block of houses. Together they form an array and their addresses are the *indices*. Each house on the block will have a unique address. Some addresses might be empty, but the addresses are all in a specific order. The *index* is the address of a specific element inside the array. In Ruby the index always begins with `0`. An array is defined in Ruby as an opening `[`, then zero or more elements, then a closing `]`. Try out this code:

{% irb %}
$ meals = ["breakfast","lunch","dinner"]
$ puts meals[2]
$ puts meals.first
$ puts meals.last
{% endirb %}

Keep going with these, but note that the first line below should give you some unusual output. Try and understand what Ruby is telling you:

{% irb %}
$ puts meals[3]
$ meals << "dessert"
$ puts meals[3]
$ puts meals
{% endirb %}

In order to get a specific element in the array you use the syntax `arrayname[index]`.

There are lots of cool things to do with an array. You can rearrange the order of the elements using the `sort` method. You can iterate through each element using the `each` method. You can mash them together into one string using the `join` method. You can find the address of a specific element by using the `index` method. You can ask an array if an element is present with the `include?` method. Try adding this method to `PersonalChef` that manipulates an array:

```ruby
def gameplan(meals)
  meals.each do |meal|
    puts "We'll have #{meal}..."
  end

  all_meals = meals.join(", ")
  puts "In summary: #{all_meals}"
end
```

We use arrays whenever we need a list where the elements are in a specific order.

To try out Frank with your new `gameplan` method, go ahead and load `personal_chef.rb` again, instantiate `frank`, and try running your array through Frank like so:

{% irb %}
$ frank.gameplan(["chicken","beef"])
{% endirb %}

You can add as many meals to the game plan as you wish! Try this exercise with some of the other methods in your file.

### Hashes

A hash is a collection of data where each element of data is addressed by a *name*. As an analogy, think about a refrigerator. If we're keeping track of the produce inside the fridge, we don't really care about what shelf it's on -- the order doesn't matter. Instead we organize things by *name*. Like the name "apples" might have the value 3, then the name "oranges" might have the value 1, and "carrots" the value 12. In this situation we'd use a hash.

A hash is an *unordered* collection where the data is organized into "key/value pairs". Hashes have a more complicated syntax that takes some getting used to:

{% irb %}
$ produce = {"apples" => 3, "oranges" => 1, "carrots" => 12}
$ puts "There are #{produce['oranges']} oranges in the fridge."
{% endirb %}

The *key* is used as the address and the *value* is the data at that address. In the `produce` hash we have keys including `"apples"` and `"oranges"` and values including `12` and `3`. When creating a hash the key and value are linked by the `=>` symbol which is called a _rocket_. So hashes start with a curly bracket `{`, have zero or more entries made up of a _key_, a rocket, and a _value_ separated by commas, then end with a closing curly bracket `}`. Try a few more steps:

{% irb %}
$ produce["grapes"] = 221
$ produce
$ produce["oranges"] = 6
$ produce
$ produce.keys
$ produce.values
{% endirb %}

In the first line of those instructions, we add a new value to the hash. Since the `"grapes"` key wasn't in the original hash, it's added with the value of `221`. Keys in the hash *must be unique*, so when we use the same syntax with `produce["oranges"]` it sees that the key `oranges` is already in the list and it replaces the value with `6`. The `keys` and `values` methods will also give you just half of the pairs.

#### Simplified Hash Syntax

When all the keys are symbols, then there is a shorthand syntax which can be used:

{% irb %}
$ produce = {apples: 3, oranges: 1, carrots: 12}
$ puts "There are #{produce[:oranges]} oranges in the fridge."
{% endirb %}

Notice that the keys end with a colon rather than beginning with one, even though these are symbols. This simplified syntax works with Ruby version 1.9 and higher. To find out which version of Ruby you have type "ruby -v" into the console.

#### Creating an Inventory

Let's write a method for `PersonalChef` that uses and manipulates a hash:

```ruby
def inventory
  produce = {apples: 3, oranges: 1, carrots: 12}
  produce.each do |item, quantity|
    puts "There are #{quantity} #{item} in the fridge."
  end
end
```

That walks through each of the pairs in the inventory, puts the key into the variable `item` and the value into the variable `quantity`, then prints them out.

To see this code, load `personal_chef.rb`, instantiate Frank, and then run:

{% irb %}
$ frank.inventory
{% endirb %}

## 9. Conditionals

Conditional statements evaluate to `true` or `false`. The most common conditional operators are `==` (equal), `>` (greater than), `>=` (greater than or equal to), `<` (less than), and `<=` (less than or equal to).

Some objects also have methods which return a `true` or `false`, so they're used in conditional statements. For example every object has the method `.nil?` which is `true` only when the object is `nil`. Arrays have a method named `.include?` which returns true if the array includes the specified element. The convention in Ruby is that a method which returns `true` or `false` should have a name ending in a `?`.

### Conditional Branching / Instructions

Why do we have conditional statements?  Most often it's to control conditional instructions, especially `if`/`elsif`/`else` structures. Let's write an example by adding a method to our `PersonalChef` class:

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
  return self
end
```

Use `load` to re-read the file, then try this example using `5`, `7`, `8` and `9` for the values of `minutes`.

When the `minutes` is 5, here is how the execution goes: "Is it `true` that 5 is less than 7? Yes, it is, so print out the line `The water is not boiling yet.`".

When the `minutes` is 7, it goes like this: "Is it `true` that 7 is less than 7? No. Next, is it `true` that 7 is equal to 7? Yes, it is, so print out the line `It's just barely boiling`".

When the `minutes` is 8, it goes like this: "Is it `true` that 8 is less than 7? No. Next, is it `true` that 8 is equal to 7? No. Next, is it `true` that 8 is equal to 8? Yes, it is, so print out the line `It's boiling!`".

Lastly, when total is 9, it goes: "Is it `true` that 9 is less than 7? No. Next, is it `true` that 9 is equal to 7? No. Next, is it `true` that 9 is equal to 8? No. Since none of those are true, execute the `else` and  print the line `Hot! Hot! Hot!`.

An `if` block has...

* One `if` statement whose instructions are executed only if the statement is true
* Zero or more `elsif` statements whose instructions are executed only if the statement is true
* Zero or one `else` statement whose instructions are executed if no `if` nor `elsif` statements were true

Only _one_ section of the `if`/`elsif`/`else` structure can have its instructions run. If the `if` is `true`, for instance, Ruby will never look at the `elsif`. Once one block executes, that's it.

### Conditional Looping

We can also repeat a set of instructions based on the truth of a conditional statement. Try out this example by adding it to your `personal_chef.rb`:

```ruby
def countdown(counter)
  while counter > 0
    puts "The counter is #{counter}"
    counter = counter - 1
  end
  return self
end
```

See how that works?  The `counter` starts out as whatever parameter we pass in. The `while` instruction evaluates the conditional statement `counter > 0` and finds that yes, the counter is greater than zero. Since the condition is `true`, execute the instructions inside the loop. First print out `"The counter is #{counter}"` then take the value of `counter`, subtract one from it, and store it back into `counter`. Then the loop goes back to the `while` statement. Is it still `true`? If so, print the line and subtract one again. Keep repeating until the condition is `false`.

I most often use `while`, but you can achieve the same results using `until` as well. Try this...

```ruby
  def countdown(counter)
    until counter == 0
      puts "The counter is #{counter}"
      counter = counter - 1
    end
    return self
  end
```

### Equality vs. Assignment

The #1 mistake people encounter when writing conditional statements is the difference between `=` and `==`.

* `=` is an _assignment_. It means "take what's on the right side and stick it into whatever is on the left side" -- it's _telling_, not _asking_

* `==` is a _question_. It means "is the thing on the right equal to the thing on the left?" -- it's _asking_, not _telling_

You can also combine conditional statements using logical operators. The most common are known as "logical and" and "logical or". In Ruby you can write a "logical and" with double ampersands like this: `&&`. You can write a "logical or" with double pipes like this: `||`.

## 10. Nil & Nothingness

What is nothingness?  Is there nothingness only in outer space?  Really, when we think of "nothing", isn't it just the absence of something?  OK, that's too much philosophy...

`nil` is Ruby's way of referring to "nothingness."

If you have three eggs, eat three eggs, then you might think you have "nothing", but in terms of eggs you have "0". Zero is something, it's a number, and it's not nothing.

If you're working with words and have a string like "hello" then delete the "h", "e", "l"s, and "o" you might think you'd end up with nothing, but you really have "" which is an empty string. It's still something.

`nil` is Ruby's idea of nothingness. It's usually encountered when you ask for something that doesn't exist. When looking at arrays, for instance, we created a list with five elements then asked Ruby to give us the sixth element of that list. There is no sixth element, so Ruby gave us `nil`. It isn't that there's a blank in that sixth spot (`""`), it's not a number `0`, it's nothingness -- `nil`.

A large percentage of the errors you encounter while writing Ruby code will involve `nil`. You thought something was there, you tried to do something to it, and you can't do something to nothing so Ruby creates an error. Let's rewrite our `make_toast` method to illustrate `nil`:

```ruby
def make_toast(color)
  if color.nil?
    puts "How am I supposed to make nothingness toast?"
  else
    puts "Making your toast #{color}!"
  end
  return self
end
```

Reload the file, call `frank.make_toast("light brown")` then try `frank.make_toast(nil)`. The only method we can rely on `nil` executing is `.nil?`, pretty much anything else will create an error.

#### You've Got the Vocabulary

Alright, that's a quick introduction to the language. Now you're ready to dive into your Ruby!
