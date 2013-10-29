---
layout: page
title: Mechanize
---

As programmers, the essence of your job is to remove tedium from the world.

### Writing Scripts

One way to do that is to write little programs (often called _scripts_ if they're one-off or ad-hoc things) to take care of things for us. What's the difference between a script and an application? Typically an application is used by an *end-user*, while a *script* is used by either the developer or another internal user.

Typical tasks would be:

* generate a pdf invoice every 2 weeks and email it to your employer
* generate a "hall of fame" list based on a text file of names and upload it to the right place on an FTP server
* automatically scan a given web page for some text and **do stuff** when a particular phrase is detected (see the sci-fi novel Daemon for an interesting take on this).
* grab the source HTML for a web page and pull out the data that you care about, be it images, css, urls, or only the text.

## Web Scripts & HTML

You're web developers, so the majority of your jobs are going to be centered on the web. We love when applications provide beautiful, RESTful APIs and have well-designed wrapper gems to access them.

But the *rest* of the time, you'll have to get the data you want like a browser: making requests, getting HTML responses, and picking through the wall of text for the data.

### Parsing HTML Yourself

Almost every developer has tried reading or parsing HTML with regular expressions. Just don't do it: there are so many things to go wrong.

In Ruby, the typical tool for parsing HTML or XML is [nokogiri](http://nokogiri.org/). In many cases, using nokogiri directly is all you need. Grab the HTML content, get the HTML nodes you want, do your *thing*.

### Installing Nokogiri

Install nokogiri from your terminal:

```plain
gem install nokogiri
```

It includes some C code, so it might take a little while to install (it will say _building native extensions_). If there are problems with the gem install, your development environment isn't properly configured. For instance, you might have an incompatible version of GCC or be missing some header libraries. Fixing these issues is beyond the scope of this tutorial.

### An HTML-Nokogiri Experiment

This is how you'd get the list of the _breaking news_ links from the Denver post. Drop this code into a Ruby script and execute it:

```ruby
require 'nokogiri'
require 'open-uri'

url = "http://www.denverpost.com/frontpage"

page = Nokogiri::HTML(open(url))
page.css('a').each do |element|
  puts
  puts element.text
  puts element.attributes['href'].value
end
```

#### What Just Happened

The script called the `open` method which is defined by the `open-url` library. This method returns an I/O (input/output) object which reads the data from the specified URL. For instance, you can try this in IRB:

```ruby
001 > require 'open-uri'
 => true
002 > open('http://google.com')
 => #<File:/var/folders/hl/kf6pvb8538j0kyrzm5gp3zjh0000gn/T/open-uri20131028-32050-1v3mcbj>
003 > open('http://google.com').read
 # lots of HTML output...
```

That I/O object was then passed to `Nokogiri::HTML`. That `HTML` is a class method on the `Nokogiri` class. Running the experiment so far in IRB:

```ruby
001 > require 'nokogiri'
 => true
002 > url = "http://www.denverpost.com/frontpage"
 => "http://www.denverpost.com/frontpage" 
003 > page = Nokogiri::HTML(open(url))
 # lots of output...
```

Then you can poke around on that `page` object:

```
004 > page.methods
 => [:type, :meta_encoding, ...]
005 > page.title
 => "Front Page - The Denver Post" 
```

Call the `.css` method to find all elements matching the CSS selector you specify:

```
006 > page.css("a").count
 => 770 
```

There are 770 links on the front page. What is the object that comes back from `page.css("a")`? We called `count` on it, presuming that it acts like an Array...or something similar.

```
007 > page.css("a").class
 => Nokogiri::XML::NodeSet 
```

What is a `Nokogiri::XML::NodeSet`? We don't care. As long as it behaves like an Array, then we know how to work with it:

```
008 > page.css('a').each do |element|
009 >   puts
010?>   puts element.text
011?>   puts element.attributes['href'].value
012?> end
```

Iterate through `each` element of the collection and execute the block. What methods can you call on `element`?

```
013 > page.css('a').first.class
 => Nokogiri::XML::Element 
014 > page.css('a').first.methods
 => #...
```

You can check out the [XML::Element documentation](http://nokogiri.org/Nokogiri/XML/Element.html) which just redirects you to the [XML::Node documentation](http://nokogiri.org/Nokogiri/XML/Node.html). There are many handy methods there, like `inner_html`, `inner_text`, `text`, `parent`, etc.

## Scripting Beyond HTML

Sometimes, though, websites want you to do pesky things like fill in forms and follow redirects. Websites check your cookies and store session data, and nokogiri isn't optimized to handle that sort of thing. 

This is where mechanize comes in. It makes it really easy to do things like fill out forms and click buttons.

### Using Mechanize

Install mechanize:

```plain
gem install mechanize
```

It depends on nokogiri. If you managed to get that installed above, you should have no problem getting mechanize working.

### Trying It Out

We'll do the same work as above, only using mechanize rather than using nokogiri directly:

```ruby
require 'mechanize'

url = "http://www.denverpost.com/frontpage"

agent = Mechanize.new
page = agent.get(url)

page.links.each do |link|
  puts
  puts link.text
  puts link.href
end
```

It's not very different. The `page` that mechanize returns gives us direct access to all the nokogiri stuff, and also provides some nice shortcuts and a more intuitive interface.

The real power of mechanize becomes apparent when you need to fill in forms, follow redirects, be authenticated, upload files and all that jazz.

### Fetching Data Behind an Authentication Wall

GroupBuzz doesn't have enough notifcations and digests for you? How about you create your own? Let's build a script that...

1. logs into groupbuzz.io,
2. gets all the blog posts that everyone posted in the last retrospective, and
3. does some text analysis (e.g. who wrote the longest/shortest post? Average word count?)

Here's some code to get you started:

```ruby
require 'mechanize'

url = "http://gschool.groupbuzz.io/login"
agent = Mechanize.new
page = agent.get(url)

login_form = page.form_with(action: 'http://gschool.groupbuzz.io/sessions')

login_form.field_with(name: 'login_form[email]').value = 'you@example.com'
login_form.field_with(name: 'login_form[password]').value = 'topsecret'
login_form.submit
```

Once you're logged in, you can go to the topic for the retrospective links:

```ruby
url = "http://gschool.groupbuzz.io/topics/810-retrospective-10-24"
page = agent.get(url)
```

Things to consider:

* How can you get *only* the links that are in the actual body of the post?
* How can you figure out who wrote what?
