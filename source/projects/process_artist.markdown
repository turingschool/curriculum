---
layout: page
title: ProcessArtist
sidebar: true
---

In this project you'll use Ruby Processing to build a simple drawing program and practice object-oriented programming in Ruby.

## Goal

In the end, we'll have a Ruby Processing program which:

* Presents a blank canvas
* Sets the color of that canvas using the keyboard
* Offers several brushes switchable via keystroke
* Changes fill color via the keyboard
* Changes stroke color via the keyboard
* Changes brush size via the keyboard
* Paints with brushes via the mouse
* Erases with brushes via the keyboard + mouse
* Clears the canvas via the keyboard

We'll build the project in several iteration so we can get one piece working at a time.

## Iteration 0: Background

For this iteration, let's just focus on the background and not deal with drawing at all. By the end of the iteration, we want to be able to:

* Start the program and see the blank canvas
* Press the "b" key to activate the background feature
* Enter a color using three RGB values like "128,0,128" then enter
* See the background change to that color

### Getting Started

Let's begin with just the most basic RP sketch:

```ruby
require 'ruby-processing'
class ProcessArtist < Processing::App

  def setup
    background(0, 0, 0)
  end

  def draw
    # Do Stuff
  end
end

ProcessArtist.new(:width => 800, :height => 800,
  :title => "ProcessArtist", :full_screen => false)
```

Create a folder in your projects directory named `process_artist` and save this file in that folder with the name `process_artist.rb`.

Run it from your command prompt with `rp5 watch process_artist.rb`

Then you should see our blank black canvas.

### Reacting to the Keyboard

You already know about the special methods `setup` and `draw`, but there's another that fires when the user types keys on the keyboard. Add this method inside your sketch class:

```ruby
def key_pressed
  warn "A key was pressed! #{key.inspect}"
end
```

* Save your file and click on the running sketch window. 
* Type a few letters on the keyboard.
* Look at the command prompt where the `rp5` instruction is running and you should see lines like these:

```plain
A key was pressed! "c"
A key was pressed! "d"
A key was pressed! "e"
```

You can see that the method is firing and the `key` is a string representing the key that was pressed.

### Accepting a Command

That method get called **each** time a key is pressed. In our plan to change the background, we're expecting the user to type something like this:

```plain
b255,0,0
```

Which means "background with 255 red, 0 green, and 0 blue". Our user is going to type a bunch of keys, but our method is going to fire once for **each** key that's pressed.

#### Typing into a Queue

Try clicking on the sketch window and clicking the ENTER key. Look at the command prompt and you should see this:

```plain
A key was pressed! "\n"
```

So the ENTER key shows up to RP as `"\n"`. We know the user is "done" typing their instruction when they hit enter. If they **didn't** hit enter yet, then they must be in the middle of typing the command.

If they're still typing, we can add the current keystroke to a "queue" -- a list of the letters or numbers that they've typed so far.

When they **do** type an enter, then we can grab all the letters/numbers in the queue and figure out what to do with them.

#### An Example Queue

Here's one approach to building a queue with the letters:

```ruby
def key_pressed
  warn "A key was pressed! #{key.inspect}"
  if @queue.nil?
    @queue = ""
  end
  if key != "\n"
    @queue = @queue + key
  else
    warn "Time to run the command: #{@queue}"
    @queue = ""
  end
end
```

Save that, then go to the active sketch window and type the letters "A", "S", "D", "F", then ENTER. Over in the command prompt window you should see this:

```plain
A key was pressed! "a"
A key was pressed! "s"
A key was pressed! "d"
A key was pressed! "f"
A key was pressed! "\n"
Time to run the command: asdf
```

#### Processing the Command

When it's time to actually run the command, we need to figure out what the user was trying to do. Let's go to the active sketch window and try typing in the example input for changing the background to red:

```
b255,0,0
```

Followed by ENTER. In the command prompt you should see this:

```plain
A key was pressed! "b"
A key was pressed! "2"
A key was pressed! "5"
A key was pressed! "5"
A key was pressed! ","
A key was pressed! "0"
A key was pressed! ","
A key was pressed! "0"
A key was pressed! "\n"
Time to run the command: b255,0,0
```

In the `key_pressed` method we're not actually doing anything with the command other than printing it out. Find this part of the code:

```ruby
else
  warn "Time to run the command: #{@queue}"
  @queue = ""
end
```

Let's insert a line so it goes like this:

```ruby
else
  warn "Time to run the command: #{@queue}"
  run_command(@queue)
  @queue = ""
end
```

Which assumes you have a method named `run_command` which we don't, yet. Let's create it like this:

```ruby
def run_command(command)
  puts "Running Command #{command}"
end
```

#### Changing the Background

Now you have to figure out what goes in that `run_command` method. Here are some tips:

* The `command` variable holds a string like `"b255,0,0"
* We can use the `[]` method to get the letter at a certain position, like `command[0]`
* We can use `[]` with a range of positions to get back a bunch of letters
* We can use `.split` to break a string up into parts based on some separator
* The `.to_i` method can convert a string into an integer

#### Experiments

When it works, you should be able to change the background to...

* White with `b255,255,255`
* Purple with `b128,0,128`
* Gold with `b255,215,0`
* [Other colors whose RGB codes you can find online](http://www.tayloredmktg.com/rgb/)

## Iteration 1: A Brush

Setting the background is one thing, but now let's actually start drawing. We'd expect a brush to:

* draw a shape where we click the mouse
* have a certain shape
* have a color
* have a scalable size

Let's figure out how we can build that.

### Mouse Movements

The key methods we need from RP are...

* `mouse_pressed` - runs once when the mouse button is first pressed down
* `mouse_dragged` - runs frequently when the mouse is moved while the button is pressed
* `mouse_released` - runs once when the mouse button is released
* `mouse_x` - the current x-axis position of the mouse
* `mouse_y` - the current y-axis position of the mouse

Using those methods we can draw brush shapes around our canvas.

### An Algorithm

Let's start with this:

* When the mouse is first depressed, pick a random color and draw the first shape
* When the mouse is moved, continue drawing the shape
* When the mouse is released, stop drawing

Can you build it?

### Tips

#### Anchor Mode

By default, the shapes are drawn by anchoring the top-left corner to the specified coordinate. You can instead anchor them to the center with the following instructions:

```ruby
ellipse_mode CENTER
rect_mode CENTER
```

#### Smoothing

Are your shapes looking a bit jagged on the edges? Run the `smooth` instruction to turn on anti-alias smoothing.

#### Clearing the Screen

Use your background-changing command from the previous iteration to clear the screen.

## Iteration 2: Brush Colors, Sizes, and Shapes

Now that you've got a single brush, let's create multiple brush shapes, sizes, and colors.

### Changing Color

When your user types `f` followed by three RGB values (like `0,128,0`), change the active fill color to the color they entered.

### Changing Size

When your user types `+`, increase the size of the brush by one pixel.

When your user types `-`, decrease the size of the brush by one pixel.

### Changing Shape

Let's allow users to use five different shape brushes. They can switch brushes by typing `s1` for "shape 1" or `s2` for "shape 2". 

Create the following brushes for them:

* 1: A circle
* 2: An oval which is twice as wide as it is tall
* 3: An oval which is twice as tall as it is wide
* 4: A square
* 5: A rectangle which is four times as wide as it is tall
* 6: A rectangle which is four times as tall as it is wide
* 7: A plus sign
* 8: A clover shape (four partially overlapping circles)
* 9: A shape you imagine yourself

## Iteration 3: Erasing

Let's now work on removing content from the sketch.

### Full-Screen Clear

If a user types a `c`, clear the entire screen using the current background color.

### Erasure Brush

If the user types an `e`, enable the eraser. It works exactly like a brush, but instead of drawing with the current fill color, it draws with the background color.

### Auto-Erase

If the user types an `a`, turn on auto-erase. When they use a brush the shapes appear only while they're holding down the mouse. As soon as they let go of the mouse, clear the screen.

When they type `a` again, turn auto-erase off so they can draw normally.
