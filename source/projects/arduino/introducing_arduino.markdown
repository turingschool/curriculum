---
layout: page
title: Introducing Arduino & Dino
---

The Arduino is a small board which features a programmable microprocessor and several pins you can use to interact with the world.

What does that mean to you? It's a cool way to write programs which affect the physical world. In this tutorial, we'll play with some neat lights and see how the programming instructions affect what you observe.

## Fundamentals

### LEDs

An LED is a small light with two wires. When one side is connected to a positive electical source and the other to negative (or "ground"), the LED lights up.

#### Is It Dangerous?

These kids *are not dangerous*. The electrical voltage we're using here is so low that even if you intentionally tried to electrocute yourself, you probably couldn't even feel it. Don't be concerned.

#### LED Structure

It looks like this:

![LED](http://www.societyofrobots.com/images/electronics_led_diagram.png)

The led has two stiff wires that we'd prefer not to bend. The shorter one goes to the ground or negative line -- this is called the "cathode". The other, longer pin, goes to the positive line -- this is called the "anode".

### Let There Be Light! 

Let's build a simple circuit that involves no programming, just wiring.

* Find the following materials in your kit:
  * Blue Arduino board
  * Black USB cord
  * White "breadboard"
  * 1 long red wire
  * 1 long yellow wire
  * 1 red LED

With those materials, build this circuit:

* Connect the USB cord to your computer and the Arduino. You should see the small green "ON" led light up on the board.
* Put one end of the *red wire* into the hole marked *3.3V*. Be careful not to put it in *5V* or you'll burn out your LED.
* Put one end of the *yellow wire* into any of the holes marked *GND*
* Get the breadboard and rotate it so the "well", the depression through the middle, is straight up and down.
* Put the other end of the red wire in the bottom left hole of the board
* Put the other end of the yellow wire in the hold just above that (all the way to the left, one row up from the bottom)
* Take the LED and turn it so the longer wire is away from you. Put it's two wires in the holes of the breadboard four spaces to the right of the yellow and red wires. The longer end of the LED should go in the same row as the *yellow* wire, the shorter end goes in the same row as the *red* wire.
* Let there be light!

![LED](/images/circuit_01_simple_wiring.jpg)

### Time to Program

Yeah, that's cool and stuff, but you probably already have lights on in your room. What is the point of one more?

We can write programs to interact with our Arduino, controlling LEDs and reading from sensors. If you buy extra parts, you can even control motors to make things move.

### Programming Arduino with Ruby

Thanks to a collection of code written by [Austin Vance](https://github.com/austinbv/dino) we can use Ruby to interact with our Arduino.

#### Installing the Gem

We're going to use a "gem", a collection of Ruby code, to help us talk to the Arduino.

Open a Command Prompt window and type this instruction:

```
gem install dino
```

You'll see something like this:

```
Successfully installed dino-0.8
1 gem installed
Installing ri documentation for dino-0.8...
Installing RDoc documentation for dino-0.8...
```

It doesn't need to be exactly the same, the important thing is that you don't see any errors.

#### Bootstrapping

We need to load a "bootstrap" program onto the Arduino board that'll let us manipulate it from Ruby.

For CodeNow classes, we'll take care of loading this onto your boards. If you're on your own:

* Download the file from https://raw.github.com/austinbv/dino/master/src/du.ino
* Download and install the Arduino software: http://www.arduino.cc/en/Main/software
* Open the `du.ino` file in the Arduino software
* Select the port for your Arduino in the Arduino software:
  Tools => Serial Port => /dev/tty.usbmodem4111
* In the file window, at the top left, click the right-arrow-in-a-circle button for "Upload"
* Wait about a minute while the LED on the Arduino board blinks
* Once the LED is steady then it's done
* You can close the Arduino program but *keep the USB cable connected*

#### Testing the Setup

Let's try out a very small program and see if we can observe a reaction from the Arduino.

Open your text editor, probably Sublime Text, and create a new file. Add these contents to the file:

```ruby
require 'dino'

board = Dino::Board.new(Dino::TxRx.new)
led = Dino::Components::Led.new(pin: 13, board: board)

[:on, :off].cycle do |switch|
  led.send(switch)
  puts switch
  sleep 1
end
```

Save that program with the name `blink.rb` in the same directory as your other Ruby files.

##### Fire it Up

In your command prompt, change to the directory where you saved your `blink.rb`file and run it:

```
ruby blink.rb
```

In your command prompt window you should see "on" and "off" printing out over and over. Look at the Arduino board, and you should see a small LED next to pin 13 turning on for one second, then off for one second. Tada!

Hold down `Ctrl` and press `c` to stop the program.

#### Using an External LED

That was cool with the tiny LED. Let's make it work with the bigger breadboard LED.

Still have the red wire connected to your breadboard? Good. Take the other end of it, which we disconnected from the Arduino earlier, and put it into pin 13. Connect the yellow wire to any `GND` pin.

Run your Ruby program, and the LED on the breadboard should blink at the same time as the small LED on the Arduino.

{% exercise %}

#### Experimenting with Pins

Move the red wire from pin 13 to pin 11. What happens?

Stop your Ruby program and go look at the source code. Can you figure out what to change to the breadboard LED will blink while connected to pin 11? Make it work!

#### Faster Blinking

Now let's make the LED blink faster. How can you make it blink on for one tenth of a second, then off for one tenth of a second?

#### A Second LED

Add a second LED to your breadboard connected to pin 10 of the Arduino and any GND pin. Can you make it blink at the same time as the first LED?

{% endexercise %}


### Working In Ruby

With the connection made to the Arduino, we can do some neat experiments on the Ruby side and see how they affect the board/LED.

#### Big Goal

Let's create a number guessing game. When the program is running, you can type any of the numbers 0 through 9.

* If the number is too small, the lower LED will blink twice.
* If the number is too big, the upper LED will blink twice.
* If the guess is correct, both numbers blink twice.

We'll build this up piece by piece.

#### Setup the Board & LEDs

Let's cut down your Ruby program to just this:

```ruby
require 'dino'

board = Dino::Board.new(Dino::TxRx.new)
lower_led = Dino::Components::Led.new(pin: 11, board: board)
upper_led = Dino::Components::Led.new(pin: 10, board: board)
```

* The `require` line loads the Dino gem to interact with the Arduino
* The `board =` line sets up a connection to the Arduino board
* The `lower_led =` line sets up a connection to the LED on pin 11 of `board`
* The `upper_led =` line sets up a connection to the LED on pin 10 of `board`

So that's basically all setup stuff that we can leave alone. Below those four lines is where we'll write the logic of our game.

#### A Blink Method

Earlier we wrote code like this:

```ruby
[:on, :off].cycle do |switch|
  lower_led.send(switch)
  puts switch
  sleep 0.1
end
```

Let's break this down:

* The first line uses the `cycle` method to repeatedly run the block with each value in the array. The first time, `:on` gets put into the variable `switch`, then runds the three lines inside the block. Then it goes back up, stores `:off` into the variable `switch`, and runs the three lines again. Then this loop repeats over and over.

If you were to list the resulting instructions in pseudocode, it might go like this:

```
Tell the lower_led to turn on
print out the word 'on'
sleep for 0.1 seconds
tell the lower_led to turn off
print out the work 'off'
sleep for 0.1 seconds
tell the lower_led to turn on
print ut the word 'on'
sleep for 0.1 seconds
tell the lower_led to turn off
print out the work 'off'
sleep for 0.1 seconds
...repeat until the program is stopped
```

In our game we want to be able to easily blink the LEDs one or two times. Let's write a ruby *method* that can wrap those instructions up into a single instruction.

Add this to your Ruby file:

```ruby
def blink(led)
  led.send(:on)
  sleep 0.1
  led.send(:off)
  sleep 0.1
end
```

That method expects us to pass in an *argument* that is a LED object, then it'll turn the LED on, wait 0.1 seconds, then turn the LED off.

Does it work? Let's add this code below the method to test it out:

```ruby
20.times do
  blink(lower_led)
end
```

Your lower LED should blink on exactly twenty times then your program should exit.

{% exercise %}

#### Blinking with Methods

Can you modify our Ruby script so that the blinking goes like this?

* Lower LED blink
* Lower LED blink
* Upper LED blink
* Upper LED blink

And repeat that cycle five times.

After you make it work and get it checked, delete this loop.

{% endexercise %}

### Starting the Game

Here's the pseudocode structure of our game:

1. Generate a secret number between 0 and 10
2. Ask the user to input a guess
3. React to their guess using the LEDs
4. Repeat until they guess correctly

I like to add these steps to my code as comments. Here's my whole file so far:

```ruby
require 'dino'

board = Dino::Board.new(Dino::TxRx.new)
lower_led = Dino::Components::Led.new(pin: 11, board: board)
upper_led = Dino::Components::Led.new(pin: 10, board: board)

def blink(led)
  led.send(:on)
  sleep 0.1
  led.send(:off)
  sleep 0.1
end

# 1. Generate a secret number between 0 and 10
# 2. Ask the user to input a guess
# 3. React to their guess using the LEDs
# 4. Repeat until they guess correctly
```

#### Generating a Secret Number

Open up a *second* Command Prompt window and enter `irb` to run Interactive Ruby. At the prompt, try this instruction:

```irb
rand(3)
```

Observe the output. 

{% exercise %}

#### Random Numbers

Run the same instruction 10 more times (use your up arrow to avoid retyping it).

* What numbers do you get?
* What number do you *not* get that you might have expected?
* What's the lowest number you get?
* How many possible numbers are there?
* What instruction would you use to generate all the numbers zero through ten?

{% endexercise %}

Write an instruction in your Ruby file to generate a secret number and store it into a variable named `secret`.

#### Guessing

Although we really want to use the LED, at first let's just use text in Ruby to handle and react to the guessing.

Here's the pseudocode you need to implement:

```ruby
- Get a guess from the player
- While the guess is not correct, repeat...
  - Tell them that the guess is wrong
  - Ask for a new guess
```

Some bits of Ruby to help you:

* Use `gets.chomp` to allow the user to type an answer and cut off the return key
* Your `secret` is an integer, but `gets.chomp` is giving you a string. Convert the string to an integer before comparing them.
* `until (condition)`...`end` will run the block defined between `do` and a matching `end` until the condition is true.

Try it out and squash bugs until this version of your game works. Run it several times to make sure it's working!

#### How Wrong Are They?

Let's add in more information about why the guess is wrong.

After you get their guess...

* Calculate the difference between the guess and the secret
* If the guess is too low, print that it's too low
* If the guess is too high, print that it's too high
* Let them guess again

Verify that this works and get your work checked.

#### Back to LEDs

If your last version worked, let's now replace the too high or too low messages with the LED blinks.

* If the guess is too low, blink the lower LED two times
* If the guess is too high, blink the upper LED two times
* Ask for another guess

On the computer you should see no feedback from the guessing other than the request to type in a next guess.

#### Celebrate

What happens when you guess correctly? So far it just exits. Let's celbrate.

Write a method named `celebrate` that blinks both LEDs together three times.

Modify your game so that when they get the answer correct it...

* runs `celebrate` to blink the lights
* prints out a line like "You correctly guessed the secret was 6"

Sound easy? The trick here is that you'll have to pass both LEDs in as arguments to the `celebrate` method. We recommend that you:

* Make an array of both LEDs in the main game
* Pass that array into `celebrate`

Then, within `celebrate`...

* Go through `each` of the LEDs in the array
* Turn each of them on
* Sleep
* Turn each of them off
* Sleep

It'll take some experimenting. When it works, get it checked. Try an have someone else play your game!

#### How Wrong Are You?

Let's step it up a little bit and give more feedback:

* If the guess is 3 or more numbers away from the secret, blink the LED 2 times
* If the guess is closer than 3, blink the right LED 1 time

When it works, have someone else play and get it checked.

#### Expanding the Range

* Expand the random number range from 0 to 100
* Expand the blink ranges so that...
  * Within 5 blinks once
  * Within 15 blinks twice
  * More than 15 blinks three times
* Change celebrate so it does 10 really fast blinks

When it works, have someone else play and get it checked.

#### Extended Challenges

Try out these extensions on your own:

* Limit the game to only 15 guesses. If they don't get it in 10, just quit with no blinks. If they guess the number, celebrate should blink the number of chances they had left. 
* Add a third LED. Each time they guess, blink it with how many guesses they have left.

## Experimenting with Analog Sensors

LEDs are pretty cool, but let's try an experiment with an analog sensor. A digital signal, like we've been using so far, is either *on* or *off*. It's like a normal light switch.

But an analog signal can have many points inbetween. It's like a dimmer light switch. It could be full on, full off, or anywhere in between.

In your kit is a small analog sensor that looks like this:

![LED](/images/sensor_01_light.jpg)

This sensor can be used to measure light.

### Resistance

When electricity is flowing through a circuit it encounters resistance. The LEDs we've used were adding resistance to the circuit and they consumed some of the power.

If we change the resistance in a circuit we change how quickly electricity can flow. Increasing the resistance in a circuit would cause it's lights to be more dim.

The light sensor works by creating resistance in response to light. When there is a lot of light, it creates a lot of resistance. When it's dark, there's very little resistance.

We can measure the resistance going through the light sensor and get that data back to our Ruby program.

### Creating a Way-Too-Complicated Night Light

Let's build a nightlight using our Arduino.

* When there's normal light on the circuit, the LED is off.
* When it gets darker, the LED turns on.

### Building the Circuit

Understanding how/why the circuit works takes a bit more electical knowledge than we want to get into right now. Instead, let's build it and experiment.

1. If you've completed the game above, leave that circuit in place. If you didn't, wire up the LEDs following those earlier instructions.
2. Turn the breadboard so the LED wiring is at the bottom left of your view.
3. Put a blue wire into the top left pin of the breadboard.
4. Put one side of the light sensor into the pin two holes to the right of the blue wire.
5. Put the other side of the light sensor into the pin two holes to the right and one pin down from the blue wire.
6. Connect a white wire from the pin one row down from the blue wire on the breadboard and into the *A0* pin on the Arduino
7. Find a resistor that is *brown-black-orange-gold* like this one:![1K Resistor](/images/resistor_01.jpg)
8. Put the resistor so that one end is in the same row as the white wire, one pin to the right of the light sensor.
9. Put the other end of the resistor in the same row but across the "well" -- the right side of the breadboard.
10. Put a green wire in the pin one to the right of the right side of the resistor into the *5V* pin on the Arduino.

When assembled, it should look like this:

![Breadboard](/images/circuit_02_breadboard.jpg)
![Arduino](/images/circuit_02_arduino.jpg)

#### Testing it Out

We need a Ruby program to see if it's working.

1. Make sure to save any old work
2. Create a new, blank file
3. Save it with the name `nightlight.rb`
4. Add the content below

```ruby
require 'dino'

board = Dino::Board.new(Dino::TxRx.new)
sensor = Dino::Components::Sensor.new(pin: 'A0', board: board)

on_data = Proc.new do |data|
  puts data
end

sensor.when_data_received(on_data)

sleep
```

Then go to your command prompt and run the program:

```
ruby nightlight.rb
```

You should see a bunch of numbers scrolling by, mine says 62. Cover the light sensor with your hand and the number should jump up to over 150 -- mine went to 182.

If you're seeing numbers around 0 or 1000 there are problems with your circuit. Go up and work through the instructions again.

#### Reacting to the Light

Right now your nightlight has these lines:

```ruby
on_data = Proc.new do |data|
    puts data
end
```

The code between the `do` and `end` gets run each time the Arduino measures the sensor, several times per second. The variable `data` is the numeric reading.

We saw that when the circuit is not covered, `data` was around `62`. When it's covered, `data` goes up to about `182`.

Within that `do`/`end`, write Ruby code that...

* Looks at the `data`
* If it is higher than a certain number, print "It's dark"
* If it is lower than the number, print "It's light"

Watch out that `data` is a string. You probably want to convert it to an integer.

#### Activating the LED

Look back at your first project to remember the instructions for connecting to and turning on an LED.

* Add one line that will connect to the LED (look for `upper_led =`)
* Add a line that will set the LED to `:off` when it is light
* Add a line that will set the LED to `:on` when it is dark

See if you can make it work. When it's working, remove the `puts` lines from your Ruby so it just runs and changes the light without any text output.

Have someone verify your work.

#### Extensions

Here are some additional ideas to try:

##### Double-Bulb

Have you ever noticed how some cell phones actually get dimmer the darker it is outside? When it's really dark, you don't want a super bright light or it's hard to see anything else!

Make it so your nightlight:

* Has no LEDs on when it's full light
* Turns on both LEDs when it gets a little darker
* Goes down to just one LED when it's very dark

##### Slow-Off

Maybe your light shouldn't be so quick to turn off when exposed to light. Make it so when the outside light goes down, the LED(s) turn on instantly.

But, when the outside light increases, the LEDs *stay on for five seconds*.
