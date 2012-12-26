---
layout: page
title: Metro - Getting Started
sidebar: true
---

## What is Metro?

Metro is a framework built around [Gosu](http://www.libgosu.org/). The goal of Metro is to make it fun and easy for Ruby developers to make games. It does this by codifying several common 2D gaming concepts, relying on convention over configuration, and removing the tedium of common tasks.

{% archive jumpstartlab@metro_gaming_tutorial setup Download this Code! %}
This contains the directory structure and files required to get started with Metro. Or you can [view it on GitHub](https://github.com/JumpstartLab/metro_gaming_tutorial).
{% endarchive %}

&nbsp;

{% terminal %}
$ cd metro_gaming_tutorial
$ bundle install
Fetching gem metadata from http://rubygems.org/.
Fetching full source index from http://rubygems.org/
Installing gosu (0.7.45)
Installing metro (0.0.6)
Using bundler (1.2.1)
Your bundle is complete! Use `bundle show [gemname]` to see where a bundled gem is installed.
{% endterminal %}

### What you are making?

By the end of this tutorial you will build a game title screen that will allow a player to start or exit the game.

![Title Screen With Menu](title-screen-with-menu.png)

## I0: Running Metro

Every metro game has a file that contains details about the game, by default that file is named `metro`.

The metro file is a Ruby file that is interpreted within a context where there are few special commands available including:

* `name 'game_title'` &emdash; The title of the game.
* `resolution width, height` &emdash; The resolution at which the game. When this is not specified it will default to 640x480.
* `first_scene 'scene_name'` &emdash; When the game starts it opens with a particular scene. This is where you will specify the starting scene. At this moment we do not have any scenes, so we can leave this value blank.

{% codesample github jumpstartlab@metro_gaming_tutorial 4dc03c622230d50296af9a410f90a5447f882c7d:metro %}

Without a first scene the game will not be able to start, generating an error message like this:

{% terminal %}
$ metro
E, [2012-10-21T21:21:03.770270 #69759] ERROR -- : Could not find scene with name ''
Known scenes:
/Users/burtlo/.rvm/gems/ruby-1.9.3-p194@jumpstartlab/gems/metro-0.0.6/lib/metro/scenes.rb:53:in `generate': undefined method `new' for nil:NilClass (NoMethodError)
{% endterminal %}

{% exercise %}
### Exercise

* Create a `metro` file that sets the name and resolution for your game.
{% endexercise %}

&nbsp;

## I1: Title Screen

Let's create a title scene so our game will start properly. It should:

* Show the title of our game
* Allow the user to exit the game

That is not hours and hours of fun, but it is a simple step to get us started.

### Creating a Scene

A *Scene* is one of three major concepts in Metro. A scene represents screens, transitions, or stages within the game. A Scene itself coordinates the many actors, events, animations, and actions that are currently on screen.

A Scene is similar to a [Rails Controller](http://guides.rubyonrails.org/action_controller_overview.html#what-does-a-controller-do).

Scenes are stored in the `scenes` subdirectory and are subclasses of [Metro::Scene](http://rubydoc.info/gems/metro/Metro/Scene).

{% codesample github jumpstartlab@metro_gaming_tutorial a5954ff:scenes/title_scene.rb %}

Our first scene does not do anything, but it exists and if we update our `metro` file with the name of our title scene, we will see some progress.

{% codesample github jumpstartlab@metro_gaming_tutorial a5954ff:metro %}

Running metro now will welcome us with a black window with the title we provided at the size we provided.

![Title Screen Blank](title-screen-blank.png)

### Adding a Title

Now it is time add a title within the scene. We want to draw the title text in the upper left corner of the title screen.

The title text is a kind of *actor* in Metro &emdash; an object within the scene. `Scene` has a class method named [draw](http://rubydoc.info/gems/metro/Metro/Scene#draw-class_method) which takes a name for our actor and a number of properies including:

* `text` &emdash; The text to write for the title
* x, y, and z-order &emdash; The x and y position place it on the screen. The coordinate spaces starts from the top-left of the window. The z-order specifies where it should be in the drawing stack; lower allows it to be overlapped, higher means it would overlap other objects.
* x-factor, y-factor &emdash; The scale to increase/decrease the size of an item.
* color &emdash; The color value is represented as a hex value formatted as `0x|alpha|red|green|blue`. So white would be `0xffffffff`, grey `0xff777777`, black `0xff000000`, or a translucent red `0x77ff0000`.
* model &emdash; The model describes how all these attributes should be drawn. Metro provides some basic model objects to take care of some of the repetitive drawing (e.g. labels, images, and menus) for you. You would use: "metro::models::label"; "metro::models::image"; "metro::models::menu".

{% codesample github jumpstartlab@metro_gaming_tutorial ac91b97:scenes/title_scene.rb %}

Run the game again and you should see our new title drawn onto the screen.

{% terminal %}
$ metro
{% endterminal %}

![Title Screen With Title](title-screen-with-title.png)

{% exercise %}
### Exercise

* Experiment with the x, y, x-factor, and y-factor to move the text around the screen and increasing its size.

* Create a second label in the scene.

* Position the first label near the second label you created so that they overlap, then change their z-order to see how that affects the rendering.
{% endexercise %}

&nbsp;

### Adding a Menu

Now for our game's _killer feature_: a menu that allows us to exit.

When drawing a menu we specify:

* padding &emdash; The spacing between menu options. A value of 20 or above is usually required.
* highlight-color &emdash; The color for the currently selected menu option, using the same `0x` format as previous colors.
* options &emdash; An array of strings with the menu options, like `[ 'Start Game', 'Exit Game' ]`.
* model &emdash; Define the model, here `'metro::models::menu'`.

{% codesample github jumpstartlab@metro_gaming_tutorial b7bab8f:scenes/title_scene.rb %}

Run the game again and you'll see the title and the two menu items.

{% terminal %}
$ metro
{% endterminal %}

![Title Screen With Menu](title-screen-with-menu.png)

Pressing the **'enter'** key should generate an error message that there is an `undefined method 'start_game' or 'exit_game' for [SCENE: title(TitleScene)]:TitleScene.`

Now define methods with those exact names in your scene. Let's start with a stub for `start_game` like below. To exit the game we will just use Ruby's `exit`:

{% codesample github jumpstartlab@metro_gaming_tutorial 9e20c89:scenes/title_scene.rb %}

{% exercise %}
### Exercise

* Experiment with the x, y, padding, and highlight color.

* Create additional menu options that may exist on a title screen.

* Create the scene methods that would accompany those menu options.

{% endexercise %}

&nbsp;

## Wrap Up

On the surface, you created a simple menu for a game that doesn't exist. But, more importantly, you started working with Metro's concepts of scenes and actors.

### Key Takeaways

* All metro games have a game file containing information about the game, by default named `metro`
* A metro game has models, views, and scenes.
* Scenes are the coordinators or controllers for games.
* Metro helper methods to allow you to quickly draw labels and menus on the screen.
