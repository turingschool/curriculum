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

## Understanding Graphics

Most computer programs you've ever used have a GUI or "Graphical User Interface". You make a GUI do things by clicking the mouse on certain buttons, boxes, shapes, etc.

### Vocabulary

We can use RP to easily create graphics we can interact with. There are just a few things you need to know up front:

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