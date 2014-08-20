---
layout: page
title: Javascript in the Page
---

### HTML Scaffold

First, we'll start off with a basic HTML page. Open your editor, and paste in this code:

```html
<!doctype html>
<html>
  <head>
    <title>Learning Javascript</title>
  </head>
  <body>
    <h1>Learning Javascript</h1>
    <p>I'm going to learn javascript!</p>
  </body>
</html>
```

Save this file in a convenient location, like your Desktop, and give it a name ending in `.html` like `learning-javascript.html`

Open the page with Chrome. You can do this by dragging the page into Chrome, or by hitting Command+O (Mac OS X) or Control+O (Windows) and locating the file from there.

You should now see your html page in your browser.

### Add Javascript

Javascript can be added to your page by using the `<script>` tag inside the `<head>` tag of the document. Add some javascript to the head, like this:

```html
<head>
  <title>Learning Javascript</title>
  <script type='text/javascript'>
    alert('hello, world!');
  </script>
</head>
```

Now, refresh your page, and you should see an alert box pop up and say "hello, world!"

### Run on page load

Notice that the page content is not displayed when the alert box pops up. This is because the alert box code is run before the content of the page is run. This is going to be a problem later on when we write some javascript to interact with elements in the page.

There are a few solutions to this problem. One solution is to wait until the page announces that it's fully loaded. This varies from browser to browser. Another common solution is to move our JavaScript to the bottom of the page's body. The browser loads the HTML page from top to bottom. Placing your JavaScript at the bottom of the page ensures that all of the HTML has been loaded before your scripts run. Your page should now look like this:

```html
<!doctype html>
<html>
  <head>
    <title>Learning Javascript</title>
  </head>
  <body>
    <h1>Learning Javascript</h1>
    <p>I'm going to learn javascript!</p>
    <script type='text/javascript'>
      alert('hello, world!');
    </script>
  </body>
</html>
```

{% exercise %}

### Experiment

Experiment with your page a bit. Here are some suggestions, but feel free to do whatever you'd like:

1. Change the message in the alert box
1. Alert more than once
1. Change `alert` to `confirm` what happens?

{% endexercise %}
