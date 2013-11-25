---
layout: page
title: JSTasker
---

In this project we'll practice jQuery fundamentals including selectors, DOM manipulation, manipulating style, basic animations, and working with collections.  Our project is to build a simple in-browser To-Do list.  A user will be able to enter to-do items, hit enter, and they'll be displayed in a list.  The list will allow items to be checked off when completed or removed.

### 1. HTML and Stylesheet

We'll start with a very barebones HTML structure.  We'll create a form with a single fieldset to hold our text field and an "add" button.  Then below we'll have a div with the ID of 'tasks' containing a UL where our tasks will be inserted.  Here is the HTML:

```html
<!doctype html>
<html>
  <head>
    <meta charset="UTF-8" />
    <title>Tasker</title>
    <link rel='stylesheet' type="text/css" href='styles.css'/>
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.1/jquery.min.js"></script>
    <script src="application.js"></script>
  </head>

  <body>
    <h1>JSTasker</h1>
    <form id='add_task'>
      <fieldset>
        <legend>Add a Task</legend>
        <input type='text' name='task_text' id='task_text' />
        <input type='submit' name='add_button' value='Add' />
      </fieldset>
    </form>

    <div id='tasks'>
      <h2>Your Tasks</h2>
      <ul>
      </ul>
    </div>
  </body>
</html>
```

And here is the css for `styles.css`:

```css
h1, h2, ul, li{
  margin: 0px;
  padding: 0px;
}

html{
  background: #333;
  font-family: 'Gill Sans Light', 'Helvetica', 'Arial';
  font-size: 90%;
}

body{
  width: 400px;
  margin: 10px auto;
  border: 1px solid #EEE;
  background: #F6F6F6;
  padding: 10px 20px;
}

fieldset{
  border: 2px solid #CCC;
  padding: 10px;
  margin: 10px 0px 0px 0px;

}

input[type=text] {
  width: 300px;
  padding-right: 20px;
}
input[type=submit]{

}

#tasks{
  margin: 20px 0px 0px 0px;
}

h2{
  margin-bottom: 10px;
}

h2 span#task_counter{
  font-size: 80%;
  color: #999;
}

#tasks ul{
  list-style-type: none;
}

#tasks ul li{
  padding: 6px 10px 3px 20px;
  height: 1.6em;

}

#tasks ul li:hover{
  background: #FFF8DC;
  text-decoration: underline;
}

#tasks ul li.completed{
  background: url('icons/accept.png') no-repeat 0px 5px;
  text-decoration: line-through;
  color: #999;
}

.trash{
  float: right;
  padding: 2px;
}

.trash:hover{
  background: #F99;
  cursor: pointer;
}
```

Here's a link where you can download [accept.png](/images/accept.png).

### 2. Add a Task

The most obvious place to start is with adding a task.  Try typing in a task and clicking the add button.  What happens?

#### Intercepting the Click

Normal HTML form tags contain an address to submit the form to, but ours are blank.  Therefore the browser submits the form back to the page in the form of a GET request which puts the parameters into the URL.  Your URL likely now looks like `index.html?task_text=Wakeup&add_button=Add`.

We'll handle the data processing in Javascript, so as a first step let's prevent the browser from actually submitting the form.  We need to find the form, add a listener for a `submit` event, then prevent the browser's default action.  Here's the code to get us started in `application.js`:

```javascript
$(function(){
  $('form#add_task').on('submit', function(event){
    event.preventDefault();
  });
});
```

Our selector finds the form element with the ID of `add_task` and attaches a submit listener.  That listener is a function, accepting the parameter named `event`, which has a one-line block of code.  That line tell the `event` object to prevent the browser's default action.  If you're curious about the `event` object, check out the API page for events: [http://api.jquery.com/category/events/event-object/](http://api.jquery.com/category/events/event-object/).

Try that in your browser.  Now when you click the add button nothing happens at all.  Is our listener working?  It would seem so since the browser isn't actually submitting the form, but let's prove it.

Within your `click` listener function, add a line to pop an `alert` box just saying `"You clicked the add button!"`.  Try this in the browser and make sure it triggers when you click the button.  Assuming that works fine we feel confident that our function is being called when we click the add button.

#### Pulling Form Content

The first step to adding the task to the list is to get the text entered into the box.  Write a selector to find the correct `input` and try modifying your `alert` to show the text of the field.

Finding the element is easy, but how do you pull out the entered text?  You might be tempted to use `.text()` like we did in JSRights.  The `text` method finds the text inside a DOM element, but an input element like this doesn't really have an "inside" -- it's a single self-closing tag.  Instead we need the value within the input which we access with the `.val()` method.  Here's what I used:

```javascript
var taskText = $('input#task_text').val();
alert(taskText);
```

#### Constructing and Inserting the List Item

Now that we've got the text we can insert it into the list.  This is very similar to what we did with the Table of Contents.  Try it in these steps:

1. Create a new variable containing the name of the task wrapped in LI tags
1. Use a selector to find the tasks UL
1. Use `append` to add the new LI into the UL

### 3. UI Enhancements

#### Clearing the Text Field

Once you're adding items to the list it becomes apparent that you should clear the text box once the task is added to the list.  How do we do that?

There's a pattern commonly used in jQuery methods: when no parameter is passed in it acts as a "getter", retrieving the data from the object.  When a parameter is passed it works as a "setter", changing the data in the object.  We've seen this with `.text()` and it's also true of `.val()`.

Under your line which appends the LI into the UL, add a line which calls the `.val()` method on the text input field.  What value should you set it to?  You can use either the empty string like `""` or use `null`, Javascript's way of saying "nothing".

#### Auto-Focus the Text Field

Open a new tab and go to Google.  See how the text box is automatically active, ready for you to type?  They know you didn't come to the page to click on buttons, you came to search.  Our page should do the same thing: putting the cursor into the text box when the page is loaded.

We want this to happen when the page is loaded, so make sure you write the instruction *outside* your `click` listener.

All you need to do is write a selector to find the text field and call the method `.focus()` with no parameters.  Refresh your page and you should see the cursor pop into the box, waiting for your tasks.

Now, in HTML5, we can instead use the `autofocus` option on an input tag. For example:

```html
<input type='text' name='task_text' id='task_text' autofocus="autofocus" />
```

#### Hovering on Tasks aka Thoughts on Dividing Responsibilities

When you unlock the power of Javascript there's a temptation to do EVERYTHING in Javascript.  We could have just started with a blank HTML document and built our whole form and page on the fly with Javascript.  We'd be very fancy, but why?  You have to try to do things the easiest way possible.  You've got HTML, CSS, and Javascript -- how do you decide where things go?

*HTML* is for content.  Unless it's built dynamically, the content that's seen on your page should be in the HTML.

*CSS* is for style.  Anything having to do with how things _look_ should be handled in CSS.

*Javascript* is for action.  It brings your page to life, but it should also be a last resort.  If you can accomplish the job using HTML or CSS do it there instead!

So I wanted to add in a `hover` action to the task list items.  I wanted them to highlight when the mouse passed over them...

Then I went through this thought process: "Can I handle it in HTML? No. How about CSS? Yes!" So it would be more fancy to build a `hover` listener, but since all I'm doing on hover is changing how things *look* it's more appropriate to handle it in CSS.  Therefore, if you look in styles.css, you'll see styles for `#tasks ul li:hover`.  It's simple, it works, so it's the right thing to do.

### 4. Check and Uncheck Tasks

This is a depressing application.  We can create a whole bunch of tasks, but we can't check them off!  Time to fix that.

Think about the structure of the problem.  We have these LI objects which we're inserting into the DOM.  When the user clicks on the LI we want to mark it as completed.  To represent a completed task I want it greyed out and with a strikethrough across the text.

These, again, are about how the element *looks*, not how it *acts*.  We need to handle the looks in CSS and use Javascript to add on the appropriate classes when we click an element.  Take a look at `styles.css` and you'll find a rule for `#tasks ul li.completed`.  When the user clicks on a task to complete it we need to add the CSS class `completed` to the LI.

#### Adding a Click Listener

Inside our existing `click` listener for the form we're creating the new LI item.  We need to add click listener to that LI which, when clicked, will add the `complete` CSS class to the LI.

On your own, try to write the `click` listener attached to the LI.  For starters, have the function just pop an `alert` saying `"You clicked on a task!"`.

#### Adding the CSS Class

Now, to make your click listener more meaningful, remove the `alert` line.  In it's place put this:

```javascript
$(this).addClass('completed');
```

Try it out in your browser.  Cool, right?  Inspect the HTML and you'll see the CSS class getting dynamically added.

In real life users make mistakes.  It'd be nice if we could un-check a task.  There are three ways to do this:

1. When the list item is clicked you could remove the existing click listener and add a new one that, when clicked, removes the `completed` class
1. Change the existing listener to check if the `completed` class is present.  If it isn't add it.  If it is, remove it.
1. Change the existing listener to use the `toggleClass` method instead of `addClass`, getting you the functionality of option 2 with no complexity

That's a clear choice, right?  Do it and confirm it works in your browser.

### 5. Counting

I don't know about you, but my task lists are usually HUMONGOUS.  It would be nice to know how many tasks are in the list.  Ideally it'd be right next to the "Your Tasks" heading.  If you peek in the CSS file you'll see a style for `h2 span#task_counter`.  Let's make that happen!

1. Insert the span into the task list's HTML
1. Write a named function to update the counter
1. Add a call to that function in our existing click listeners

#### Add the Span to the HTML

Open up the `index.html` file and find the "Your Tasks" H2.  Just before the closing H2 tag, add in the following:

```html
<span id='task_counter'></span>
```

Could we have done this in Javascript? Sure. But it's structural content, so when possible we should just modify the HTML.

#### Write a Named Function

Up until now we've written anonymous functions.  They looked like `function (){}`.  But, when appropriate, we can create functions with names.

At the very top of your `application.js`, even above the document ready line, add the following:

```javascript
function updateTaskCounter(){
  alert("Updating the task counter!");
}
```

This defines a function named `updateTaskCounter` which, when called, will pop an alert box.  A few things to notice here:

1. We put it before the document ready line because we don't need to wait for the document to be ready before _defining_ functions, only _running_ them when they need to manipulate the DOM.
1. Functions blocks end with a `}` and don't need a semicolon, though many people put one
1. This function is defined on the global namespace, so it can be run anywhere in our code AFTER it has been defined
1. Because of point 3, it's a good practice to put your named functions at the top of the file

#### Calling the `updateTaskCounter` Function

When do we need to update the counter?  The first place is whenever we add a task.  Find the bottom of that `click` listener and, maybe right below the line that clears the text box, add a call to our method like this:

```javascript
updateTaskCounter();
```

Now go to your browser, refresh, and add a task.  You should see the alert pop saying that the counter is being updated. You might notice that when the alert pops up the item has already be added to the task list, that'll be important soon.

#### Counting the To-Dos

We need to make the `updateTaskCounter` actually do it's thing.  Here's how it'll work:

1. Find the UL containing the tasks list items
1. Count how many there are
1. Find the `task_counter` span
1. Put the count into that span

First, write a selector to find the tasks UL.  Attach the method calls `.children().size()`, store the result into a variable named `task_count`, and pop an alert showing the value of `task_count`.  Test it in your browser and confirm the number goes up with each task.

Then write a selector to find the SPAN with the id `task_counter`.  Use the `text` method to set the value to your variable `task_count`.  Delete or comment out your `alert` then test it in your browser.  Your counter should be functional!

#### Counting only Active To-Dos

Check off a few items and you'll see that, not surprisingly, the counter doesn't change.  There are two steps to fixing this:

1. Make the `updateTaskCounter` method only count incomplete items
1. Make the task `click` listener run the counter function

##### Only Counting Incomplete Items

Here's what my counter line currently looks like:

```javascript
var taskCount = $('div#tasks ul').children().size();
```

Now we want to only count active tasks.  How would you explain this in English?  I might say "Find all the list items that DON'T have the class name `completed`".  jQuery's `not()` method is perfect for a situation like this where you want to reject a subset from the selection collection.  Here's how to change that previous line:

```javascript
var taskCount = $('div#tasks ul').children().not('li.completed').size();
```

Refresh your browser, add a few tasks, then check one off.  Did the count change? No. Check off another task and you still won't see a change.  But add one more task and you'll see the count drop down.  The function is now working properly but it isn't getting called when we check off a task.

##### A Second Call to `updateTaskCounter`

So far we're calling the function when we add a task, we need to also call it when we check off a task.  Find your `click` listener which catches that action and add a call to the function.  Make sure you do it *after* you've toggled the CSS class or else your count will be off by one.

Test it out in your browser and, if everything goes to plan, your counting function is complete!

### 6. Moving Completed Tasks

If we have several items in our To-Do list, it'd be nice if the completed items would slide to the bottom to keep things tidy.  We can write a named function that...

1. Finds the task list
1. Finds all completed tasks within the task list
1. Pull them out of the list
1. Appends them back to the end of the list

Start by writing a function named `sortTasks` following the model of your `updateTaskCounter` function.  In the body just pop an alert saying "Sorting the Tasks!".

Now where should we call this method?  I'm going to cheat for now and just call it from the bottom of `updateTaskCounter`.  It already gets called whenever the list changes, so this will work properly.  We'll do a little refactoring later.

Refresh your browser and try adding a task to make sure it pops your alert about sorting.

#### Finding the List and Tasks

First remove the alert line from `sortTasks`.

Write a selector which finds the UL within the tasks div and store this into a variable named `taskList`.

Write a second selector line which finds all `children` within `taskList` that have the class name `completed`.  Store this into a variable named `allCompleted`.

#### Pull Out the Completed Tasks

Now that we have the set of completed tasks we need to pull them out of their current positions in the DOM.  jQuery has a few different methods for removing objects.  You'd probably first be tempted to try `remove()`, but if you check out the api at [http://docs.jquery.com/Manipulation/remove](http://docs.jquery.com/Manipulation/remove) you'll see that this method removes the objects and destroys their attached listeners.

We want to preserve the attached `click` listener so tasks can still be un-checked, so using `remove()` would mean rebuilding the `click` listener.  Too much work!

Instead we can use the `detach()` method.  It's similar to `remove` except that it *preserves* any attached listeners.  Call `detach()` on your `allCompleted` variable.

#### Append Them Back to the List

We've done all the hard parts.  The only thing interesting in this step is I want to show you a different method named `appendTo`.  So far we've used `append` which when called like `a.append(b)` puts `b` into the end of `a`.  When we call `a.appendTo(b)` it will stick `a` into the end of `b`.  They work exactly the same except the values are flip-flopped.  In general, use whichever feels more comfortable in the situation.

Here, though, use the `appendTo` method to stick `allCompleted` into `taskList`.

Refresh your browser, try it out, and the sorting should work both when tasks are checked and when they're un-checked.

#### Refactoring

I hate when functions tell lies.  Right now we have a function named `updateTaskCounter` which updates the counter then sorts the tasks.  That name is lying about what it does; that's not cool.

These functions are also both defined in the global namespace.  It's considered a best practice to put your functions into a namespace to prevent collisions.  Let's fix both these issues.

##### Building a Namespace

Here's how we write functions inside a namespace named `JSTasker`:

```javascript
var JSTasker = {
    updateTaskCounter: function() {
    },
    sortTasks: function() {
    },
    updatePage: function (){
    }
};
```

Copy this structure to the very top of your `application.js`.  What does it all mean?  We're creating a variable named `JSTasker`.  In Javascript functions can be stored into variables which is kinda amazing if you've never see that before.  `JSTasker` is set equal to what's called an "Object Literal Notation" object, starting and ending with `{}`.  This is the format that JSON uses if you've seen that before.

Within the brackets you give a name followed by a colon, followed by a "value", and separate elements by commas.  For our values, in this case, we're storing anonymous functions.

Confused yet?

This structure allows us to call methods by saying `JSTasker.updateTaskCounter()`.  The Javascript engine finds the `JSTasker` object, looks for an element named `updateTaskCounter`, then executes the function stored there.

Move the instructions inside your `update_task_counter` method into the anonymous function like this:

```javascript
var JSTasker = {
    updateTaskCounter: function() {
      var taskCount = $('div#tasks ul').children().not('li.completed').size();
      $('span#task_counter').text(task_count);
    },
    sortTasks: function() {
    },
    updatePage: function (){
    }
};
```

Notice that I removed the call to `sortTasks`.  We'll use the more appropriately named `updatePage` method in a minute.

Next migrate the instructions from your `sortTasks` function into the anonymous function in `JSTasker`.  Then delete the old, now blank `updateTaskCounter` and `sortTasks` methods.

Within the `updatePage` function, write a call to `this.updateTaskCounter()` and to `this.sortTasks()`.

Finally, within your document ready block, change the calls to `updateTaskCounter()` to `JSTasker.updatePage()`.

Test it out in your browser and see if everything still works.  Use the developer window as your friend, watch for the red X in the bottom right to see if there are errors.

### Extensions

Our task list is really starting to work, but there are many more functions we could add.  Here are some ideas:

* Add an animation to highlight the newly added task
* Animate the removal of checked tasks and their reinsertion at the bottom
* Add a trash link which would delete the item from the list
* Add check/uncheck all links
* Add plus/minus links that would slide the element up or down the list
* Make a second list, maybe one "Work" and one "Personal", then have a radio button to choose which list the task goes into
* Add an animation to highlight the newly added task
* Create a drag handle and dropzone so tasks could be reordered by drag & drop
