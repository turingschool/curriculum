---
layout: page
title: Metro - Views and Animations
sidebar: true
---

This is the second tutorial introduction to Metro. This tutorial will build on the concepts [introduced]({% page_url metro-getting-started %}) and expand on them further. This tutorial's focus is on creating cleaner scenes by using views and animating actors within the scene.

{% archive jumpstartlab@metro_gaming_tutorial views-and-animation Download this Code! %}
This contains a skeleton game with a title screen. This also contains the player image used in the tutorial.
{% endarchive %}


## What are you making?

By the end of this tutorial you will add an image of the player to the screen and then animate the player to the center of the screen while fading the game title.

![Title Transition Complete](title-transition-finished.png)

## I0: Use the Views

We finished our title screen in the the [previous tutorial]({% page_url metro-getting-started %}).

The title scene draws a 'title' and a 'menu'. This is done with the Scene class method draw which takes a list of characteristics and converts that into actors within our scene that are drawn with each game draw call.

The title scene works but is visually cluttered. All these characteristics make it difficult to see what is important to the scene, which are our two methods 'start_game' and 'exit_game'.

#### Creating a View

A view is the second of three major concepts in Metro. A view contains visual details of the actors that are drawn within the scene. The characteristics we defined with our view method are exactly the details that we would store within the view.

Each scene has a view. Views are stored in the views directory and by default are named similar to the scene, though an alternative view name can be provided. A view can be represented in [YAML](http://www.yaml.org/YAML_for_ruby.html) or JSON format.

Our title scene expects the view file 'views/title.yaml' or 'views/title.json'.

The format of the data is a hash with the name of the actors as the key and all the characteristics as the value (another hash). In YAML this would be represented as the following:

As YAML:

{% codesample github jumpstartlab@metro_gaming_tutorial a79696f:views/title.yaml %}

Defining all of these characteristics in the title view file allows us to use the Scene's more succinct 'draws' class method:

{% codesample github jumpstartlab@metro_gaming_tutorial a79696f:scenes/title_scene.rb %}

Running metro with either a YAML or JSON view should render the same exact title screen.

![Title Screen With Logo](title-screen-with-logo.png)

{% exercise %}
### Exercise

* Define your view in JSON Format

* Define your view in YAML format

{% endexercise %}

For the remainder of the exercise we will be using a view defined in YAML.

## I1: Using an Image

We want to add the image of the player on the title screen. So let's add the image to our view.

Metro is able to draw images. It shares similar characteristics as the other elements with a few additional ones:

* model

    > The model to draw an image is 'metro::models::image'.

* path

    > The file name of the image. Images are by default assumed to be in the assets path of the project.

* angle

    > The image can be draw with a rotation applied to it. The angle value is expressed in degrees.
    
* center-x, center-y

    > The center position of the image expressed with a float between 0 and 1. By default this is set to the center of the image (0.5,0.5).

* color

    > The color of the image allows you to define the transparency settings of the image.


Tell your scene to draw the 'player' and then define the details about your player.

{% codesample github jumpstartlab@metro_gaming_tutorial cf031dd:scenes/title_scene.rb %}

![Title Screen With Player](title-transition-with-player.png)

&nbsp;

## I2: Scene Transition

When the game starts we want the player image that appears on our title screen to animate to the center of the screen. This will give some continuity for the player when the game actually starts. Second, we want the title to simply fade to black at the same time this is happening.

We could define our animation within on our title screen. However, the scene we are describing is a transition between the title scene and our game. A good goal is to keep your scenes small and short.

So let's create a new scene 'TitleTransitionScene'. Now we need to tell our title scene to transition to this new scene. This can be done with the Scene method `transition_to`. Similar to first_scene, 'transition_to' takes a scene name.

{% codesample github jumpstartlab@metro_gaming_tutorial 42e155e:scenes/title_scene.rb %}

{% codesample github jumpstartlab@metro_gaming_tutorial 42e155e:scenes/title_transition_scene.rb %}

Now when we press 'Enter' on 'Start Game' we should be presented with our new scene 'title_transition' scene.

Now we are ready to define our animation. First we need to draw the title and the player image again. Instead of redefining these elements in our views or in draw calls we are going to allow metro to give us the 'title' and 'player' from the last scene.

When a scene transitions to a new scene two events are fired:

* prepare_transition_to(new_scene)

    > The current scene receives this event with the new scene. This could allow the current scene impart information to the next scene.

* prepare_transition_from(old_scene)

    > The new scene receives this event with the previous scene as a parameter. This allows for the new scene to query the previous scene for information.

We could use `prepare_transition_from(old_scene)` to copy information about the title and the player. However, we do not need to do this work because Metro makes it easier. Instead when we define our actors for the scene we can use the option 'from: :previous_scene'.

{% codesample github jumpstartlab@metro_gaming_tutorial 89569c3:scenes/title_transition_scene.rb %}

## I3: Animation

Now we are finally ready to animate our hero to the center of the screen and to fade our title.

### Moving the Player

We want to move the player to the center of the screen. We have the player. Finding the center would normally require us to know the resolution of the game. Using the value s directly within the code would likely cause problems for us if we were to decide later to change our resolution. So we can rely on asking for some information about the game.

* Metro::Game.center

    > This will return an array containing the center x position and the center y position. Example a game running at the resolution of 640 width and 480 height would return [ 320, 240 ].

So now we need to define animation. A Metro Scene has the 'animate' method which allows us to define an implicit animation for an actor over an interval.

{% codesample github jumpstartlab@metro_gaming_tutorial 4b8004e:scenes/title_transition_scene.rb %}

Wheverever the player is at the moment, it will be animated to the final x position and y position over 60 iterations (roughly a second).

Similar to the x and y position we can do the same with the alpha level of our title label.

{% codesample github jumpstartlab@metro_gaming_tutorial 658e0c0:scenes/title_transition_scene.rb %}

![Title Screen Transition Animation](title-transition-finished.png)

{% exercise %}
### Exercise

* With the player experiment with animating the angle, x_factor, and y_factor.

* With the title experiment with animating the position, x_factor, and y_factor.

* Experiment with interval of the animation.

{% endexercise %}

Lastly the animate method allows you to specify a block of code to execute when the animation is complete. This is where you could define another animation a sequence or an action to take.

In our case when the player's animation is complete we want to transition to the a new scene. This scene would be our main game.

{% codesample github jumpstartlab@metro_gaming_tutorial a8d82f5:scenes/title_transition_scene.rb %}

## Wrap Up

Our game is just getting started but with the ease at which we can draw and animate shows some promise.

* All scenes will load a view that is based on it's name.

* Scenes can be defined in YAML or JSON format.

* Views allow us to keep scenes cleaner and clearer.

* Transitioning to a new scene is done with the 'transition_to' method.

* New scenes can load the actor's in the previous scene.

* Animations allow us to quickly move, grow, or fade actors within our scene.
