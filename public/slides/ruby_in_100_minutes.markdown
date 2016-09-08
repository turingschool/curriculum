title: Ruby in 100 Minutes
output: ruby_in_100_minutes.html
controls: true
theme: JumpstartLab/cleaver-theme
--

# Ruby in 100 Minutes

--

## Ruby History

* Ruby origins
* The Pickaxe
* DHH and Rails

--

## 1. Instructions & Interpreters

--

```ruby
class Sample
  def hello
    puts "Hello, World!"
  end
end

s = Sample.new
s.hello

$ ruby my_program.rb
```

--

## 2. Variables

--

A variable, like in math, is just a name for a piece of data.

```
$ a = 5
$ b = 10 + 5
$ c = 15 + a + b
$ b = c - a
```
--

You can also assign words or text to be stored in a variable.

```ruby
d = "Hello, "
e = "World!"
f = d + e
```

--

A familiar equation from Algebra is the equation of a line.

```ruby
y = m * x + b
```

--

In Ruby, you are allowed to give more descriptive names to your variables.

```ruby
y = slope * x + y_intercept
```

--

### Exercise

Create a variable that:

* stores a number (like `age`)
* stores some text (like `hometown`)
* that has an underscore **_** (like `first_name`)
* that has a number in it (like `favorite_color2`)

--

### Bonus

What happens when you create a variable name:

* that starts with a number?
* that uses a dash **-** instead of an underscore **_**?

--

### Question

* Why would you want to use an underscore in your variable names?

--

## 3. Running Ruby from a File

--

* Exit your IRB session
* Note which folder your terminal is currently in, this is your "working directory"
* Using a plain-text editor like Notepad++ or Sublime Text, create a file named `personal_chef.rb`.
* Save the file in your editor

--

* Reopen `irb` from your terminal
* Now load the file:

```
$ load 'personal_chef.rb'
```

--

## 4. Objects, Attributes, and Methods

--

In Ruby, everything is an object. Objects know information, called _attributes_, and they can do actions, called _methods_.

A class is an *abstract* idea, it defines what all objects of that type can know and do.
--

In Ruby, we define an object using the `class` keyword.

```ruby
class PersonalChef

end
```

--

Inside the class, we define one or more methods using the `def` keyword.


```ruby
class PersonalChef
  def make_toast
    puts "Making your toast!"
  end
end
```

--

Once we define a class, we can create an `instance` of that class.

```ruby
frank = PersonalChef.new
```

--

#### Exercise

In `irb` run the commands:

```
$ load 'personal_chef.rb'
$ frank = PersonalChef.new
$ frank.make_toast
```

--

### Getting more out of your Chef

Add a new method named `make_milkshake` on `PersonalChef`

--

In `irb` run the commands:

```
$ load 'personal_chef.rb'
$ frank = PersonalChef.new
$ frank.make_toast
$ frank.make_milkshake
```

--

### Hiring more staff

* Create a new class called `Butler`
* Add a method named `open_front_door` on `Butler`
* Create an `instance` of that class and assign it to a variable named `jeeves`

--

In `irb` run the commands:

```
$ load 'personal_chef.rb'
$ jeeves = Butler.new
$ jeeves.open_front_door
```

--

### Method Parameters

Sometimes methods take one or more _parameters_ that tell them _how_ to do what they're supposed to do.

--

Parameters can be numbers, strings, or any kind of object.

```ruby
class PersonalChef
  def make_toast(color)
    puts "Making your toast #{color}"
  end
end
```

--

#### Exercise

In `irb` run the commands:

```
$ load 'personal_chef.rb'
$ frank = PersonalChef.new
$ frank.make_toast('burnt')
```

--

### Milkshake Flavors

* Create a `make_milkshake` method, that has a flavor parameter,

```
$ load 'personal_chef.rb'
$ frank = PersonalChef.new
$ frank.make_milkshake('chocolate')
```

--

### Ask your butler to open your doors

* Create a new method named `open_door` which accepts a parameter which is the name of the door to open.
* Ask `jeeves` to open the *front* door, the *back* door, the *closet* door.

--

In `irb` run the commands:

```
$ load 'personal_chef.rb'
$ jeeves = Butler.new
$ jeeves.open_door('front')
$ jeeves.open_door('back')
$ jeeves.open_door('closet')
```

--

### Return Value

In Ruby, every time you call a method you get a value back.

```ruby
class PersonalChef
  def make_toast(color)
    puts "Making your toast #{color}"
    return self
  end
end
```

--

We do this because we often want to call multiple methods one after the other -- this is called _method chaining_ .

```ruby
frank.make_toast("burned").make_eggs(6)
```

--

#### Exercise

* Write a `make_milkshake` method that also `return self`
* Now ask `frank` to make you toast, eggs, and then immediately make you a milkshake

--

In `irb` run the commands:

```
$ load 'personal_chef.rb'
$ frank = PersonalChef.new
$ frank.make_toast('burnt').make_eggs(6).make_milkshake('strawberry')
```

--

### Hunger Games

* Add another `make_toast`, `make_eggs` or `make_milkshake` to the end of that

*Remember to reload the file*: `load 'personal_chef.rb'`

--

## 5. Strings

--

### Length of a String

{% irb %}
$ greeting = "Hello Everyone!"
$ greeting.length
{% endirb %}

* **length**

    > Call `length` on a string to get back the number of characters in the
      string. For instance `"hello".length` would give you back `5`.


--

#### Exercise

* Find out the length of your first, middle, and last name
* Calculate the total length of your name

--

### Deleting letters from a String

{% irb %}
$ greeting = "Hello Everyone!"
$ greeting.delete('l')
{% endirb %}

* **delete**

    > Delete lets you specify a set of characters that should be removed from
--

#### Exercise

* Pick the letter you hate the most and remove it from your name


--

### gsub (Replacing letters in a String)

{% irb %}
$ greeting = "Hello Everyone!"
$ greeting.gsub("Everyone!","Friends!")
{% endirb %}

* **gsub**

    > Call `gsub` to replace a substring with a different string. For instance,
--

#### Exercise

* Change the above the example to say hello just to you.


--

### Splitting a String

{% irb %}
$ t2 = "sample,data,from,a,CSV"
$ t2.split(",")
{% endirb %}

* **split**

    > The `split` method is somewhat complex because it's used to break a single

--

### Getting a piece of a String

{% irb %}
$ greeting = "Hello Everyone!"
$ greeting[0..4]
$ greeting[6..14]
$ greeting[6..-1]
$ greeting[6..-2]
{% endirb %}

The numbers inside the `[]` brackets specify which of the characters you want pulled out. They're numbered starting with zero. So the first example pulls out the letters from zero, the beginning of the string, up to and including position four. The second example pulls from `6` up to `14`. The third one goes from `6` up to...`-1`?  If you specify a negative value, that is like counting back from the end. Using `-1` means the end of the string, so `6..-1` means "from `6` to the end of the string." The last example goes from `6` to the second to last character in the string.

--

### Combining Strings and Variables

```ruby
"Happy Saturday!"
```

{% irb %}
$ today = "Saturday"
$ puts "Happy " + today + "!"
{% endirb %}

{% irb %}
$ require 'date'
$ today = Date.today.strftime("%A")
$ puts "Happy " + today + "!"
{% endirb %}

{% irb %}
$ today = Date.today.strftime("%A")
$ day_of_year = Date.today.yday
$ puts "Happy " + today + "! It is the " + day_of_year + " day of the year."
{% endirb %}

{% irb %}
$ today = Date.today.strftime("%A")
$ day_of_year = Date.today.yday
$ puts "Happy " + today + "! It is the " + day_of_year.to_s + " day of the year."
{% endirb %}

--

### String Interpolation

*String interpolation* is the process of sticking data into the middle of strings. We use the interpolation marker `#{}`. Inside those brackets we can put any variables or Ruby code which will be evaluated, converted to a string, and output in that spot. Our previous example could be rewritten like this:

{% irb %}
$ puts "Happy #{today}! It is the #{day_of_year} day of the year."
{% endirb %}

{% irb %}
$ modifier = "very "
$ mood = "excited"
$ puts "I am #{modifier * 3 + mood} for today's class!"
{% endirb %}

--

#### Back to Frank

Write a `good_morning` method on the `PersonalChef` object that, when called, prints out a message like "Happy Wednesday, it's the 132 day of 2011."

--

## 6. Symbols

{% irb %}
$ "hello".methods
$ "hello".methods.count
$ :hello.methods
$ :hello.methods.count
{% endirb %}

--

## 7. Numbers

You can use normal math operations with integers including `+`, `-`, `/`, and `*`. Integers have a bunch of methods to help you do math-related things, which you can see by calling `5.methods`.

--

### Iterating

```
  for(int i=0; i < 5; i++){
```

--

### Revisiting Making Eggs

```ruby
def make_eggs(quantity)
  quantity.times do
    puts "Making an egg."
  end
  puts "I'm done!"
  return self
end
```

--

## 8. Collections

--

### Arrays

An *array* is a number-indexed list. Picture a city block of houses. Together they form an array and their addresses are the *indices*. Each house on the block will have a unique address. Some addresses might be empty, but the addresses are all in a specific order. The *index* is the address of a specific element inside the array. In Ruby the index always begins with `0`. An array is defined in Ruby as an opening `[`, then zero or more elements, then a closing `]`. Try out this code:

{% irb %}
$ meals = ["breakfast","lunch","dinner"]
$ puts meals[2]
$ puts meals.first
$ puts meals.last
{% endirb %}

{% irb %}
$ puts meals[3]
$ meals << "dessert"
$ puts meals[3]
$ puts meals
{% endirb %}

```ruby
def gameplan(meals)
  meals.each do |meal|
    puts "We'll have #{meal}..."
  end

  all_meals = meals.join(", ")
  puts "In summary: #{all_meals}"
end
```

{% irb %}
$ frank.gameplan(["chicken","beef"])
{% endirb %}

--

### Hashes

A hash is a collection of data where each element of data is addressed by a *name*. As an analogy, think about a refrigerator. If we're keeping track of the produce inside the fridge, we don't really care about what shelf it's on -- the order doesn't matter. Instead we organize things by *name*. Like the name "apples" might have the value 3, then the name "oranges" might have the value 1, and "carrots" the value 12. In this situation we'd use a hash.

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

--

#### Simplified Hash Syntax

{% irb %}
$ produce = {apples: 3, oranges: 1, carrots: 12}
$ puts "There are #{produce[:oranges]} oranges in the fridge."
{% endirb %}

Notice that the keys end with a colon rather than beginning with one, even though these are symbols. This simplified syntax works with Ruby version 1.9 and higher. To find out which version of Ruby you have type "ruby -v" into the console.

--

#### Creating an Inventory

```ruby
def inventory
  produce = {apples: 3, oranges: 1, carrots: 12}
  produce.each do |item, quantity|
    puts "There are #{quantity} #{item} in the fridge."
  end
end
```

{% irb %}
$ frank.inventory
{% endirb %}

--

## 9. Conditionals

--

### Conditional Branching / Instructions

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

* One `if` statement whose instructions are executed only if the statement is true
* Zero or more `elsif` statements whose instructions are executed only if the statement is true
* Zero or one `else` statement whose instructions are executed if no `if` nor `elsif` statements were true

--

### Conditional Looping

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

--

### Conditional Looping

```ruby
  def countdown(counter)
    until counter == 0
      puts "The counter is #{counter}"
      counter = counter - 1
    end
    return self
  end
```

--

### Equality vs. Assignment

The #1 mistake people encounter when writing conditional statements is the difference between `=` and `==`.

* `=` is an _assignment_. It means "take what's on the right side and stick it into whatever is on the left side" -- it's _telling_, not _asking_

* `==` is a _question_. It means "is the thing on the right equal to the thing on the left?" -- it's _asking_, not _telling_

--

## 10. Nil & Nothingness

If you have three eggs, eat three eggs, then you might think you have "nothing", but in terms of eggs you have "0". Zero is something, it's a number, and it's not nothing.

`nil` is Ruby's idea of nothingness. It's usually encountered when you ask for something that doesn't exist. When looking at arrays, for instance, we created a list with five elements then asked Ruby to give us the sixth element of that list. There is no sixth element, so Ruby gave us `nil`. It isn't that there's a blank in that sixth spot (`""`), it's not a number `0`, it's nothingness -- `nil`.

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

--

#### You've Got the Vocabulary
