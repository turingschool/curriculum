# Jumpstart Lab Curriculum

[![Build Status](https://secure.travis-ci.org/JumpstartLab/curriculum.png?branch=master)](http://travis-ci.org/JumpstartLab/curriculum)

## Authoring and Editing Content

### Setup

The code highlighting used throughout the tutorials is colorized by an external site. The colorized results are stored in Redis locally. So to work with this site effectively, you'll want to have Redis installed. The first time you generate the site it'll be slow as the fragments are being cached, but future generate processes should be quite fast.

### View

```
bundle exec rake preview
```

Generates the content and then lauches a Sinatra web application. 


In your browser visit [localhost:4000](http://localhost:4000) or execute `open http://localhost:4000` to lauch the browser.

> Note: This project contains a lot of content so the initial generation will delay the initial startup of the webservice for a few seconds. Saved changes to the content will cause Jekyll to re-generate all of the content causing a delay before it is displayed in the browser. Ensure any caching is disabled.

### Custom Page Attributes

#### Sidebar - Table of Contents 

You can automatically enable a Table of Contents for long pieces of content. This sidebar will place all `h2` elements (generated from `##` markdown) as linkable references.

An example:

```
---
layout: page
title: Object Oriented Javascript
sidebar: true
---
```

### Custom Tags

#### `{% terminal %} CODE {% endterminal %}`

Generates the text inside of a OSX styled terminal window.

Lines that are commands are prefaced with a *$*. Lines without are treated as output.

{% terminal %}
$ ruby -v
ruby 1.9.3p194 (2012-04-20 revision 35410) [x86_64-darwin11.4.0]
{% endterminal %}

#### `{% irb %} CODE {% endirb %}`

Generates the text inside of a OSX styled IRB window

Lines that are commands are prefaced with a *$*. Linesk without are treated as output.

{% irb %}
$ 1 + 1
2
{% endirb %}

#### `{% page_url filename-of-content %}`

The `page_url` tag allows you to link to content without regard to knowing the relative or absolute path to the content item from the current item that you are editing.

```
### Great Javascript Tutorials

{% page_url 1-javascript-in-the-page %}
{% page_url 2-javascript-basics.markdown %}
{% page_url 3-dom-basics.html %}
```

* The resulting link will use the title of the linked document
* The extension of the file is ignored


#### `{% section path/to/content.markdown path/to/image-to-display.png Title of Section %}`

This tag will generate a special section layout which will embed the specified markdown content file in the page with an image and a special title.

## Online

Visit [http://tutorials.jumpstartlab.com](http://tutorials.jumpstartlab.com)

### License

<p>Unless otherwise noted, all materials licensed <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/3.0/">Creative Commons Attribution-NonCommercial-ShareAlike 3.0</a>&nbsp;<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/3.0/"><img alt="Creative Commons License" style="border-width:0" src="http://i.creativecommons.org/l/by-nc-sa/3.0/80x15.png" /></a></p>

