---
layout: page
title: Ruby Warrior Strategy Guide
sidebar: true
---

Computer programming can control the power grid, mobile phones, and maybe intergallactic satellites. But that's not how you learn to love programming.

Many programmers got into programming because of games. Let's experiment with the [Ruby Warrior tutorial](https://github.com/ryanb/ruby-warrior) by Ryan Bates to refresh and refine your Ruby programming skills.

## Setup

There are just a few short steps to get rolling.

### Install the Gem

To begin, you need the gem. Recall that a gem is a package of Ruby code that's been published to the http://rubygems.org website.

To fetch the gem, go to your Command Prompt and type:

{% terminal %}
> gem install rubywarrior
{% endterminal %}

That should fetch the gem from RubyGems and make it available in your system.

### Generate Your Project

After that installation completes you need to create a Ruby Warrior project directory. At your command prompt let's create a general projects directory then use Ruby Warrior to generate its own subfolder:

{% terminal %}
> mkdir projects
> cd projects
> rubywarrior
{% endterminal %}

Then Ruby Warrior will ask you a few questions. Let's being with the `beginner` tower and decide on your own name for your hero:

{% terminal %}
Welcome to Ruby Warrior
No rubywarrior directory found, would you like to create one? [yn] y
[1] beginner
[2] intermediate
Choose tower by typing the number: 1
Enter a name for your warrior: Me
First level has been generated. See the rubywarrior/me-beginner/README for instructions.
{% endterminal %}

### Open the Project

Now, open your text editor (like SublimeText or Notepad++) and open the `rubywarrior` so you can see and edit all the files.

Within that directory, open the `README` file.

## Level 1

The `README` file explains that on level one your character is facing down a hallway with no obstructions. In the diagram, `@` represents your character and `>` represents the stairs to the next level.

It also shows you that you can use the `warrior.walk!` instruction to move your character forward.

### Write the Code

Go over to the `player.rb` file and tell your player to walk forward:

```ruby
class Player
  def play_turn(warrior)
    warrior.walk!
  end
end
```

### Run the Code

Go back to your terminal and run the code:

{% terminal %}
> cd me-beginner
> rubywarrior
Welcome to Ruby Warrior
Starting Level 1
- turn 1 -
 --------
|@      >|
 --------
me walks forward
- turn 2 -
 --------
| @     >|
 --------
me walks forward
- turn 3 -
 --------
|  @    >|
 --------
me walks forward
- turn 4 -
 --------
|   @   >|
 --------
me walks forward
- turn 5 -
 --------
|    @  >|
 --------
me walks forward
- turn 6 -
 --------
|     @ >|
 --------
me walks forward
- turn 7 -
 --------
|      @>|
 --------
me walks forward
Success! You have found the stairs.
Level Score: 0
Time Bonus: 8
Clear Bonus: 2
Total Score: 10
Would you like to continue on to the next level? [yn] y
{% endterminal %}

Ok, it's no Call of Duty, but we've made it through the first level!

### What You Learned

* The `README` file will explain our challenges and abilities for each level
* The `play_turn` method is run by Ruby Warrior to run our instructions
* The `warrior` that's passed into `play_turn` has a method named `walk!` that moves it forward
* We execute our code by running `rubywarrior` from the command prompt

## Level 2

You survived the first level, now return to the `README` file and you'll see new instructions.

### The `README`

Sludge? Ick. If you look at the level diagram you'll see the `s` marker for sludge and the description says it has 12 HP which is short for hit points.

The level itself is still a straight hallway with stairs at the end.

At least we get some new abilities:

* `.feel` gives us back a `Space` -- but what's a `Space`?
* A `Space` has an `.empty?` method that will be true if the space in front of us is empty and false if there's something there (like **Sludge**!)
* `.attack!` attacks one space forward
* `.walk!` moves one step forward -- we already knew that

### The Plan

We should probably:

* Step forward until we can reach the sludge
* Attack it until it's dead
* Walk forward to the stairs

### Write the Code

Now you'll have to start tapping into your Ruby knowledge. Some pieces that will help you out:

```ruby
if condition
  # do something when the condition is true
else
  # do something when the condition is false
end
```

### Run the Code

Go back to your terminal and run `rubywarrior` and see if you can pass the level.

Here's the results I got:

```ruby
Success! You have found the stairs.
Level Score: 12
Time Bonus: 10
Clear Bonus: 4
Total Score: 10 + 26 = 36
Would you like to continue on to the next level? [yn] y
```

### What You Learned

* New warrior methods `.feel` and `.attack!`
* New space method `.empty?`
* How to use an `if`/`else` statement to control your warrior

## Level 3

Return to the `README` to see the next level. 

### The `README`

Four spots of sludge to defeat. You might not have noticed, but on the last level you probably lost some HPs while battling the sludge. With these four enemies on level 3, we might need to be more careful.

The `README` teaches us a few new methods:

* `.health` with our current HPs
* `.rest!` to stop and regain some HPs

### Plan #1

Let's try and just storm through and slaughter that sludge. If it doesn't work, then we'll have to go back and add in some `rest!` instructions.

### Code #1

Let's just leave it the same as level 2 and see what happens!

### Run #1

I made it through the first three sludge puddles then...

```plain
Sludge attacks forward and hits me
me takes 3 damage, -1 health power left
me dies
Sorry, you failed level 3. Change your script and try again.
```

Nooooooooooooooo!

### Plan #2

The sludge probably doesn't respect "time out". So I'm guessing that I can't rest when I'm in the middle of fighting.

Here's *pseudocode* for a plan:

```plain
if I have more than 10 HPs left
  if there's an empty spot in front of me
    move forward
  else
    attack that sludge!
  end
else
  rest up
end
```

That should help me only start attacking when I have a decent number of HPs left. Maybe we'll find out that 10 isn't enough and we need to bump it up, but let's give it a try.

### Code #2

You're going to use nested `if` statements like the plan above. Nested `if`s can get messy and hard to read, but it's a good place to start.

### Run #2

I implemented the pseudocode, ran it, and...

```ruby
Sludge attacks forward and hits me
me takes 3 damage, 0 health power left
me dies
Sorry, you failed level 3. Change your script and try again.
```

Dang! If I look back through the moves I see that the sludge was attacking me while I was trying to rest! Why?

The way I charted the logic had a flaw. If I drop below 10 HPs mid-fight, I'd stop attacking and instead start resting. That's not going to work!

Can you figure out a way to rearrange or change the logic so we can survive the level?

Here were my results, see if you can beat me on the time bonus:

```plain
Success! You have found the stairs.
Level Score: 48
Time Bonus: 7
Clear Bonus: 11
Total Score: 36 + 66 = 102
```

## Level 4

### `README`

Archers shooting arrows? I wonder how far they can shoot?

The suggestion about a `@health` variable is interesting. If we store our current health into an instance variable, then the next time the `play_turn` method is called we could compare the current health to the `@health` and figure out whether we've been attacked. How will that help us?

### Plan #1

It didn't work out on the last level, but let's just run our existing walk/rest/attack code and see what happens.

### Run #1

Uh-oh.

```plain
me receives 2 health from resting, up to 3 health
Archer shoots forward and hits me
me takes 3 damage, 0 health power left
me dies
Sorry, you failed level 4. Change your script and try again.
```

After killing the big sludge, the archer started shooting me. I was resting, but it wasn't enough to keep up with his arrows hurting me. We'll need a new plan.

### Plan #2

We should go kill that thick sludge and keep charging for the archer. Once the archer is dead then we could rest up before hitting the last thick sludge.

How would that look in code? I'm thinking...

```plain
if I'm being attacked
  attack back at them!
else
  if the next space is empty
    if my health is low
      rest
    else
      move forward
    end
  else
    attack
  end
end
```

### Run #2

I ran the code, but that archer still shot me dead. Looking back through the moves, I see that when I finished killing the first thick sludge I only had 8 HPs left.

My code realized that I was being attacked and started attacking back -- but there was still one space between me and the archer so I was attacking the air! His arrows worked, my attacks didn't.

### Plan #3

Go back to the logic. If we're being attacked we can't just attack back, we need to make sure we can reach the attacker. How does that change your code?

### Run #3

Mine didn't work! There was an error in my logic and it took me awhile to figure out what the problem was. Here are a few techniques you might use to find your own issues:

#### Use `puts`

You can use the `puts` instruction to output your own text during your turn. To help me figure out what was going wrong I used this line:

```ruby
puts "   Not being attacked, health: #{warrior.health}"
```

Remember that the `#{}` will insert the value into the output, so in my turns I saw output like this:

```plain
-- Not being attacked, health: 13
```

#### Breaking Out `being_attacked?`

There were so many `if` statements nested together I was getting confused about what matched up with what.

I decided to break some functionality into its own method. Specifically, I wanted to write a method named `being_attacked?` that would return `true` if I was being attacked and `false` if I wasn't. It would also be responsible for updating the `@health` variable I was tracking.

Here's the *pseudocode* for that method:

```plain
def being_attacked?(warrior)
  if @health is nil OR warrior health is greater than or equal to @health
    update @health with the current health
    return false
  else
    update @health with the current health
    return true
  end
end
```

#### Breaking Out `charge`

I felt that pulling out that `being_attacked?` method made things easier to read and wanted to try pulling out another method. Going back to my `play_turn` method, it starts like this...

```ruby
def play_turn(warrior)
  if being_attacked?(warrior)
    if warrior.feel.empty?
      warrior.walk!
    else
      warrior.attack!
    end
  else
    # ... other code
  end
end
```

If I'm being attacked I should charge and attack the bad guy. I remove the nested `if` and pull it out to a `charge` method like this:

```ruby
def play_turn(warrior)
  if being_attacked?(warrior)
    charge(warrior)
  else
    # ... other code
  end
end

def charge(warrior)
  if warrior.feel.empty?
    warrior.walk!
  else
    warrior.attack!
  end
end
```

I run the level again and it still passes.

#### Breaking Out `rest_or_walk`

That `play_turn` method is a little more readable now, but let's break out *one* more method named `rest_or_walk`.

Do you have an `if` statement that looks at the current health and, if it's below some threshold, rests. But if it's above the threshold, tells the warrior to `walk!`? Pull that out to a method and use it in `play_turn`.

#### Final Results

With all those methods extracted, here are the results from my run:

```plain
Success! You have found the stairs.
Level Score: 55
Time Bonus: 14
Clear Bonus: 14
Total Score: 102 + 83 = 185
```

Let's finally step up to the next level!

### What You Learned

* Nested `if` statements can be hard to write, read, and debug
* Extracting methods can help us understand and simplify our logic

## Level 5

I'm assuming that you extracted all the methods described above to help understand the `play_turn` method for this level.

### `README`

Captives sound cool, we have to be a bit more conservative about who we attack. 

* We can now call the `.captive?` method on a `Space` to see if it's a captive.  
* We can use the `.rescue!` method to save a captive.
* We shouldn't kill the captives

### The Plan

Returning to my `play_turn` method, I think the change is actually small. 

* If I'm being attacked, I still want to charge and attack
* If the space in front of me is empty, I want to either rest or walk

The last possibility is when the space in front of me is *NOT* empty. I now need to check...

```plain
if the next space is a captive
  rescue them
else
  attack that critter!
end
```

### The Code

First, I'm going to add that new nested if statement right in `play_turn` and see if I can pass the level.

If that works, then I want to extract it to a `rescue_or_attack` method.

### The Run

Hooray, it worked on the first try! I then extracted the `rescue_or_attack` method, ran it again, and got these results:

```plain
Success! You have found the stairs.
Level Score: 78
Time Bonus: 19
Clear Bonus: 19
Total Score: 185 + 116 = 301
```

## Level 6

### `README`

Look closely at the level diagram and you'll see there's a captive behind us. That's interesting.

It notes that we can pass `:backward` as an argument to `walk!`, `feel`, `rescue!` and `attack!` which would look like `walk!(:backward)`.

### Plan #1

For this level, I want to:

* Walk backward until I see a captive, then rescue them
* Go forward and attack/rest as I have before

Doesn't sound too hard, right? There's a little wrinkle here. I need to manage some **state**. The state of a program is how you keep track of what things have already happened.

In this level, I need to go backwards and try to rescue a captive until I rescue one. Then I can go forward and kill. 

My first idea is to track a `@captives_rescued` instance variable that I'll start at `0` and increase when I rescue someone. If the value is `0`, I know I need to be working backwards. If it's greater than `0`, it's killing time.

### Code #1

Here's ruby code for a `captives_rescued?` method:

```ruby
def captives_rescued?
  if @captives_rescued.nil?
    @captives_rescued = 0
  end
  if @captives_rescued > 0
    return true
  else
    return false
  end
end
```

**NOTE:** That method can be shortened to just two lines of code if you're slick :)

Now, back in the `play_turn`, I'm going to implement something like this:

```plain
if no captives have been rescued
  if feeling backwards finds a captive
    rescue them
    increase the number of captives I've rescued
  else
    move backwards
  end
else
  all the other code about being attacked, charging, etc
end
```

### Run #1

The part about rescuing the captive then moving forward went fine, but I still died. I read through the turns and see that, when I kill the thick sludge, I have only 8 HPs left.

I then take a rest before charging, but the archers start shooting me. I can't kill them fast enough while they're shooting me, and I die.

### Plan #2

I can see that the archers only start attacking once the giant sludge is dead. If there's no obstruction, I'm not sure if they can attack across the whole level or only across two spaces.

I'm thinking that I need to change my `being_attacked?`/`charge` logic. Maybe if I'm being attacked and my health is below some threshold, I should retreat and rest up. Here's my idea in pseudocode:

```plain
if I'm being_attacked? 
  if my health is low
    move backwards
  else
    charge
  end
else
  rest, walk, rescue or attack
end
```

I really only have to add the nested `if` statement for the `if my health is low`, the rest is already there.

### Run #2

I implemented the logic and ran it, but got to a problem. Once the sludge was dead, the archers attacked me. I backed up, rested for a turn, then charged. They attacked, my health got low, so I retreated and rested again.

I was in an infinite loop because my threshold of "how low do I need to be to rest" and "when should I stop resting" were the same.

I stopped the program by pressing `Control-c` and changed the thresholds so that I'd get to a higher health before moving forward and lowered the retreat threshold.

By tweaking those values a few times I ended up with these results:

```plain
Success! You have found the stairs.
Level Score: 58
Time Bonus: 14
Clear Bonus: 14
Total Score: 301 + 86 = 387
```

FYI, I had to retreat after killing the sludge, then again after killing the first archer.

## Level 7

### `README`

The level itself looks simple, except that we need to turn around first.

### The Plan

Let's check for a wall first, and if it's found, turn around. We can remove (or maybe comment-out) the bits about `captives_rescued`.

Then just run our existing strategy.

### The Code

This one is up to you!

### The Run

Mine passed on the first try:

```plain
Success! You have found the stairs.
Level Score: 31
Time Bonus: 4
Clear Bonus: 7
Total Score: 387 + 42 = 429
```

### Refactorings

That `play_turn` method is getting big again. Let's extract a few methods.

### `charge_or_retreat`

I extracted a method that gets run when the warrior is being attacked which causes him to either retreat or charge.

### `move_or_interact`

I extracted a method that is run when the warrior is NOT being attacked which checks whether the next space is empty and either rests, walks, rescues, or attacks.
