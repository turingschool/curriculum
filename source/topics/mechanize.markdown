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

Almost every developer has tried reading or parsing HTML with regular expressions. Just don't do it: [there are so many things to go wrong](http://blog.codinghorror.com/parsing-html-the-cthulhu-way/).

In Ruby, the typical tool for parsing HTML or XML is [nokogiri](http://nokogiri.org/). In many cases, using nokogiri directly is all you need. Grab the HTML content, get the HTML nodes you want, do your *thing*.

### Installing Nokogiri

Install nokogiri from your terminal:

```plain
gem install nokogiri
```

It includes some C code, so it might take a little while to install (it will say _building native extensions_). If there are problems with the gem install, your development environment isn't properly configured. For instance, you might have an incompatible version of GCC or be missing some header libraries. Read through [Nokogiri's installation instructions](http://nokogiri.org/tutorials/installing_nokogiri.html) if this is the case.

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
  puts element['href']
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
011?>   puts element['href']
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

### What About Filling In Forms and Logging In?

Mechanize is able to do more than request a page and look at its links.
It can click links and fill in forms, too.
When you talk to a website, the website sets a header in the HTTP request called a cookie.
The browser then sends this back to the site whenever you interact with it.
This allows the site to set the cookie to be something that allows them to identify you.
Which, in turn, means they can do things like authenticate that you are the user you say you are, and then store that in a cookie.
If you didn't send the cookie back, it would look like you weren't logged in.
So for us to crawl sites, we often need to remember the cookies the site has set, and then re-submit them for all future requests.

If we call our current browsing process a "session", then we will want to remember cookies for this session.
Fortunately, Mechanize takes care of this for us, it keeps track of the cookies the website has sent, for the duration of our session, and continues to re-submit them.
This means that when we fill in a form to log into a website, we will continue to be logged in.
You can configure Nokogiri, or other web crawling tools to log into your accounts, and perform tasks for you, collect data for you, whatever it happens to be.

### Give It A Try

Our form won't require a session, but the process is the same.
We're going to give you a list of ISBNs that identify books about Ruby
(for a liberal definition of "Ruby"). Your task is to go to
[isbnsearch.org](http://www.isbnsearch.org), fill the isbn into the form, submit it,
and then extract the data from the resulting page into a format of your choice.

You have completed the task when you can show me a text file with all of the data.
You can verify your data against [this list](https://gist.githubusercontent.com/JoshCheek/1ef1c6fbe7ff7ee28de4/raw/4637ee480fad96f2808583e04d7c9b74e90da492/books_selected#).

Here are the ISBNS:

```
1405232501 082172388X 0764222228
0590474235 0672320835 0439539439
0375434461 0752859978 0752860224
2745945475 0425032337 074459040X
1860393225 1405232501 082172388X
0764290762 0590474235 0672320835
3826672429 0375434461 0752859978
038079392X 2745945475 0425032337
0701184361 1860393225 0758238614
0152049215 3826672429 1921656573
0747203873 0701184361 0764222228
0439539439 0152049215 0752860224
074459040X 0747203873 0764290762
038079392X 1921656573 0758238614
```

[Here](http://www.isbnsearch.org/isbn/1860393225) is an example.
You should be able to extract the title, isbn10, isbn13, author,
binding, publisher, and published date.

### You Know What You Want To Do... But How Do You Do It?

For reference, you can look at the script I used to retrieve this data with:

{% codeblock file.sh %}
curl https://gist.githubusercontent.com/JoshCheek/1ef1c6fbe7ff7ee28de4/raw/4b4f95e108ad779eec7f070f060233c68fd971e0/get_potentials.rb > example.rb
{% endcodeblock %}

But lets open up pry and play around with Mechanize a little bit.

I recommend loading pry and playing around with either the site you're going to parse
or another site. This allows you to try things out with much less effort.
Here are some examples of playing around with the Denver Post page:

```ruby
# an example pry session (http://pryrepl.org/)
require 'mechanize'
internet = Mechanize.new
internet.get "http://www.denverpost.com/frontpage"

# links
page.links.count # => 91
page.links.first # => #<Mechanize::Page::Link "Front Page" "http://www.denverpost.com/frontpage?source=hot-topic-bar">
ls -v page --grep link # displays methods with link in the name:
                       # Mechanize::Page#methods: link  link_with  link_with!  links  links_with  select_links

# use link_with to select 1 link based on attributes.
# and links_with (plural) to select all links that match that attribute
# the key is the attribute, the value is the value of that attribute
# you can also use :text to talk about the text inside of that tag
page.link_with text: 'Front Page' # => #<Mechanize::Page::Link "Front Page" "http://www.denverpost.com/frontpage?source=hot-topic-bar">

# if you want to use a CSS selector to scope which item you're interested in
# you can pass the selector as a parameter to :search
# the CSS selector must still match your item, so in the case of a link
# must end in "a", for the "anchor" tag
link = page.link_with search: '.complexListingBox a', class: 'complexListingLink'

# click the link and get the next page
link.click

# lets go back to the main page and look at the search form there
page = internet.get 'http://www.denverpost.com/'
page.forms # omitted b/c it's long

# and like link has link_with and links_with
# form has form_with and forms_with, supporting the same search interface
form = page.form_with method: 'POST'

# and within form, the same interface for its fields
input = form.field_with name: '_dyncharset' # => [hidden:0x3fecce347538 type: hidden name: _dyncharset value: UTF-8]
input.value # => "UTF-8"
input.value = 'NOT UTF 8, lol'
input # => [hidden:0x3fecce347538 type: hidden name: _dyncharset value: NOT UTF 8, lol]
form.submit # ... and so on
```

Use this information to complete the task.
If you find yourself needing something not covered here,
consider how we used pry just now to find out about the links_with methods.
Can you use this tool to answer your questions, too?

### Things to consider:

* How do you want to store the data?
* What happens if you get 90% finished with the scraping, and then it blows up for some reason? Maybe you should persist the results ASAP, so you can skip work you've already done when you fix the error and rerun it.
* What are things that could break your scraper?

### Finished and bored?

* Given that we've seen both form and link have search methods that suffix `_with` to them, we might hypothesize that there are other such methods. Can you use pry to confirm or deny this hypothesis?
* Got all the data? Nice. How about reading it in and generating a html page that lists all the books.
* Pull down other useful information, as well. How about the image and the relevant links.
