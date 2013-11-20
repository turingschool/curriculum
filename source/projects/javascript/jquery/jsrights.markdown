---
layout: page
title: JSRights
---

In this short project we'll work with the United States Bill of Rights.  Starting with some simple markup and the body content, we'll use jQuery to generate a table of contents and some simple user interface features.

### 1. The Plain Old Thing

Let's start with this very basic HTML:

```html
<!doctype html>
<html>
  <head>
    <meta charset="UTF-8"/>
    <title>The Bill of Rights</title>
    <link rel="stylesheet" href="styles.css" type="text/css" media="screen" charset="utf-8" />
  </head>
  <body>

    <h1>The Bill of Rights</h1>
    <div class='article'>
      <h2> Article I</h2>
      <p>
        After the first enumeration required by the first article of the Constitution, there shall be one representative for every thirty thousand, until the number shall amount to one hundred, after which the proportion shall be so regulated by Congress, that there shall be not less than one hundred representatives, nor less than one representative for every forty thousand persons, until the number of representatives shall amount to two hundred; after which the proportion shall be so regulated by Congress, that there shall be not less than two hundred representatives, nor more than one representative for every fifty thousand persons.
      </p>
    </div>

    <div class='article'>
      <h2> Article II</h2>
      <p>
        No law varying the compensation for the services of the Senators and Representatives, shall take effect, until an election of Representatives shall have intervened.
      </p>
    </div>

    <div class='article'>
      <h2>Article III</h2>
      <p>
        Congress shall make no law respecting an establishment of religion, or prohibiting the free exercise thereof; or abridging the freedom of speech, or of the press; or the right of the people peaceably to assemble, and to petition the Government for a redress of grievances.
      </p>
    </div>

    <div class='article'>
      <h2>Article IV</h2>
      <p>
        A well regulated Militia, being necessary to the security of a free State, the right of the people to keep and bear Arms, shall not be infringed.
      </p>
    </div>

    <div class='article'>
      <h2>Article V</h2>
      <p>
        No Soldier shall, in time of peace be quartered in any house, without the consent of the Owner, nor in time of war, but in a manner to be prescribed by law.
      </p>
    </div>

    <div class='article'>
      <h2>Article VI</h2>
      <p>
        The right of the people to be secure in their persons, houses, papers, and effects, against unreasonable searches and seizures, shall not be violated, and no Warrants shall issue, but upon probable cause, supported by Oath or affirmation, and particularly describing the place to be searched, and the persons or things to be seized.
      </p>
    </div>

    <div class='article'>
      <h2>Article VII</h2>
      <p>
        No person shall be held to answer for a capital, or otherwise infamous crime, unless on a presentment or indictment of a Grand Jury, except in cases arising in the land or naval forces, or in the Militia, when in actual service in time of War or public danger; nor shall any person be subject for the same offence to be twice put in jeopardy of life or limb; nor shall be compelled in any criminal case to be a witness against himself, nor be deprived of life, liberty, or property, without due process of law; nor shall private property be taken for public use, without just compensation.
      </p>
    </div>

    <div class='article'>
      <h2>Article VIII</h2>
      <p>
        In all criminal prosecutions, the accused shall enjoy the right to a speedy and public trial, by an impartial jury of the State and district wherein the crime shall have been committed, which district shall have been previously ascertained by law, and to be informed of the nature and cause of the accusation; to be confronted with the witnesses against him; to have compulsory process for obtaining witnesses in his favor, and to have the Assistance of Counsel for his defence.
      </p>
    </div>

    <div class='article'>
      <h2>Article IX</h2>
      <p>
        In Suits at common law, where the value in controversy shall exceed twenty dollars, the right of trial by jury shall be preserved, and no fact tried by a jury, shall be otherwise re-examined in any Court of the United States, than according to the rules of the common law.
      </p>
    </div>

    <div class='article'>
      <h2>Article X</h2>
      <p>
        Excessive bail shall not be required, nor excessive fines imposed, nor cruel and unusual punishments inflicted.
      </p>
    </div>

    <div class='article'>
      <h2>Article XI</h2>
      <p>
        The enumeration in the Constitution, of certain rights, shall not be construed to deny or disparage others retained by the people.
      </p>
    </div>

    <div class='article'>
      <h2>Article XII</h2>
      <p>
        The powers not delegated to the United States by the Constitution, nor prohibited by it to the States, are reserved to the States respectively, or to the people.
      </p>
    </div>

  </body>
</html>
```

Also, you'll want to make a file called `styles.css` in the same folder containing these styles:

```css
html{
  background-color: #CCC;
}

body{
  margin: 50px auto;
  font-family: Garamond;
  width: 620px;
  padding: 20px;
  background-color: #FFF;
}

h1{
  background-color: #E0E0E0;
}

h1, .article{
  padding: 10px;
}

h2{
  font-size: 24px;
  padding: 0px;
  margin: 0px;
}

p{
  margin: 5px 0px 5px 0px;
}

ul#toc{
  margin-left: 20px;
  font-size: 80%;
}
```

What you should notice about this document is that each Article starts with an `h2` heading then the text of the article is in a paragraph following it.  Looking at the document's `head` section you'll see that it include a CSS stylesheet but nothing else.  Open this page in your browser to get a sense of the text.

### 2. Loading jQuery and Your Javascript

With that baseline setup we can start integrating our Javascript.  First, include the jQuery library from Google:

```html
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.1/jquery.min.js"></script>
```

Then we want to include our own Javascript file which we'll create in a second:

```html
<script src="application.js"></script>
```

Next create a second file in your project directory named `application.js` and open it.

Refresh your browser and there will be no change.  We're loading these Javascript files but we're not actually doing anything.  Now in your `application.js` add the following:

```html
alert("I loaded application.js!");
```

Refresh your browser and you should see an alert box indicating that the `application.js` file was loaded.  Check the RESOURCES tab in Chrome and make sure jQuery is downloading properly.  Then you're good to go for some real development!

### 3. Back to Top

The first feature we'll add is a "Back to Top" link under each article.  Why do this in Javascript when we could just change the HTML? For one thing, we can keep our text more pure by handling it in Javascript.  More importantly, our Javascript approach is flexible and repurposable. If we were dealing with thousands of documents it would work great, where modifying the HTML might take weeks.

We want to insert new content.  The process goes something like this:

1. Find the places you want the content
1. Create the content
1. Stick it in that spot

So where do we want the link? It'd be tempting to put the link after every paragraph since each article is just one, but that seems a little sloppy.  If there were introductory paragraphs or something they might get links too.  Each article is wrapped in a DIV tag with the class name `article` so let's find those DIVs and stick the link just inside the closing DIV tag.

We need a jQuery selector.  If you're familiar with CSS then writing selector statements is super easy.  In this case we want DIV tags with the class name `article` so we just write `"div.article"`.  We'll also need to wrap our jQuery in the document ready lines, so start with this in your `application.js`:

```javascript
$(function (){
    $("div.article");
});
```

Refresh your browser and you'll see...no change.  We might have selected all the article DIVs, but we didn't do anything with them.  When I'm not sure about a selector I like to first add some CSS attributes to the matched objects.  That gives me a visual confirmation that jQuery is finding the things I want it to find.  Modify your middle line in `application.js` so it's like this:

```javascript
$("div.article").css('border','3px solid #FCC');
```

Refresh your browser and pink borders should pop around each article.  The CSS method sets a CSS property on each element that the selector matched.  One thing I love about Chrome is how you can now do "Inspect Element" on those article `div`s and it'll show you, right in the souce code, the CSS that has been dynamically applied.  We know our selector is working!

We found the places we want the content, now to create the content.  I don't like to have a whole lot of HTML in my Javascript.  In this case we'll need it, but we can at least abstract it into a variable.  Add this line just above your selector line:

```html
var backToTop = "<a href='#top'>Back to Top</a>";
```

We know where the content goes, we've got the content, now let's put it in there.  There are several methods for inserting content in jQuery that each have a slightly different purpose.  We want to stick content "inside but at the end of" the matched elements.  This is an append operation which we can accomplish like this:

```javascript
$("div.article").append(backToTop);
```

Replace the `.css` line with that one, refresh your browser, and your Back to Top links should appear.  You've dynamically created content within the HTML page!

#### On Your Own: The #top Anchor

These links are great but if you click them nothing happens.  You need to insert more content.  At the very top of our HTML page is the H1 with the text "Bill of Rights".  Insert a named anchor like `<a name='top'>` within that `h1` and check that your links work.

### 4. Table of Contents

Jumping back to the top is great and all, but what most users are going to want is to jump from the top to the article they're interested in.  We need to build a table of contents on the fly.  How's that possible?

1. Create a ToC heading and unordered list near the top of the page
1. Find all the `h2`s, they are the names of the articles
1. Insert the article names as list items into the UL
1. Insert named anchors into each of the `h2`s
1. Link the Table of Contents item to the `h2`

#### Create a ToC Heading and Unordered List

We've already practiced creating a variable to hold HTML then inserting that HTML.  Store `"<h2 id='toc'><a name='toc'>Table of Contents</a></h2>"` into a variable and insert it into the markup just below the existing H1.  Instead of using `append` like we did before, here you need `after` so it goes outside the closing H1 tag.

Then, just under that heading, insert an unordered list (UL) with the id attribute set to `'toc'`.  The tricky thing here is that you probably want to use a selector to find the ToC `h2`, but how can we do that without getting all the `h2`s? Use the CSS-style virtual attribute `:first` like `h2:first`.

Refresh the page in your browser, use the Inspect Element tool, and make sure your new HTML is getting injected properly.

#### Finding the Titles and Inserting them into the ToC

First, *on your own*, write a selector which finds all the article `h2`s and sets their background color to #CCF.  Make sure it's not selecting the heading ToC heading.

Now that you've found the `h2`s, we need to grab their content and create the list items.  Our selector is finding the collection of `h2`s, then we can use the `each` method to run instructions on each element of the collection.  Here's how it'll look:

```javascript
    $("div.article h2").each(function (){

    });
```

We pass a `function` into `each` holding the instructions we want run on each element.  Remember that we bundle it into a function so the instructions don't get executed when the script is first read, they wait until the function is called.

We want to pull the text out of the object.  How do we get to the one object we're looking at within the collection? We can try using the special variable `this` like so:

```javascript
    $("div.article h2").each(function (){
      var title = this.text();
      alert(title);
    });
```

Refresh your browser and you won't see any alert boxes popping up.  Look at your developer pane and you'll see an error like `Object #<an HTMLHeadingElement> has no method 'text'`.  You get this error because within the `each` method, the `this` variable refers to the plain DOM object.  It isn't a jQuery object, so we can't call a jQuery method like `.text` or else we see this error.

But it allows us to show another usage style for the `$` jQuery reference.  Modify your code block to pass `this` into `$` like so:

```javascript
$("div.article h2").each(function (){
  var title = $(this).text();
  alert(title);
});
```

Now refresh your page and you should see a bunch of popups with the individual article titles.  It works! Now, what were we trying to do again?  We wanted to insert these titles into the ToC list.  Instead of alerting the title, let's build it into an `li` like this:

```javascript
var listItem = "<li>" + title + "</li>";
```

Then, on your own, write a selector to find the ToC UL and `append` the `list_item`.  Refresh your browser and you should see a plain text Table of Contents.

#### Linking

Our ToC is nice for reading and printing, but it should be linked.  We want to click on an article title in the ToC and jump to the article further down the page.  To accomplish this interaction we need to:

1. Take the title and convert it to a "slug" usable in a URL
1. Insert anchors in the individual article `h2`s which have the name set to that slug
1. Link the list items in the ToC to that slug

##### Creating a Slug

We already have the `title` variable which holds name of the article like "Article X".  We need to create a slug version of that, conventionally all lowercase and spaces replaced by underscores like `article_x`.  We'll use a mix of jQuery methods and normal Javascript methods to accomplish this translation.

It's a great application of method chaining, but we need to be aware of what object type we're expecting back.  The jQuery methods should give jQuery objects back, while the Javascript methods are going to give Javascript objects.  A jQuery object knows the Javascript methods too, but a Javascript object does *not* know the jQuery methods -- so our ordering will be important.  Let's start with these lines just under your current `title = ` line.

```javascript
var slug = title;
alert(slug);
```

Refresh your browser and you'll just see the normal titles in alert boxes.  As a first step I want to use the jQuery method `.trim()` which cuts any whitespace off the frontend or backend of our string.  Now those lines will look like this:

```javascript
var slug = title.trim();
alert(slug);
```

Remember that in Javascript we have to put the method's parentheses even if there are no parameters.  Now we'll use some normal Javascript methods to manipulate the string further.

Right after your `trim()` call, add on a call to `.toLowerCase()` to convert it to lower case.  Then we need the `.replace()` method which takes two parameters: the string to find and the string to replace it with.  Use it to replace a space with an underscore.  Combining them all gives me this line:

```javascript
var slug = title.trim().toLowerCase().replace(" ", "_");
```

Refresh your browser to check that the slugs look good and we can move on.

##### Insert the Target Anchors

Now that we have the slug we can setup the target anchors.  Within the `each` block that we've been working in, remember that `this` is referring to the `h2`.  We want to inject the anchor inside that `h2`.  Let's create the anchor in one step, then insert it in a second like this:

```javascript
var targetAnchor = "<a name='" + slug + "'/>";
```

Then, on your own, use the `append` method to stick this inside the `h2`.  Remember that `self` is a pure Javascript object and it doesn't have an `append` method.

##### Link to the Targets

We need to add links into the `list_item`.  On your own, work with the `var list_item=` line to include a link tag where the `href` points to `#article_x` where `article_x` is the current slug.

Remove any `alert` lines you have and refresh your browser.  Your ToC should be fully functional!

#### A Little Usability Issue

How browsers handle anchor tags within pages varies.  In Chrome it jumps to the section of the page just below the anchor.  So in this case the links are working, but the anchor and `h2` showing the article title end up just out of view off the top of the screen.

Here's a quick fix: if we know the browser is going to jump right below the anchor, let's put the anchor before the `h2` title.  Switch your `append` to `before` to make this happen.  Now when you refresh the browser and click a link the `h2` should be at the top of the window.

This iteration is done!

### 5. Hiding Content

There's one more feature I want in our document.  Underneath the title of each article I want a `(hide)` link which, when clicked, hides the body of the article and changes the link to say `(show)`.  Here's what we need to do:

1. Create the hide link
1. Attach a `click` event handler that...
  1. Hides the article content
  1. Changes the link text

Creating the link itself is the easy part.  You already have the selector for all article `h2`s and the `each` block of instructions, so we'll continue to work within that `each` block.  Add these two lines to create a simple link and insert it after the `h2`:

```javascript
var toggleLink = $("<a href='#'>(hide)</a>");

$(this).after(toggle_link);
```

You'll notice that `toggle_link` is a jQuery object, not just a normal Javascript string, because I put it inside `$()`.  We'll need that jQuery functionality soon.  The second line inserts the link object after the `h2`.  Refresh your browser and you'll see the links appear, but when you click them nothing meaningful happens.

#### Working with the Click Event

We need to add behavior that will be executed when that link is clicked.  In between the two lines you just wrote, add this:

```javascript
toggleLink.on('click', function (event){
  $(this).siblings().hide();
});
```

What is that?  The `on` method binds the given event to the given function.  In this case, the event we're listening for is `click`, which is fired when there is a mouse click on that element.  `on` takes a `function` parameter which holds the code that will be executed when the click happens.  Here our function takes a parameter `event` which effectively creates a local variable named `event` that contains a bunch of information about when and where the click happened.  So far we're not using that variable for anything.  Then inside the function we get the link with `this`, turn it into a jQuery object with `$()`, and call the `siblings` method.  This method returns the set of all "sibling" objects in the DOM, the objects that share the same parent/wrapper object as this one.  In our case that will be all DOM objects inside the article DIV.  Once those siblings are found it calls `hide` on them to hide them from view.

Now that the `click` listener is attached to `toggle_link` we need to insert the link into the DOM.  Use this line outside of the `click` block:

```javascript
$(this).after(toggle_link);
```

Try it in your browser.  It kinda works, right?  What's the main issue?

We can fix that by filtering the `siblings` matcher.  Change `siblings()` to `siblings('p')` so it'll only match siblings which are paragraphs and retry it.  Now your article titles won't disappear.

##### Revealing the Text

Hiding is cool and all, but how about revealing?  If we click the link again it should reveal the hidden text.  In jQuery there's the `hide` method we just used and there's `show` which works exactly the same.  We could use an if/else block to say "when this link is clicked, if the text is visible then hide it, otherwise reveal it."  That'd work, but it's a common enough use case that jQuery makes it easier on us.

Several methods come in pairs like `hide` and `show`.  Many such pairs have a third instruction that toggles between them, looking at the element and figuring out which one should be done.  In this case, the toggle method is called `toggle`.  All we need to do is change our method call from `hide()` to `toggle()`.

Try that out in your browser.

##### Changing the Link Text

It works great but it looks stupid.  When the text is hidden the link still says "hide" -- it should switch to saying "show."  It'd be nice if there were some toggle-like function to change text and there is discussion about it existing in the future.  For now, though, we have to toggle the link text manually.

We'll do it in two steps:

1. Figure out what the text should be
1. Set the link to that text

Here's the logic to figure out the text: "If the link currently says `'(hide)'` then the text should be `'(show)'`, otherwise it should be `'(hide)'`.  We could use a Javascript if/else construction to get this accomplished, but when there is just one step in the "then" clause we can use the ternary operator.

Present in several languages, the ternary operator is one of those things that looks crazy but is really handy.  Here's how it's constructed:

```javascript
result = condition ? what_to_do_if_true : what_to_do_if_false
```

The condition is evaluated to true or false.  If it's true then the `what_to_do_if_true` instruction will be executed and the result stored into `result`.  If the condition was not true the `what_to_do_if_false` is executed and it's result put into `result`.

In our case, here's how we'll use it:

```javascript
var oldText = $(this).text();
var newText = (oldText === '(hide)') ? '(show)' : '(hide)'
```

##### Setting the Link Text

Now `newText` will hold the value of what we want the link to say after this click.  Figure out how to use the `text` method to set the text of the link to `new_text`.

Try it out in your browser and it's functionally good, but there's a usability issue.

##### Stop Jumping Around, Browser!

When you click show or hide links the browser is jumping to the top of the page, right?  That's because in addition to executing our Javascript listening for the `click` event, it's also doing the normal things it does when you click a link -- trying to load the page or anchor.  Our actual link tag points to `#`, a blank anchor, which is the conventional pointer for "do some Javascript but don't actually load any HTML."  But the browser is looking for an anchor tag with a blank name and, not finding it, jumps you to the beginning of the page. Annoying.

The fix is simple.  We want the browser to not react to the link click itself, just run our Javascript.  jQuery has a method for doing this which encapsulates the differences between browsers.  It's acutally a method of the event object itself which is why we put `event` into the `click` method signature.  All you need to do is add this as the first line inside your `click` block:

```javascript
event.preventDefault();
```

Refresh your browser and try it out; there should be no more jumping around.  Our hide/show functionality is complete!

### 6. Refactoring to a plugin

Plugins make jQuery an excellent language for sharing re-usable pieces of code.  As we saw in this example, we created a script that goes through a page featuring `div.article` sections with `h2` tags and built up a table of contents to place under the `h1`.  We also using lots of jQuery functions that operated on selected tags, for example, `$('div.article').each(...`.  We're going to create our own method that can operate on tags using jQuery's plugin architecture.

Here's how we're going to setup our plugin and call it when the document loads:

```javascript
$.fn.tableOfContents = function(header) {
  /* our code will go here */
};

$(function (){
    $("div.article").tableOfContents($('h1'));
});
```

By adding a function to `$.fn` we can access it when selecting tags.  In our case we select all of our `div.article` tags and call our function. We also pass in the header to the plugin function so it will know where to put our ToC.

Only a few changes need to be made to our code in order to use it inside the plugin:

```javascript
// $('div.article') => this
this.append(back_to_top);

// $('h1') => header
header.append(top_anchor);

// $('h1') => header
header.after(toc_header);

// $('h2:first') => toc_header
toc_header.after(toc_list);

// $('div.article') => this
this.find('h2').each(function (){
  // all the same, since it's encapsultated in the loop
});
```

Now we are free to distribute this plugin among our team or publicly for the world to use to build tables of contents for their article lists.

### Wrapup

In this short project we took relatively plain HTML text and augmented it with navigation, a table of contents, and show/hide functionality.  While much of this would be possible by editing the HTML itself, our Javascript technique keeps the content more "pure" and brings the "function" all into one place.  This approach would also scale to multiple pages, where editing the HTML would be time consuming.

In practicing our jQuery and pure Javascript we...

* Created and worked with variables
* Used text manipulation methods like `toLowerCase` and `text`
* Used the ternary operator
* Responded to a click event
* Inserted, hid, and displayed content
* Used a variety of selectors with IDs, Classes, and Virtual Attributes
* Refactored our script into a reusable plugin
