---
layout: page
title: Getting Started with Ruby-Processing
---

Ruby-Processing is an awesome and simple framework for creating graphics with Ruby. It is built upon libraries from the [Processing](http://processing.org) framework which uses the Java programming language. Ruby-Processing uses a library named JRuby to allow us to interact with the Java components from Ruby -- so no Java knowledge is required!

For the rest of this tutorial, we'll use "RP" to refer to Ruby-Processing.

## Setup

The first thing to do is get RP running on your machine. From a command prompt window:

{% terminal %}
> gem install ruby-processing
{% endterminal %}

It'll take a few minutes to install because RP is a big library. You can continue reading ahead while it's running.

### Setup Java on Windows

* Download and run the Java installer: http://java.com/en/download/index.jsp
* Add Java to the path: http://java-buddy.blogspot.com/2012/01/set-path-for-jdk-7-on-windows-8.html

Verify it's installed by opening a new command prompt and typing `java -version`

## Understanding Graphics

Most computer programs you've ever used have a GUI or "Graphical User Interface". You make a GUI do things by clicking the mouse on certain buttons, boxes, shapes, etc.

### Vocabulary

We can use RP to easily create graphics we can interact with. There are just a few things you need to know up front:

#### Sketch

An RP program is called a "sketch". It's just made up of Ruby code like any other Ruby program.

#### Window

A graphical program runs in a *window* or an area of the screen with a certain *width* (left-to-right) and *height* (top-to-bottom).

#### Pixels

The space inside a window is made up of *pixels*. A pixel is a super-tiny square of color. Your entire computer screen is made up of over a million pixels. Using RP, we can control the color of each square individually -- allowing us to draw and animate shapes.

#### Coordinates

We can specify any pixel in the window with coordinates, usually referred to as "X" and "Y". They work pretty much like the coordinates you've used in math class, but in graphics the "origin" `(0,0)` is the *top left corner*.

Positive numbers for X go out from the top left towards the right.

Positive number for Y go **down** from the top towards the bottom.

#### Shapes

A collection of pixels that, when colored together, look like a shape like a circle, square, etc.

#### Stroke

A shape can have *stroke* which is another word for outline. That stroke can have both a color and a weight. 

The weight defines how many pixels wide the stroke is. If you drew a line that was 5 pixels long with a stroke weight of 1 pixel, then in total the line takes up 5 pixels.

If, however, you drew a line 5 pixels long with a 10 pixel stroke width, you'd see more of a rectangle that's 5 pixels by 10 pixels, a total of 50 pixels.

#### Fill

The area inside a shape's stroke can be colored and is called the *fill*. Often the fill will be a solid color, but can also have an alpha value.

#### Alpha Value or Transparency

Shapes can overlap each other. Most of the time, the colors used for the stroke and fill are totally opaque -- they completely block out any shape/color below them.

But when we use an Alpha value (also called transparency), we can allow the colors to mix together. If the top shape's transparency is set to 50%, then what you see on the screen will be a mix of 50% the top shape and 50% the bottom shape.

If this is confusing right now, it'll make more sense later when you play with it.

#### Colors

When we specify colors in RP, we typically use three numbers called an RGB set. The first number represents Red (0-255), the second is Green (0-255), and the third is Blue (0-255). So a few examples:

* `0, 0, 255` is pure blue
* `128, 0, 128` is half red and half blue, giving purple
* `255, 255, 255` is all the colors maximized which is white

## A First Sketch

Let's get going with a first sketch with a couple shapes.

### Create the File

* Create a directory in your projects directory named `processing-getting-started`
* Open your text editor
* Create a file named `first_sketch.rb` and save it in that `processing-getting-started` directory

### Add Instructions to the File

Add the following to your `first_sketch.rb` file:

```ruby
require 'ruby-processing'
class FirstSketch < Processing::App

  def setup
    background(0, 0, 0)
  end

  def draw
    fill(255, 0, 0)
    rect(10, 10, 60, 30)
  end
end

FirstSketch.new(:width => 200, :height => 200,
  :title => "FirstSketch", :full_screen => false)
```

### Run the Sketch

* In your command prompt window, change into the `processing-getting-started` directory using the `cd` command
* Run the program with `rp5 run first_sketch.rb`

### Observe

You should see:

* A white window appear
* A red rectangle appear within that window

### Inspect

Now let's dig into the program and figure out what we've got.

#### `class FirstSketch < Processing::App`

We're defining a class named `FirstSketch` and it *inherits from* the class named `Processing::App`. Whatever the `Processing::App` class can do, our class gets for "free".

This is how our program is able to use all the RP instructions because they're defined in the `Processing::App` class.

#### `FirstSketch.new`

The very last line of the file, we're calling the `new` method on `FirstSketch`. The instructions above only defined what the sketch would do, but it didn't actually make it **go**.

This instruction actually runs the sketch.

#### `setup` method

This special method is run once when the sketch is initialized. In this `setup` all we've done is set the background of the window to `0, 0, 0`. 

#### `draw` method

RP will run the draw method **over and over** while the sketch is running. In our current method, we have:

```ruby
def draw
  fill(255, 0, 0)
  rect(10, 10, 60, 30)
end
```

The `fill` method sets the current fill color to full red, then the `rect` method creates a rectangle at the coordinates `10,10` that is `60` wide and `30` tall.

You can't really tell that this method is running over and over since it's just re-drawing the same rectangle at the same size in the same spot.

### What You've Seen

* An RP program is called a "Sketch"
* A Sketch is a class that inherits from Processing::App
* It defines a `setup` method that's run once at startup
* It defines a `draw` method that's run over-and-over

## Adding Animation

What is animation? It's a _drawing that changes over time_.

In a RP sketch the draw method is called over an over. If the second time it's called the data is different than the first time, then the image will change.

### Animating Size

Let's revisit the previous sketch. We currently have this `draw` method:

```ruby
def draw
  fill(255, 255, 255)
  rect(10, 10, 60, 30)
end
```

Let's replace it with the following:

```ruby
def draw
  if @size.nil? || @size == 150
    @size = 1
  else
    @size = @size + 1
  end

  fill(255, 255, 255)
  rect(10, 10, @size, @size)
end
```

#### See the Results

Run `rp5 run first_sketch.rb` and you should see...

* A black background
* A white square slowly grow towards the bottom right
* More squares draw over the existing square

#### Improvise

Using a similar technique, can you...

* Animate the color go from white to pure red?
* Draw two rectangles within the same window that don't overlap
* Inject some randomness with `rand` (ex: `rand(255)` gives you a random value between 0 and 255)