---
layout: page
title: Scraping data with Capybara
---

When you would like to retrieve data from a website,
you can use an API: an Application Programming Interface.
This is a url that emits the data in a paresable format like JSON or XML.
When the program doesn't have an API, however, how do you get it?


### Parsing HTML Yourself

Parsing HTML with regular expressions is a [losing game](http://blog.codinghorror.com/parsing-html-the-cthulhu-way/).
Instead, we'll use the industry standard [nokogiri](http://nokogiri.org/).
In many cases, using nokogiri directly is all you need.
Grab the HTML content, get the HTML nodes you want, do your *thing*.


### Installing Nokogiri

Install nokogiri from your terminal:

```plain
$ gem install nokogiri
```

It includes some C code, so it might take a little while to install
(it will say _building native extensions_).
If there are problems with the gem install,
your development environment isn't properly configured.
For instance, you might have an incompatible version of GCC
or be missing some header libraries.
Read through [Nokogiri's installation instructions](http://nokogiri.org/tutorials/installing_nokogiri.html)
if this is the case.

### An HTML-Nokogiri Experiment

This is how you'd get the list of the _breaking news_ links from the Denver post.
Drop this code into a Ruby file and execute it:

```ruby
require 'nokogiri'
require 'net/http'

# get the HTML from the website
uri  = URI("http://www.denverpost.com/frontpage")
body = Net::HTTP.get(uri)

# parse it and use CSS selectors to find all links in list elements
document = Nokogiri::HTML(body)
links    = document.css('li a')

# print each interesting looking link
links.each do |link|
  next if link.text.empty? || link['href'].empty?
  puts link.text, "  #{link['href']}", "\n"
end

# pry at the bottom so we can play with it
require "pry"
binding.pry
```

If you don't have pry, install it with

```plain
$ gem install pry
```

#### What Just Happened

The program made a URI object to parse our uri (you can think a uri as being the same thing as a url).
Then it made a GET request to that uri to get the page's body.
It gives the body to `Nokogiri::HTML`, which parses the HTML
and gives us back a Nokogiri document, an object we can use to interact with the html.
In this case, we use "css" to give it a css selector that will find all links
inside of list elements.

We also stuck a pry at the bottom so that we can play with those objects if we like.
Maybe we'd like to see what we can do with a link, we'll use Pry's `ls -v` to list out
all the interesting things on it:

```ruby
[1] pry(main)> link = links.first
=> #(Element:0x3fdb7d741bf0 {
  name = "a",
  attributes = [
    #(Attr:0x3fdb7df04978 {
      name = "href",
      value = "http://www.denverpost.com/news/ci_26538875/colorado-doctors-warn-that-sepsis-can-be-hidden?source=hot-topic-bar"
      })],
  children = [ #(Text "Hidden Killer")]
  })
[2] pry(main)> ls -v link
Enumerable#methods:
  all?            count       each_cons         entries     flat_map  lazy     min        one?          select        take_while
  any?            cycle       each_entry        find        grep      map      min_by     partition     slice_before  to_a
  chunk           detect      each_slice        find_all    group_by  max      minmax     reduce        sort          to_h
  collect         drop        each_with_index   find_index  include?  max_by   minmax_by  reject        sort_by       zip
  collect_concat  drop_while  each_with_object  first       inject    member?  none?      reverse_each  take
Nokogiri::XML::Node#methods:
  %                         attribute_nodes         description           internal_subset        node_type                text?
  /                         attribute_with_ns       do_xinclude           key?                   parent                   to_html
  <<                        attributes              document              keys                   parent=                  to_s
  <=>                       before                  document?             last_element_child     parse                    to_str
  ==                        blank?                  dup                   line                   path                     to_xhtml
  >                         canonicalize            each                  matches?               pointer_id               to_xml
  []                        cdata?                  elem?                 name                   prepend_child            traverse
  []=                       child                   element?              name=                  previous                 type
  accept                    children                element_children      namespace              previous=                unlink
  add_child                 children=               elements              namespace=             previous_element         values
  add_namespace             clone                   encode_special_chars  namespace_definitions  previous_sibling         write_html_to
  add_namespace_definition  comment?                external_subset       namespace_scopes       processing_instruction?  write_to
  add_next_sibling          content                 first_element_child   namespaced_key?        read_only?               write_xhtml_to
  add_previous_sibling      content=                fragment              namespaces             remove                   write_xml_to
  after                     create_external_subset  fragment?             native_content=        remove_attribute         xml?
  ancestors                 create_internal_subset  get_attribute         next                   replace                  xpath
  at                        css                     has_attribute?        next=                  search
  at_css                    css_path                html?                 next_element           serialize
  at_xpath                  decorate!               inner_html            next_sibling           set_attribute
  attr                      default_namespace=      inner_html=           node_name              swap
  attribute                 delete                  inner_text            node_name=             text
```

We see the link has its own `css` method, so we could run another query from within this node.
And we can see the href attribute, it looks like we get attributes by using bracket notation, like a hash.
This is a great way to play around with a new library and learn about it,

You can check out the [documentation](http://nokogiri.org/Nokogiri/XML/Node.html)
to learn more about what you can do with Nokogiri,
but this isn't a lesson about Nokogiri, lets get on to Capybara!



## Beyond HTML

Sometimes, though, websites want you to do pesky things like fill in forms and
follow redirects. Websites check your cookies and store session data, and
Nokogiri isn't optimized to handle that sort of thing.

For this, you'd want a tool that understands these things.
Mechanize is a common library for this, but it just parses html like we did with
Nokogiri, and then makes more get requests when we "click" on a link,
or "submit" a form. It's great for this purpose... except that many webpages
require JavaScript to run correctly, and Nokogiri doesn't have a JavaScript
engine in it, it's just reflecting on the static structure of the page.

### Phantom.js, Capybara and Poltergeist

To really interact with the page, we'd need to be in a browser.
This is what Phantom.js is, a browser like Opera or Firefox,
but it's specifically intended to be run by programs. It doesn't pop up a
window like the browser you use, it does all the work without ever displaying
the pages.

Capybara provides an interface for interacting with websites from Ruby.
It is specifically intended for testing, but all the functionality it provides
is useful for scraping, too.
It leaves the specifics of how to talk to the website to a "driver"
This allows you to use it with numerous tools, such as rack-test,
Which hooks it into your rack layer, allowing you to navigate your website
Without ever loading a server.

The driver that knows how to talk to Phantom.js is called Poltergeist
So we'll use Capybara to navigate the web, click links, and so forth,
like Mechanize, but we'll have it use Poltergeist so it does this in Phantom.js,
and we can interact with JavaScript

### Installation

```plain
$ brew install phantomjs
$ gem install capybara poltergeist launchy
```

### First run

Lets open Capybara's documentation with it.

```ruby
$ pry
pry(main)> require 'capybara/poltergeist'         # require the gems
pry(main)> Capybara.default_driver = :poltergeist # configure Capybara to use poltergeist as the driver
pry(main)> browser = Capybara.current_session     # the object we'll interact with
pry(main)> url = "https://github.com/jnicklas/capybara"
pry(main)> browser.visit url                      # go to a web page (first request will take a bit)
pry(main)> browser.save_and_open_page             # save the page locally, open it (this is what Launchy does)
```

And now lets head over to the Denver Post and try getting the information we previously had.

```ruby
pry> ls -v browser
# ...
Capybara::Session#methods:
  accept_alert          dismiss_prompt         has_no_link?             save_and_open_page
  accept_confirm        document               has_no_select?           save_and_open_screenshot
  accept_prompt         driver                 has_no_selector?         save_page
  all                   evaluate_script        has_no_table?            save_screenshot
  app                   execute_script         has_no_text?             select
  assert_no_selector    field_labeled          has_no_title?            server
  assert_no_text        fill_in                has_no_unchecked_field?  source
  assert_no_title       find                   has_no_xpath?            status_code
  assert_selector       find_button            has_select?              switch_to_window
  assert_text           find_by_id             has_selector?            synchronized
  assert_title          find_field             has_table?               synchronized=
  attach_file           find_link              has_text?                text
  body                  first                  has_title?               title
  check                 go_back                has_unchecked_field?     uncheck
  choose                go_forward             has_xpath?               unselect
  cleanup!              has_button?            html                     visit
  click_button          has_checked_field?     inspect                  window_opened_by
  click_link            has_content?           mode                     windows
  click_link_or_button  has_css?               open_new_window          within
  click_on              has_field?             query                    within_fieldset
  current_host          has_link?              raise_server_error!      within_frame
  current_path          has_no_button?         refute_selector          within_table
  current_scope         has_no_checked_field?  reset!                   within_window
  current_url           has_no_content?        reset_session!
  current_window        has_no_css?            resolve
  dismiss_confirm       has_no_field?          response_headers
instance variables: @app  @document  @driver  @mode  @scopes  @server  @synchronized  @touched
```

Looks like there are some good methods available to us. Methods to `click_on` things,
`fill_in` forms (I would assume), a `go_back` method, that's probably like our
back button in the browser. Oh,`current_url` looks like it should tell us where
we are, lets try that.

```ruby
pry(main)> browser.current_url
=> "http://www.denverpost.com/frontpage"
```

Yep! Oh, and that `all` looks promising, lets try and use it like we did with Nokogiri's `css`.

```ruby
pry> links = browser.all 'li a'
=> [#<Capybara::Element tag="a">, ...

pry > links.first
=> #<Capybara::Element tag="a">
```

Great, and now what can we do with a link?

```ruby
pry(main)> ls -v links.first
# ...
Capybara::Node::Finders#methods:
  all  field_labeled  find  find_button  find_by_id  find_field  find_link  first
Capybara::Node::Actions#methods:
  attach_file  choose        click_link            click_on  select   unselect
  check        click_button  click_link_or_button  fill_in   uncheck
Capybara::Node::Matchers#methods:
  ==                  has_css?               has_no_link?             has_selector?
  assert_no_selector  has_field?             has_no_select?           has_table?
  assert_no_text      has_link?              has_no_selector?         has_text?
  assert_selector     has_no_button?         has_no_table?            has_unchecked_field?
  assert_text         has_no_checked_field?  has_no_text?             has_xpath?
  has_button?         has_no_content?        has_no_unchecked_field?  refute_selector
  has_checked_field?  has_no_css?            has_no_xpath?
  has_content?        has_no_field?          has_select?
Capybara::Node::Base#methods: base  find_css  find_xpath  parent  session  synchronize
Capybara::Node::Element#methods:
  []             click         drag_to  native  right_click    set       trigger          visible?
  allow_reload!  disabled?     hover    path    select_option  tag_name  unselect_option
  checked?       double_click  inspect  reload  selected?      text      value
instance variables: @base  @parent  @query  @session
```

Hmm, a `text` method, a `value` method, both of those look promising.
Oh, and brackets, too. Lets try them out.

```ruby
pry(main)> links.first.text
=> "News"

pry(main)> links.first.value
=> nil

pry(main)> links.first['href']
=> "http://www.denverpost.com/breakingnews"
```

Okay, so value isn't interesting, but text is, and we seem to be able
to access the element's attributes with brackets like we could do with Nokogiri.

Lets try clicking that link. Notice in the methods it got from
`Capybara::Node::Actions` that we have a `click_link` method,
and down on the element, we have a `click` method. Lets try those out.

```ruby
pry(main)> links.first.click_link
ArgumentError: wrong number of arguments (0 for 1..2)
from /Users/josh/.gem/ruby/2.1.1/gems/capybara-2.4.1/lib/capybara/node/actions.rb:26:in `click_link

pry(main)> links.first.click
=> {"status"=>"success"}

pry(main)> browser.current_url
=> "http://www.denverpost.com/breakingnews"
```

Okay, so we followed the link! Oh, but I forgot to print the links on the last
page. Remember that `go_back` method? lets try that out now.

```ruby
pry(main)> browser.current_url
=> "http://www.denverpost.com/breakingnews"

pry(main)> browser.go_back
=> true

pry(main)> browser.current_url
=> "http://www.denverpost.com/frontpage"
```

Great, we're back, now lets print the text and href:

```ruby
pry(main)> browser.all('li a')
=> [#<Capybara::Element tag="a">, ...

pry(main)> browser.all('li a').class
=> Capybara::Result

pry(main)> browser.all('li a').class.ancestors
=> [Capybara::Result,
 Enumerable,
 Object,
 JSON::Ext::Generator::GeneratorMethods::Object,
 PP::ObjectMixin,
 Kernel,
 BasicObject]
```

So, it gives me back a `Capybara::Result`, but notice that we inherit from
Enumerable. I know how to deal with Enumerable!

```ruby
pry(main)> browser.all('li a').each { |a| puts a.text, "  #{a['href']}", "" }
News
  http://www.denverpost.com/breakingnews

Sports
  http://www.denverpost.com/sports

# ...
```

Great, we did it!
The real power of Capybara becomes apparent when you need to fill in forms,
follow redirects, be authenticated, upload files and all that jazz.

### What About Filling In Forms and Logging In?

Capybara is able to do more than request a page and look at its links.
It can fill in forms, too!
When you talk to a website, the website sets a header in the HTTP request called a cookie.
The browser then sends this back to the site whenever you interact with it.
This allows the site to set the cookie to be something that allows them to identify you.
Which, in turn, means they can do things like authenticate that you are the user
you say you are, and then store that in a cookie.
If you didn't send the cookie back, it would look like you weren't logged in.
So for us to crawl sites, we often need to remember the cookies the site has set,
and then re-submit them for all future requests.

If we call our current browsing process a "session",
then we will want to remember cookies for this session.
Fortunately, Phantom takes care of this for us,
it keeps track of the cookies the website has sent,
for the duration of our session, and continues to re-submit them.
This means that when we fill in a form to log into a website,
we will continue to be logged in.
You can configure Nokogiri, or other web crawling tools to log into your accounts,
and perform tasks for you, collect data for you, whatever it happens to be.

### Lets try it out!

Lets try submitting that form. I took a look at
[Capybara's readme](https://github.com/jnicklas/capybara#clicking-links-and-buttons),
under the sections about clicking links and buttons, and the section about interacting
with forms, and then used my web inspector to dtermine which things I wanted to
fill in and click on.

```ruby
pry(main)> browser.fill_in 'yahooSearchField', with: 'ruby'
=> true

pry(main)> internet.click_on 'Go'
=> {"status"=>"success", "position"=>{"x"=>983.5, "y"=>165}}

pry(main)> browser.current_url
=> "http://www.denverpost.com/circare/html/gsa_template.jsp?sortBy=mngi&similarTo=&similarType=find&type=any&aff=3&view=entiresitesppublished&query=ruby&searchbutton=Go"

pry (main)> browser.save_and_open_page
```

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

Our pry method works really well, and is usually what I turn to first.
But, docs are good too. The [Capybara readme](https://github.com/jnicklas/capybara)
has some great examples. And there is also
[API documentation](http://rdoc.info/gems/capybara/frames)
available.


### Things to consider:

* How do you want to store the data?
* What happens if you get 90% finished with the scraping, and then it blows up for some reason? Maybe you should persist the results ASAP, so you can skip work you've already done when you fix the error and rerun it.
* What are things that could break your scraper?

### Finished and bored?

* Got all the data? Nice. How about reading it in and generating a html page that lists all the books.
* Pull down other useful information, as well. How about the image and the relevant links.
