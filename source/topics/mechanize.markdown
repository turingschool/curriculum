---
layout: page
title: Mechanize
date: 2013-10-28
---

We do a lot of tedious, repetitive things on the web. As programmers, one ofour goals should be to eliminate tedious and repetitive things.

One way to do that is to write little programs (often called _scripts_ if they're one-off or ad-hoc things) to take care of things for us.

Typical tasks would be:

* generate a pdf invoice every 2 weeks and email it to your employer
* generate a "hall of fame" list based on a text file of names and upload it to the right place on an ftp server
* automatically scan a given web page for some text and **do stuff** when a particular phrase is detected (see the sci-fi novel Daemon for an interesting take on this).
* grab the source HTML for a web page and pull out the data that you care about, be it images, css, urls, or only the text within a particular HTML element.

In Ruby, the typical tool for parsing HTML or XML is a gem called **nokogiri**. In many cases, using nokogiri directly is all you need. Grab the HTML content, get the HTML nodes you want, do stuff.

Sometimes, though, websites want you to do pesky things like fill in forms and follow redirects. Websites check your cookies and store session data, and nokogiri isn't optimized to handle that sort of thing. This is where mechanize comes in. It makes it really easy to do things like fill out forms and click buttons.

## Using Nokogiri

Installing nokogiri should be straight forward:

```plain
gem install nokogiri
```

It includes some C code, so it might take a little while to install (it will say _building native extensions_). It might complain that it's missing dependencies, which is likely to be C code that is expected to be on your machine.

### Trying it out

This is how you'd get the list of the _breaking news_ links from the Denver post.

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

### Using Mechanize

Install mechanize:

```plain
gem install mechanize
```

It depends on nokogiri. If you managed to get that installed above, you should have no problem getting mechanize working.

### Trying it out

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

