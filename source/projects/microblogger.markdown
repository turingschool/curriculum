---
layout: page
title: MicroBlogger
sidebar: true
---

In this multi-phase project, you will build a client that interacts with the Twitter messaging service. Your client will both mimic functionality found through the twitter.com web interface as well as perform many new tasks.

Learning Goals:

* Practice installing and using a gem library
* Writing methods and basic instructions
* Practice basic techniques including conditional branching and looping

<div class="note">
<p>The Twitter API and gem are constantly changing. We do our best to keep this tutorial updated, but sorry if things get confusing.</p>
</div>

<div class="note">
<p>This tutorial is open source. If you notice errors, typos, or have questions/suggestions, please <a href="https://github.com/JumpstartLab/curriculum/blob/master/source/projects/microblogger.markdown">submit them to the project on GitHub</a>.</p>
</div>

## Iteration 0: Up & Running


If you haven't already setup Ruby, visit [the environment setup page for instructions]({% page_url /topics/environment/environment %}).

Install the `jumpstart_auth` gem by running this instruction from your command prompt (Windows) or terminal (OS X):

{% terminal %}
$ gem install jumpstart_auth
Fetching: oauth-0.4.7.gem (100%)
Fetching: multipart-post-1.1.5.gem (100%)
Fetching: faraday-0.8.4.gem (100%)
Fetching: simple_oauth-0.1.9.gem (100%)
Fetching: twitter-3.7.0.gem (100%)
Fetching: jumpstart_auth-0.2.0.gem (100%)
Successfully installed oauth-0.4.7
Successfully installed multipart-post-1.1.5
Successfully installed faraday-0.8.4
Successfully installed simple_oauth-0.1.9
Successfully installed twitter-3.7.0
Successfully installed jumpstart_auth-0.2.0
6 gems installed
{% endterminal %}

Next, open your text editor such as SublimeText or Notepad++. Create a file named `micro_blogger.rb` and start it off with this structure:

```ruby
require 'jumpstart_auth'

class MicroBlogger
  attr_reader :client

  def initialize
    puts "Initializing"
  end
end
```

Let's see if that little program is ready to run. From your terminal/command prompt, start "Interactive Ruby" with this instruction:

{% terminal %}
$ irb
{% endterminal %}

You'll get a prompt that looks something like this:

{% irb %}
$
{% endirb %}

At that prompt, run these two instructions:

{% irb %}
$ require './micro_blogger'
true
$ blogger = MicroBlogger.new
Initializing
#<MicroBlogger:0x1014012b0>
{% endirb %}

### Dealing with OAuth

When connecting to a third-party service, from the developer's perspective, possibly the simplest form of authentication is passing the user's username and password. Unfortunately, this puts more work on the user and is less secure than more robust schemes such as OAuth. 

The OAuth authentication system is a more complex private/public key exchange that requires several steps and a difficult-to-follow workflow that requires a handshake with the remote service. So that we can focus on the important parts of this exercise, all this complexity has been pushed into the `jumpstart_auth` gem. You can use this library inside your initialize method...

```ruby
  def initialize
    puts "Initializing..."
    @client = JumpstartAuth.twitter
  end
```

To run this code, go back to IRB and use `load` to reprocess the file:

{% irb %}
$ load './micro_blogger.rb'
true
$ blogger = MicroBlogger.new
{% endirb %}

The first time this is run it'll use the `Launchy` gem to pop open your web browser and ask for permission to use your account. We've setup several test accounts with these credentials which will be distributed in class.

Twitter will then give you a pin number that's about 10 digits. Copy it to your clipboard, go over to your IRB session, and paste it in where the prompt says `Enter the supplied pin:`.

The result is that we have a `@client` variable which is our connection to Twitter. With that setup, we can move forward.

## Iteration 1: Posting Tweets

Now that we have the `@client` object, we need to know what methods are available from the library. The best information is available on the [project readme file here](http://rdoc.info/gems/twitter/file/README.md).

In the readme you'll find a section "Usage Examples" which clues you into some of the functions exposed by the library.

### Step 1 - Write the `tweet` Method

Now add the the following method to your class:

```ruby
def tweet(message)
   @client.update(message)
end
```

Then at the very end of the file, add these lines as an execution script:

```ruby
blogger = MicroBlogger.new
blogger.tweet("MicroBlogger Initialized")
```

Then run your code by going to your terminal an entering:

{% terminal %}
$ ruby micro_blogger.rb
{% endterminal %}

You should see the output say `Initializing`. Now go to your test account's Twitter page and look for your results!

#### Step 2 - Length Restrictions

Twitter messages are limited to 140 characters. Experiment with your current program and see what happens if your try to call `tweet` with a message longer than 140. Let's create some error checking that will prevent the user from posting messages longer than 140.

Inside your `tweet` method, write an `if`/`else` block that performs the following logic:

* If the message to tweet is less than or equal to 140 characters long, tweet it.
* Otherwise, print out a warning message and do not post the tweet.

Test your new `tweet` method with a message that is less than 140 characters, one that is exactly 140 characters, and one that's longer than 140 characters.

How do you get a string that's exactly 140 characters?  Here's how I did it in `irb`:

```ruby
puts "".ljust(140, "abcd")
```

## Iteration 2: A Better Interface

Our client is off to a good start, but the interface sucks. We have to change lines in the Ruby file for each tweet we want to send -- that's not reasonable!

Let's build an interactive prompt interface to run our program.

#### Step 0 - Outline the Process

First, let's define a method named `run` which will be the instruction that gets repeated over and over:

```ruby
  def run
    puts "Welcome to the JSL Twitter Client!"
  end
```

Then go to the last line of your program and change it to `blogger.run`.

Run your program at the command line with `ruby micro_blogger.rb` and you should just see the line "Welcome to the JSL Twitter Client!"

#### Step 1 - The Loop

Underneath the `puts` line we'll use a `while` loop to repeat instructions over and over. Add these lines below the `puts` but before the `end`:

```ruby
  command = ""
  while command != "q"
    printf "enter command: "
  end
```

Remember that you can exit a running Ruby application by pressing *Control-C* if you just so happen to get in an infinite loop.

Go ahead and run that program and you should see the "enter command: " string over and over. Why?

The `while` loop will keep repeating until the variable `command` contains the value `"q"`. Since we set `command` to the empty string and aren't changing it, the loop continues forever.

Also, you might wonder what `printf` is about. Why not `puts`?  The difference is that `printf` prints text and leaves the cursor there, while `puts` prints text then starts a new line. For our interface, we'll have the prompt and the command on the same line.
 
#### Step 2 - Accepting Input

In Ruby we can accept user string with the `gets` command. Add this line below your `printf`:

```ruby
  command = gets
```

Now run your program again and it'll wait for you to enter commands. Try typing some things in. Try entering a `q` to quit.

It doesn't work, right?  There's a little gotcha with using `gets` -- it picks up the enter key too. So your `command` variable is actually getting the string `"q\n"` where that backslash-n is a new line. The fix is to change `gets` to `gets.chomp`. The `chomp` method will remove any whitespace (spaces, tabs, newlines) on the back end of a string.

After you add the `chomp` try your program again and you should be able to quit with just `q`.

#### Step 3 - Starting a Case Statement

We think we're getting the instruction from the user, but we need to actually do something with it. We'll use what's called a *case statement*. Case statements in Ruby look like this:

```ruby
  case input
    when "a" then puts "It's an A!"
    when "b" then puts "It's a B!"
    when "c" then puts "It's a C!"
    else
      puts "It's something else!"
  end
```

Ruby will look at the variable `input` and see what value it holds. If the value matches one of the `when` lines, then it'll do the instruction(s) that follow that line's `then`. If it doesn't match any of the `when` lines, it'll run the `else`.

Start with this case statement in your method just below the `command = gets.chomp` line:

```ruby
  case command
    when 'q' then puts "Goodbye!"
    else
      puts "Sorry, I don't know how to #{command}"
  end
```

Run your program and test some commands.

#### Step 4 - Tweeting & Parameters

Let's make this thing work for our tweet method. Add a `when` line that is run when the `command` is `"t"`. Have it call our `tweet` method.

Run your program and try entering `t This is only a test!`. 

You should see output like `Sorry, I don't know how to (t This is only a test!)`. I wanted it to call the `tweet` method because I started the line with `t`, but then the rest of the line was my message. Instead, it thought the whole line was the command. We need to divide up the input between the command and the text that should be sent to that command.

There are a few ways we could accomplish this, but we'll use the most straightforward method.

##### Making the Command-Line Interface Smarter

The line `command = gets.chomp` is kind of telling a lie. It isn't just getting the `command`, it's getting a `command` and a message to send to that command. Lets change this line to `input = gets.chomp` then we'll work with `input` to pull out the command.

Now that we have `input` we need to split it up into pieces. We'll cut it up using the `split` method. Just below the `input = gets.chomp` add a line that says `parts = input.split(" ")` to chop `input` into `parts`.

`split` will take our input string (entered by the user at the
command line) and chop it into an array of smaller strings based on the given parameter.

For example, if the user gave the input: `t tweet my message`

Our `input = gets.chomp` would produce a `parts` array that looked like this: `["t", "tweet", "my", "message"]`

Knowing the structure of this array will allow us to pull out the
parts we need at various places in our program. In the example `parts` array above, `t` is the command we're looking for, so let's pull it out by saying `command = parts[0]`.

Then what do we do with the rest of the `parts`?  They're our message. Our `tweet` method is expecting to be passed in a message, so we need to reassemble the message and add it to our `when` line. In order to get the whole message I'll grab `parts[1..-1]` which gives me all the words in the message from index 1 to the end of the array (-1). That basically just skips the `command` that's in `parts[0]`. 

But those `parts[1..-1]` are individual word strings, I need to join them into a single string. We can use the `join` method and tell it to connect the words with a space like this: `parts[1..-1].join(" ")`. Using that idea in the `when` line for `t`, here's what my method looks like right now:

```ruby
  def run
    command = ""
    while command != "q"
      puts ""
      printf "enter command: "
      input = gets.chomp
      parts = input.split
      command = parts[0]
      case command
         when 'q' then puts "Goodbye!"
         when 't' then tweet(parts[1..-1].join(" "))
         else
           puts "Sorry, I don't know how to (#{command})"
      end
    end
  end  
```

Try it out and you should finally be able to post tweets over and over!

## Iteration 3: Send Direct Messages

Sending Direct Messages isn't that different from posting a tweet. In fact, we can reuse our existing `tweet` method to do all the hard work.

#### Step 0 - Frameworks

```ruby
def dm(target, message)
  puts "Trying to send #{target} this direct message:"
  puts message
end
```

And we need to add the command to our `run` method. We'll enter the instruction like `dm jumpstartlab Here is the text of the DM`, so our `when` line should look like this:

```ruby
  when 'dm' then dm(parts[1], parts[2..-1].join(" "))
```

Remember that `parts[0]` is the command itself, here `dm`. Then `parts[1]` will be the target username, here `jumpstartlab`. Then everything else is the message, so we join them with spaces `parts[2..-1].join(" ")`.

#### Step 1 - Create and Send the Message

First, inside your `dm` method, create a new string that is a combination of "d", a space, the target username, a space, then the message. 

Then call the `tweet` method with this new string as the parameter message. 

Try sending a DM to your personal Twitter account. Try sending yourself a DM. If the DM doesn't show up it is probably because you can only send DMs to people who are following you. Start following your `your_testing_account_username` account from your personal account and try it again.

#### Step 2 - Error Checking DM-ability

You can only DM people who are following you. As you saw in Step 1, if you try and DM someone else, though, it doesn't give you an error message. It just fails silently.

Let's add a way to verify that the target is following you before sending the message. In pseudo-code, it'd go something like this:

* Find the list of my followers
* If the target is in this list, send the DM
* Otherwise, print an error message

We can call `@client.followers` which gives us back a list of all our followers but includes lots of information we don't need right now like their follower count, web address, last tweet. All we want is to find their `screen_name`.

What we need to do is pull out just the `screen_name`. We create an array of the followers' screen names with this line of code:

```ruby
screen_names = @client.followers.collect{|follower| follower.screen_name}
```

To read this line out loud it would be like "Call the `followers` method of `@client`, then take that array and, for each element in the array, `collect` together the value of `screen_name`.

Now you have an array of your followers' screen names. Create a conditional block that follows this logic:

* If the `target` username is in the `screen_names` list (use [Array#include?](http://rubydoc.info/stdlib/core/Array#include%3F-instance_method) method), then send the DM
* Otherwise, print out an error saying that you can only DM people who follow you

Test your code by sending a DM to someone who does follow your demo account and someone who does not.

#### Step 3 - Spamming Your Friends

It would be cool to be able to send the same message out to all of our followers. We'll accomplish this in two parts:

* Create a method named `followers_list` that returns an array containing the usernames of all my followers
* Create a method named `spam_my_followers` that finds all followers from `followers_list` and tries to send them a Direct Message using the `dm` method

To create the `followers_list` method...

* Define the method named `followers_list` with no parameters
* Create a blank array named `screen_names`
* On the `@client` call the `followers` method then the `users` method and iterate through `each` of them performing the instruction below:

```ruby
  screen_names << follower["screen_name"]
```

* Return the array `screen_names`

Then for the `spam_my_followers` method...

* Define the method named `spam_my_followers` with a parameter named `message`
* Get the list of your followers from the `followers_list` method
* Iterate through `each` of those followers and use your `dm` method to send them the `message`

Then create a `when` line in your `run` method for the command `spam`. It will look just like the `tweet` line, except it'll send the message into the `spam_my_friends` method.

Test it out and see how many followers you can annoy at once!

## Iteration 3: Last Tweet from All Friends 

So now you can post tweets and DMs. There are hundreds of clients that can do that. If you're a normal twitter user you follow some people who post several times per day and some people who post once per week. It can be difficult to see everyone. Lets create a list of the last tweet for each person you follow.

#### Step 0 - Framework

Here it is in pseudocode:

* Find the list of people you follow

* For `each` member of the list...
    - Find their latest tweet
    - Print out their `screen_name` and latest tweet

Turn that into code like this...

```ruby
  def everyones_last_tweet
    friends = @client.friends
    friends.each do |friend|
      # find each friend's last message
      # print each friend's screen_name
      # print each friend's last message
      puts ""  # Just print a blank line to separate people
    end
  end
```

Add a `when` line to your `run` method for this instruction. I'm using the instruction `elt` so my `when` line is just `when 'elt' then everyones_last_tweet`. Once added, restart your program and try it out.

#### Step 1: Finding the Last Messages

When you call the `friends` method you get an array list where each element of the array is an object representing one friend. The object has all the information about an individual friend such as `screen_name`, `id`, `followers_count`, etc. Here are the useful properties that it has:

```ruby
[:all_replies, :blocking, :can_dm, :connections, :contributors_enabled, :default_profile, :default_profile_image, :description, :favourites_count, :follow_request_sent, :followed_by, :followers_count, :following, :friends_count, :geo_enabled, :id, :is_translator, :lang, :listed_count, :location, :marked_spam, :name, :notifications, :notifications_enabled, :profile_background_color, :profile_background_image_url, :profile_background_image_url_https, :profile_background_tile, :profile_image_url, :profile_image_url_https, :profile_link_color, :profile_sidebar_border_color, :profile_sidebar_fill_color, :profile_text_color, :profile_use_background_image, :protected, :screen_name, :statuses_count, :time_zone, :url, :utc_offset, :verified, :want_retweets, :all_replies?, :blocking?, :can_dm?, :contributors_enabled?, :default_profile?, :default_profile_image?, :follow_request_sent?, :following?, :followed_by?, :favorites, :favorites_count, :favourites, :followers, :friends, :geo_enabled?, :is_translator?, :listed, :marked_spam?, :notifications?, :notifications_enabled?, :profile_background_tile?, :profile_use_background_image?, :protected?, :statuses, :translator, :translator?, :updates, :verified?, :want_retweets?, :status, :created_at, :credentials, :credentials?, :attrs, :attrs, :to_hash, :[]]
```

So for each of those `friend` objects, if you call `friend.followers_count` you'll get their number of followers. Or use `friend.id` to get their unique Twitter ID number.

`status` contains their last tweet, but there's a catch -- `status` is ANOTHER complex object, not simply a string. The `status` object has these properties and methods:

```ruby
:favorited, :from_user, :from_user_id, :from_user_name, :id, :in_reply_to_screen_name, :in_reply_to_attrs_id, :in_reply_to_status_id, :in_reply_to_user_id, :iso_language_code, :profile_image_url, :retweet_count, :retweeted, :source, :text, :to_user, :to_user_id, :to_user_name, :truncated, :favorited?, :retweeted?, :truncated?, :expanded_urls, :geo, :media, :metadata, :place, :user, :retweeted_status, :oembed, :created_at, :attrs, :attrs, :to_hash, :[]]
```

So if you want to access one of these pieces of data you'd call it like this: `friend.status.created_at` or `friend.status.source`.

Now that you understand the hashes available to you, implement code for the three commented lines in our `everyones_last_tweet` method. RUN your program and you should see output kinda like this:

{% terminal %}
MicroBlogger Initialized
rsturim said...
the raw bar is open

amyhoy said...
along with our candlelit dinner in the garden, charming brass music drifted over the hills from nearby. as if it were just for us.

wonderwillow said...
`ChrisMacDen fab idea. Do you know of good resources?
{% endterminal %}

#### Step 2: Improving the Output

Getting each friend's last message was cool, but they're in some random order. Sort them by the `screen_name` in alphabetical order!  I want you to hack out the code, but the way I did it would read like this: 

"take the friends list and use the [Array#sort_by](http://rubydoc.info/stdlib/core/Enumerable#sort_by-instance_method) method, then call each one `friend` and find the `friend.screen_name`". You might look at how you used `sort_by` in EventManager for syntax clues. (NOTE: Ruby considers all capital letters to come earlier in alphabetical order than lowercase letters. To keep all your letters together regardless of capitalization, change `friend.screen_name` to `friend.screen_name.downcase` when sorting)

Second, these messages are lacking any time context. The `status` hash has a key named `created_at` which holds a string like this one: `Thu Jul 23 23:31:16 +0000 2009`. That's the information we need, but it's in an ugly format. Use these steps to make the data more useable:

```ruby
timestamp = friend.status.created_at

#Then, when you want to print the date, it can be formatted like this:
timestamp.strftime("%A, %b %d")
```

[DateTime#strftime](http://rubydoc.info/stdlib/date/DateTime#strftime-instance_method) 
is my most hated method in Ruby because every time I use it I need to
lookup the dumb parameters. The `"%A, %b %d"` that I gave you will cause it to
output the date formatted like `Wednesday, Jul 29`. Implement the sorting and
the timestamping to create output that looks like this:

{% terminal %}
MicroBlogger Initialized
abailin said this on Wednesday, Jul 29...
RT `JackiMieler: `abailin Amen! Be sure to spread the word about the facts of this story - http://tinyurl.com/mt3gfx - vs. the fictitous

AlexSenn said this on Tuesday, Jan 13...
Is looking for a cute condo in Atlanta...2 bedroom, 2 bathroom...any suggestions, let me know!

americasvoice said this on Wednesday, Jul 29...
Frank Sharry on Huffington Post: GOP Latino Outreach Strategy: Oppose, Ignore, Aggravate and Scapegoat - http://bit.ly/1jbpxo #topptog #tcot

amyhoy said this on Wednesday, Jul 29...
along with our candlelit dinner in the garden, charming brass music drifted over the hills from nearby. as if it were just for us.
{% endterminal %}

## Iteration 4: Shorten URLs with Bit.ly

There's a great library which can be used to automatically create shortened URLs. Let's add this functionality into our project.

#### Step 0 - Testing the Library

First, go into Terminal and run this line:

{% terminal %}
$ gem install bitly
{% endterminal %}

Next, open `irb` and try out the following:

```ruby
require 'bitly'

Bitly.use_api_version_3

bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
puts bitly.shorten('http://jumpstartlab.com/courses/').short_url
```

It might take a few seconds, but you should now have a shortened URL from Bitly's shortner service. Try it out in your browser to make sure it works.

#### Step 1 - Framework

Create this method:

```ruby
def shorten(original_url)
  # Shortening Code
  puts "Shortening this URL: #{original_url}"
end
```

Add a `when` line to your `run` method so that the command `s` will take one parameter and send it into the `shorten` method.

#### Step 2 - Implement the Method

Look at the model for Bitly that we used in Step 0 and use it to fill in the shortening code of your `shorten` method. Make sure that your method ends with a `return` statement so it sends the shortened URL that to the method called it.

#### Step 3 - Tweet with URL

How can we shorten a url while posting a tweet?  There are a few ways to do it. Here's an easy one:

Add a `when` line in your `run` method for the command `turl` which stands for "Tweet with URL". Make it accept commands that look like this:

`turl I wrote this twitter client at: http://jumpstartlab.com`

You know that `parts[0]` is the command, `parts[1..-2]` are the message, and `parts[-1]` is the URL to be shortened. You can put that all together like this:

`tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))`

Get that working and you're done with the twitter client!

## Iteration 5: The Klout API

Let's continue experimenting with various APIs.

Klout (klout.com) is a service that, "measures influence on social networks." The Klout service analyzes a variety of networks to determine an individual's "Klout Score." Measured from 0 to 100, a higher Klout Score indicates greater influence on various social networks.

Klout offers a free public API that lets you retrieve Klout scores by simply providing a Twitter username. Let's attempt to retrieve the Klout Score of all the users you follow and see who has the greatest influence!

#### Step 0 - Testing the API

First, hop into Terminal and run this line:

{% terminal %}
$ gem install klout
{% endterminal %}

Next, open `irb` so you can experiment with the Klout API. Run the following lines:

{% irb %}
$ require 'klout'
$ Klout.api_key = 'xu9ztgnacmjx3bu82warbr3h'
$ identity = Klout::Identity.find_by_screen_name('jack')
$ user = Klout::User.new(identity.id)
$ user.score.score
=> 74.61
{% endirb %}

While the format of the second command may be a bit confusing, you're simply asking Klout to return a user's Klout Score in a format you can read and interpret. In this example, you've provided the Twitter username `jack` (the original creator of Twitter), and Klout returned the value `74.61`. You can easily change out `jack` for any other Twitter username, so let's obtain the Klout Score for everyone you follow!

#### Step 1 - Require Klout

First, you'll want to require the Klout gem in your MicroBlogger implementation, and make sure you can make requests to the Klout service. At the top of your `micro_blogger.rb` file, insert the following just below require `jumpstart_auth`:

```ruby
require 'klout'
```

Next, in your initialize method, insert the following:

```ruby
Klout.api_key = 'xu9ztgnacmjx3bu82warbr3h'
```

Great! Now you're set up to make requests to Klout's API!

#### Step 2 - Obtain Klout Scores

You've already written logic to obtain a list of your friends, which looks something like this:

```ruby
screen_names = @client.friends.collect{ |f| f.screen_name }
```

If you wanted to write a method that prints out the Klout score for all of your friends, its logic would be structured something like this:

* Obtain a list of all your friends, and save that list inside a variable named `screen_names` (this is done using the method above).
* Step through the list of friends. For each `friend`, issue a request to Klout to obtain their Klout score.
* Print out each `screen_name` followed by their Klout score.

Here's the basic setup for this method, you can fill in the gaps:

```ruby
  def klout_score
    friends = @client.friends.collect{|f| f.screen_name}
    friends.each do |friend|
      # print your friend's screen_name
      # print your friends's Klout score
      puts "" Print a blank line to separate each friend
    end
  end
```

Once you're finished, test the method by inserting the following line at the bottom of the `micro_blogger.rb` file:

```ruby
blogger.klout_score
```

  and then run the program. Who has the highest Klout score amongst your friends?
