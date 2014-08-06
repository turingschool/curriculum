---
layout: page
title: Ruby Debugging
section: Debugging
sidebar: true
---

When our software doesn't do what it is supposed to, we call this a bug.
The most famous example of this is when Navy Admiral Grace Hopper,
famous for developing the first compiler, was working on a computer at
Harvard in 1947. Computers back then were large and mechanical, and this
computer was acting up. We might say it was being "buggy". Now, no one wants
their computer acting buggy, so we try to fix bugs when we find them. This
is called "debugging", and is the point of this lesson.

When she went to investigate, to her surprise, the cause of the bug was...
a bug! A moth was trapped between the points in a relay. She removed the moth,
debugging the computer.

Since the military requires you to log goddamn everything (yeah, I'm a veteran),
she taped it into the log with the caption "First actual case of bug being found."

![Computer Bug](/images/first-computer-bug.jpg)

## Before The Bug

Before you even get to the point of debugging, there are a number of things
you can do. These will reduce the likelihood of bugs occurring, and will
make them easier to find once you identify that you do, in fact, have a bug.

### Code in Small Steps

If you write a page of code and then go run it, you have an entire page of
possible places there are errors. If you instead code in small steps, and verify
that those pieces are working before moving on, then you will catch errors
as you make them, and will only have a small section of new code that to
worry about.

Probably the bug is in the small piece of new code.

### Commit Your Code Often

When you play a difficult game, you save often.
That way, when you inevitably die, you don't lose much progress.
Source control works the same way.

In addition, if you commit often, you can run `git diff` to see what code was
changed. Making it a lot easier to know where you need to go to find the problem.

### Verify Assumptions

You need to take things from the unknown to the known.
In the code `choice == 5`, maybe you think the input is the number 5,
because you just entered it on the console.
This means the comparison should be true. Verify that this is the case.
Maybe it turns out that it is actually the string "5\n", because
it was entered by a user on the console, so there is no way for
the comparison to ever return true.

This allows you rule out pieces of code, knowing that they do what you think
they should be doing, and allowing you to move beyond that, to other places
the bug potentially exists.

> when faced with a "surprising" failure, you must realize that one or more
> of your assumptions is wrong.
>
> http://pragmatictips.com/27

We'll talk about how to verify in the tools section below.

### Prefer Setters and Getters Over Instance Variables

Here, we set the wrong ivar, but we don't find out about it
until we try to do something with gas, later. Now we've pushed
the problem out into some other piece of code that is using gas,
causing us to look in the wrong place when trying to fix it.

```ruby
class Car
  attr_reader :gas
  def initialize(gas)
    @gass = gas
  end
end
Car.new(10).gas # => nil
```

When we invoke the setter, though, we are immediately told of our error,
at the place that it is introduced.

```ruby
class Car
  attr_accessor :gas
  def initialize(gas)
    self.gass = gas # ~> NoMethodError: undefined method `gass=' for #<Car:0x007fa4b28d4128>
  end
end
Car.new(10).gas
```

### Use Parentheses When You're Not Sure Of Order

```ruby
true || (false && false)  # => true
(true || false) && false  # => false
true || false && false    # => ??
```

Even though you can easily enough check this, as I present it this way,
just imagine that last line sitting in the middle of a bunch of other code,
it's a lot harder to figure out what it's doing.

Further, it could introduce errors as a colleague could read it and assume
it interprets the other way, and then misinterpret how this code behaves.

### Structure Programs so They are Easier to Reason About

Objects talk to objects they create. They manage the objects **below** them.
Generally avoid letting them go talk to any random thing out there in the system.
So avoid global variables, avoid singleton objects (objects for which there
is only one instance), strongly avoid mutating objects that were passed in
as arguments. Calculate a value instead, and let the caller do the mutation.
Avoid passing instances of self, don't let objects you talk to talk back to you.

Each object is a silo, knowing only about itself and the things beneath it.
Avoid giving it things that let it mess with the world above it.

Then you can take each piece in isolation, and make sure that it works
without having to worry about the rest of the system.

Example: A CommandLineInterface might instantiate a MasterMind into a game variable, the game should not
know that it is being run in a command-line interface, it should not
be able to kick off "play again", or that users entering "b"
(simply because its convenient for a CLI) correspond to the beginner
difficulty setting. That's all above it, it just knows about game things.
And the CLI translates the users inputs into what the game needs,
and chooses when to start new games based on the context that **it**
decides.

Here is a hypothetical separation of CLI and MasterMind.
Notice that the game provides all the methods the CLI needs to make the decisions,
it implements the game logic, but it leaves it up to the CLI to actually make those decisions:

```
MasterMind
  initialize
    secret  = ...
    guesses = []
  add_guess(guess)
  over?
  player_won?
  player_lost?
  valid_guess?(guess)
  num_guesses_so_far
  correct_colors(guess)
  correct_positions(guess)

class CLI
  def play_game
    game = MasterMind.new
    until game.over?
      guess = get_guess(game) # get_guess uses game.valid_guess? and returns something like "RRYB"
      game.add_guess guess
      if game.won?
        puts ":)"
      elsif game.lost?
        puts ":("
      else
        puts "You got #{game.correct_colors guess} colors correct ..."
      end
    end
    puts game_over_message(game)
  end
end
```

Given this structure, how do we play a second game?
Well, whoever called `play_game` will prompt to see if they want to play another,
and if they do, will call `play_game` a second time.


### Avoid Mutable Objects

Objects are mutable if their state can be changed by other objects.
State is just the data stored in your variables.

Here, we expose methods that change the internal data.
If some other piece of code doesn't consider that we're using this objet,
it might call one of these methods to prepare the object for the new use case.

```ruby
class Sequence
  def compare(guess)
    @sequence == guess
  end

  def use_beginner
    @sequence = ['a', 'b', 'c'] # hypothetical random sequence
  end

  def use_expert
    @sequence = ['a', 'b', 'c', 'd']
  end
end

beginner_sequence = Sequence.new
beginner_sequence.use_beginner

expert_sequence = beginner_sequence # <-- expert_sequence is using the same object as the beginner
expert_sequence.use_expert

beginner_sequence.compare ['a', 'b', 'c'] # => false
```

Instead, that code should create its own instance with its own state.
It shouldn't change the state of our variables. And we should avoid having
code that can be misused in this way.

```ruby
class Sequence
  def initialize(skill_level)
    case skill_level
    when :beginner then use_beginner
    when :expert   then use_expert
    else raise "No #{skill_level.inspect} skill level!"
    end
  end

  def compare(guess)
    @sequence == guess
  end

  private

  def use_beginner
    @sequence = ['a', 'b', 'c']
  end

  def use_expert
    @sequence = ['x', 'a', 'i', 'l', 'q']
  end
end

beginner_sequence = Sequence.new :beginner
expert_sequence   = Sequence.new :expert

beginner_sequence.compare ['a', 'b', 'c']
# => true
```

### Don't Propagate Incorrectness

As in the example of the incorrect instance variable above,
[crashing early](http://pragmatictips.com/32), allows you to be as close
to the problem as possible when something goes wrong.

Who wants to read a stack trace, and then consider all the things that
might have gone wrong before this point in order to incorrectly arrive here?

Ever look at a piece of code that was initialized with a wrong value?
That means something else somewhere else was wrong, and instead of complaining
about it there, it let the wrongness infect the piece of code you're looking
at. Now you have to go find who was talking to this code in order to debug it.
Avoid this by crashing early when things are known to be wrong.

Validate inputs at the boundaries of the system, where they enter the system,
so that you can operate under the assumption that data within the system is
correct, and don't have to compensate for potentially bad data in every method
that receives an argument.

## Thinking About It

### Is It Actually a Bug?

Something might not be doing what you expect. That doesn't mean it's a bug.

If it's in the stdlib, make sure you understand it by reading the docs
and playing around with it in isolation.

If it's code you wrote, make sure you understand the requirements on it.

Read the tests written around it, you may find that it explicitly decided
that this code should behave in this way.

Maybe you're just using it wrong, make sure this isn't actually how the system
is supposed to behave.

### Get Feedback

The core of debugging is finding where something either isn't or doesn't do
what you expect. The only way to do this is to check at different points what
is going on in that code. To do this, you must get feedback.

All the "Before the Bug" steps are about preventing your expectations from
being violated. But the debugging tools are all about giving you the feedback
you need to see that something isn't what you thought it was.

To debug well, you need to ruthlessly get feedback from the system. Feedback
that answers specific questions, and feedback that exposes the context
that the code is running in, so you can see "wait, that doesn't feel right"
or "oh, this clearly won't work, what assumption am I making that led to this?"

**The first place to get feedback is to read the error message.**

### Think About What Can Cause These Issues

When you experience a bug, consider what could cause that sort of issue.
Typically, something associated with it will cause it. You don't expect
things way off on the other side of the interpreter to be the cause.

For example, after we installed [Seeing is Believing][sib] into Corey's
atom editor, he found that the editor was not working. Not only did Seeing
is Believing not work, but when he'd load a new window, many things in the
editor were messed up.

Given that the steps we followed were:

* Create an rvm wrapper for a specific version of Ruby
* Install Seeing is Believing on that Ruby
* Add settings to Atom's configuration file telling it to use our custom Ruby when running Seeing is Believing
* Download the Seeing Is Believing plugin for Atom

I had no clue what was wrong with the editor, but I immediately guessed
where the problem was, and upon looking at it for a moment, was able to
see the problem.

Where was the problem? Only two of these touch Atom, and of those two, one
is right in the middle of a bunch of other Atom stuff.

### Understand The Cause, Don't Just Fix The Symptoms

> Beware of myopia when debugging. Resist the urge to fix just the symptoms
> you see: it is more likely that the actual fault may be several steps removed
> from what you are observing, and may involve a number of other related things.
> Always try to discover the root cause of a problem, not just this particular
> appearance of it.
>
> http://pragmatictips.com/25

```ruby
def add5(n)
  n + 5 # ~> TypeError: no implicit conversion of Fixnum into String
end

def add6(n)
  n + 6
end

print "Enter a number: "
n = gets
add5 '5'
```

When debugging why `add5` failed, don't fix the value of `n` in `add5`,
because then the bug still exists for `add6`. Go fix it at the source,
and stop propagating incorrectness.

If you keep tripping and skinning your knee, the solution isn't to put on knee
pads, it's to get shoes that fit.





## Finding where it is wrong

### The Problem is in *your* Code

> Remember, if you see hoof prints, think horses—not zebras.
> The OS is probably not broken. And the database is probably just fine.
> It is rare to find a bug in the OS or the compiler, or even a third-party
> product or library. The bug is most likely in the application.
>
> http://pragmatictips.com/26

Don't waste your time debugging your tools until you are *very* confident
that the bug isn't in the code you wrote.

Rails has been downloaded [over 36 million times](http://rubygems.org/gems/rails).
If there's an issue, it's safe to assume that someone else found and fixed it
in those [15,000+](https://github.com/rails/rails/issues?page=1&state=closed)
issues.

The bug is in your code that you wrote.

### Follow the Backtrace

In the same way you need to read the error message, you should also follow
the backtrace. Where does it enter your code? This is where to begin.
Who called it before that?

### What Did You Most Recently Change?

If you are working in small steps, then the thing you most recently changed
is probably the thing that introduced the bug. Go there and look at that code.

If it's not there, then it probably exposed a bug that already existed,
but wasn't showing itself. Go look at the code that it's talking to, validate
that this code works

### Binary Search

No idea where the problem is? It could be early in the execution of the code
or late? Come from anywhere? Use a binary search.

Split the code in half, verify something halfway through. If it's 10 lines
of code, check that everything looks good at line 5. If it does, the problem
is in the last 5 lines of code, if not, it's in the first 5. You just cut
the problem space in half. Do it again. And again, narrowing the space in
half each time. Eventually, you'll hone in on your bug.

Is it an iterative thing that becomes wrong at some point?
Check that it looks good after half the iterations, and then half again, etc.


### Follow the Code Down

You don't know where the bug is, what happened up to this point,
what was passed in, etc. So start at the top, what's the first thing that happens
go there, figure out what that is doing. What happens beneath it?
Figure out which of those is wrong (binary search),
then go down there. Repeat this process until you find the thing where things went wrong,
and why they went wrong.

[Here](https://github.com/pry/pry/issues/1277#issuecomment-50979838)
is a more extreme example, where I documented everywhere I went.
I actually started above this, at the binary to figure out that this is
the top of where pry reads in data and does things with it.

### Extract And Validate Small Ideas

Have a big piece of code that you're pretty much able to reason about,
but there's one small chunk in there that you're not sure about?

Take that small chunk out and make sure you understand it independently
of the context that it is being evaluated in.

For example, [this code](https://github.com/JoshCheek/seeing_is_believing/blob/b9fef0a564eb44412ff34b0e1b7c2cca8828c987/lib/seeing_is_believing/binary/align_line.rb)
has a lot of context necessary to see if it works.
However, we can pull the body of that `line_lengths` method out
and make sure it's doing what we expect, independent of the rest of the code:

```ruby
body = "1
12
123
1
1234"

Hash[ body.each_line
          .map(&:chomp)
          .each
          .with_index(1)
          .map { |line, index| [index, line.length+2] }
    ]
# => {1=>3, 2=>4, 3=>5, 4=>3, 5=>6}
```

This is where tools like [Seeing Is Believing][sib] shine.
We'll talk about some of them below.


### Common Bug Types

Here are some common bug types and how to interpret them.

#### Setters vs Local Variables
When invoking a setter on self, objects need to use `self.setter = value`
rather than `setter = value`, otherwise the interpreter thinks you're
wanting to create a local variable.

#### TypeError "not a module/class"

You created a constant as a class or module, then reopened it as the other.

```ruby
class A
end

module A  # ~> TypeError: A is not a module
end
```

#### ArgumentError "wrong number of arguments"

You invoked a method, passing it too many arguments or too few.
Look at the backtrace to find the method and the invocation.

```ruby
def meth(arg)  # ~> ArgumentError: wrong number of arguments (2 for 1)
end
meth 1, 2
```

#### KeyError

You tried to access a hash key that doesn't exist.

```ruby
hash = {a: 1}
hash.fetch :a  # => 1
hash.fetch :b  # ~> KeyError: key not found: :b
```

#### SyntaxError your file is syntactically invalid

Use a binary search, commenting out half the lines and running
`ruby -c filename.rb` to see if it is still invalid. If so,
the error is in the invalid half.

Sometimes you can't directly comment half the lines, but the concept
of ruling out chunks of code is still valid.

```ruby
"ab
# ~> -:1: unterminated string meets end of file
```

#### LoadError

You're trying to load a file that it can't find.

Common reasons are that the name is misspelled,
at a different location than you think,
does not have it's directory in the `$LOAD_PATH`,
or is part of a gem that isn't installed.

```ruby
require 'zomg'  # ~> LoadError: cannot load such file -- zomg
```

#### NameError "uninitialized constant"

You misspelled the name of a constant, or the namespacing is wrong.

```ruby
class User
end
Usr # ~> NameError: uninitialized constant Usr
```

#### NoMethodError "undefined method ..."

You are accessing a method or a local variable, and Ruby can't find it.

Check your spelling, and that order of lines is correct.

```ruby
class A
  attr_accesor :b  # ~> NoMethodError: undefined method `attr_accesor' for A:Class
end
```

#### ZeroDivisionError

Often this comes from getting numbers out of empty collections.

```ruby
grades     = []
sum        = grades.inject(0, :+)
num_grades = grades.size
average = sum / num_grades
# ~> ZeroDivisionError: divided by 0
```




## Tools


### Git

#### diff

What have I changed? (likely places things went wrong)

#### blame

When was this line changed? What was the commit, who did it?
Now you can go investigate that context
(e.g. get the SHA and pass it to `git show`)

#### show

Show the commit message and files changed.

#### log path/to/file

Show commits that changed this file

#### bisect

Git will perform a binary search, finding the exact commit
that the problem was introduced.


### Print Statements

The most general purpose way of getting the feedback you need to figure out
where your program is wrong is a print statement. This works in nealry every
language, and doesn't require knowledge of any fancy tools.

Wherever you want something, print it out. In Ruby, you can call `inspect`
on an object to get a representation that reveals information about its type.

Here, we figure out that n is coming in as a String by printing its
inspection just before the error.

```ruby
n = gets
puts "n = #{n.inspect}"
n + 5 # ~> TypeError: no implicit conversion of Fixnum into String

# >> n = "5\n"
```

Here, we figure out which branch was evaluated.
```ruby
def set_back_to_initial_conditions
  if @was_backed_up
    puts "RESTORING BACKUP"
    FileUtils.mv temp_filename, filename
  else
    puts "DELETING TEMP FILE"
    FileUtils.rm filename
  end
end
```

### Assertions

You can validate your assumptions by adding assertions. Making sure that
the code is executing in the context you are expecting

While working on [Turing's](http://turing.io/) Enrollment application,
I wound up with a lot of bugs that, as I traced them, were due to
the seed data being wrong after I added database cleaning. So I added
assertions around the code that did the cleaning:

```ruby
module Test
  module Support
    module CleanDatabase
      def setup
        super
        DatabaseCleaner.start
      end

      def teardown
        super
        raise "Database is not seeded!" if PaymentPlan.count.zero?
        DatabaseCleaner.clean
        raise "Database cleaning strategy deleted seed data!" if PaymentPlan.count.zero?
      end
    end
  end
end
```

> Assertions validate your assumptions.
> Use them to protect your code from an uncertain world.
>
> http://pragmatictips.com/33


### Tests

Use tests to show your does what you think,
and to notify you as soon as you make a change that breaks this expectation.

Think of tests as pre-defined debugging that you can run in an instant.

If you have a bug, that's a reason to write a test, then you'll make sure
that this problem isn't re-introduced. It also implies that the testing
may be spotty in this area, so this is a place you could stand to buff up
your test coverage.

### Pry

Pry is a REPL like IRB. But it's just generally better in every way.

Aside from the obvious, that it handles syntax much better, you can also
use it like a debugger.

You can drop pry into the middle of any piece of running code (e.g. a Rails
  controller), and it will load you into a REPL.

```ruby
def add5(n)
  require 'pry'
  binding.pry
  n + 5
end
```

Now call that code, and you'll see you're at a prompt

```ruby
    1: def add5(n)
    2:   require 'pry'
 => 3:   binding.pry
    4:   n + 5
    5: end

[1] pry(main)> n
=> "5\n"
```

Useful commands:

* `help`        - See what commands you can run
* `cd obj`      - Change context into obj (sets self to that object)
* `cd ..`       - Change context back out of that object.
* `ls -v`       - Show all the methods and variables on self
* `ls -v obj`   - Show all the methods and variables on other objects
* `whereami`    - Show code surrounding the current context.
* `!`           - Clear the input buffer, use when you typed something incorrectly and want to get out of it
* `edit`        - Allows you to edit code without rerunning the program. I use it to put another pry into a method that I'm about to call.
* `show-source` - Show the source for a method or class. SUPER USEFUL!!
* `nesting`     - Display the list of `cd`s you've gone down
* `exit`        - Quit out of current pry session. [`C-D`](readline-notation) also works.

Both the `edit` and `show-source` commands can be done like this: `some_object.some_method` in which case,
pry will operate on the method named `some_method` of the object named `some_object. Or, if you don't
have access to an instance, you can do `SomeClass#some_method`, in which case it will operate on
the instance method `some_method` of the class `SomeClass`.

### Seeing Is Believing

Seeing Is Believing is greate for extracting and verifying small steps.
It's in your editor, so its easier to work with, you can change a line
anywhere and then re-run it.

[sib]:               https://github.com/JoshCheek/seeing_is_believing
[readline-notation]: https://www.gnu.org/software/bash/manual/html_node/Introduction-and-Notation.html#Introduction-and-Notation
