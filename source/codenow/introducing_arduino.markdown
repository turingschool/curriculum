---
layout: page
title: Introducing Arduino
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

The led has two stiff wires that we'd prefer not to bend. The shorter one goes to the ground or negative line -- this is called the "cathode". The other, longer pin, goes to the positive line -- this is called the "annode".

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
