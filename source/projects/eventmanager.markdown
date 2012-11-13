---
layout: page
title: EventManager
sidebar: true
alias: [ /eventmanager, /event_manager.html ]
---

In this project you'll work with the attendee data for a conference supplied in a CSV file. This data comes from an actual conference, though identifying information has been masked.

The techniques practiced in this lab include:

* Basic file input and output
* Working with CSV (Comma Separated Value) files using the CSV library
* String manipulation techniques
* Basic looping and branching instructions
* Accessing a web-based API

<div class="note">
<p>This tutorial is open source. If you notice errors, typos, or have questions/suggestions, please <a href="https://github.com/JumpstartLab/curriculum/blob/master/source/projects/eventmanager.markdown">submit them to the project on Github</a>.</p>
</div>

## Bootstrap

If you haven't already setup Ruby, visit [the environment setup page for instructions]({% page_url /topics/environment/environment %}).

### Dependencies

We'll use just one external gem during the main sections of the tutorial. Install it with the following command and your terminal:

{% terminal %}
$ gem install sunlight
Fetching: ym4r-0.6.1.gem (100%)
Fetching: sunlight-1.1.0.gem (100%)
Successfully installed ym4r-0.6.1
Successfully installed sunlight-1.1.0
2 gems installed
{% endterminal %}

### Folder & File Setup

Create a folder named `event_manager` wherever you want to store your project. In that folder, use your text editor to create a plain text file named `event_manager.rb`

### Initial Skeleton

Start with this code framework:

```ruby
# Dependencies
require "csv"

# Class Definition
class EventManager
  def initialize
    puts "EventManager Initialized."
  end
end

# Script
manager = EventManager.new
```

### Running the Program

In the terminal:

{% terminal %}
$ cd event_manager
$ ruby event_manager.rb
EventManager Initialized.
{% endterminal %}

## Iteration 0: Basics of a CSV File

CSV files are great for storing and transporting large data sets. They're most commonly created from spreadsheets, but since a CSV is really just a plain text file, they're pretty easy to interact with from ANY program.

### Accessing the Data File

The first thing to do is open the file. We can do that by adding in the `CSV` line to our `initialize` method:

```ruby Gemfile
# Dependencies
require "csv"

# Class Definition
class EventManager
  def initialize
    puts "EventManager Initialized."
    filename = "event_attendees.csv"
    @file = CSV.open(filename)
  end
end

# Script
manager = EventManager.new
```

Run the program and you should get an error that starts like this:

{% terminal %}
$ ruby event_manager.rb
No such file or directory - event_attendees.csv (Errno::ENOENT)
{% endterminal %}

If you get an error like 'wrong number of arguments (1 for 2) (ArgumentError)',
you may need to change the line with `open` to this:

```ruby
@file = CSV.open(filename, "rb")
```

This should fix the error, and give you the "No such file or directory" one.

### Setup `event_attendees.csv`

Download the file [event_attendees.csv](/assets/eventmanager/event_attendees.csv) and store it into the *same directory as your `eventmanager.rb`*. Then re-run your program and you should see this:

{% terminal %}
$ ruby event_manager.rb
EventManager Initialized.
{% endterminal %}

Now that our file is getting loaded properly we have a name for that variable - `@file`. We can talk to that object named `@file` and ask it questions or tell it to do things.

### Reading Data from the File

Now that we can open the file, let's read out some data.

#### Understanding the File Data

The first question to ask is "how do we read the individual lines of the file?" The CSV object implements the `Enumerable` interface which means that, among other things, you can use the `each` method to go through the collection one-by-one.

Here, we can access one line at a time with this loop:

```ruby
@file.each do |line|
  # Do Something
end
```

But what is that `line` object? Is it a String? An Array? Check it out by writing this method:

```ruby
  def print_names
    @file.each do |line|
      puts line.inspect
    end
  end
```

With the method inside the class, we need to call it from our script. At the bottom of your project file add the line `manager.print_names` like this:

```ruby
manager = EventManager.new
manager.print_names
```

Then *run the program* using the terminal. You'll see that the `line` object looks like an Array.

#### Default Reading

We can access individual fields within that array by their position.

If you look at the data file, you'll see that the first name is in the third column. Since an array is zero-indexed, the third column is position `2`. So we can print the first names like this:

```ruby
  def print_names
    @file.each do |line|
      puts line[2]
    end
  end
```

Test it, see that it's working, then modify this method to print both the first *and* last names for each line.

#### Looking for Headers

Using numbers to access the array isn't very clear. When you look at the code, which position is the first name and which is the last name? It's impossible to know without looking at the data file.

The data file begins with a row of headers labeling each column. The CSV library can read these headers and use them to organize the data.

Look in your `initialize` method, and add the extra `:headers` parameter to the `@file` line like this:

```ruby
@file = CSV.open(filename, {:headers => true})
```

Run your existing `print_names` method and it should still work the same.

Then, try calling `inspect` on the line object again:

```ruby
  def print_names
    @file.each do |line|
      puts line.inspect
      #puts line[2] + " " + line[3]
    end
  end
```

Note that the `#` comments out the line so it won't be executed.

When you look at the output, you'll see that `line` now looks like a Hash. It has keys like `"HomePhone"` and `"City"`. Now, *use the keys instead of array positions* to print out the first and last names.

#### Converting to Symbols

It's annoying that the weird header name formatting, with its inconsistent capitalization, is now polluting our program. The CSV library provides a way to help standardize the headers, triggered by adding another option to the loading:

```ruby
@file = CSV.open(filename, {:headers => true, :header_converters => :symbol})
```

Now, in your `print_names` method, use `.inspect` to look at the structure of the `line` object. Update your `puts` instruction to use the newly standardized column names.

## Iteration 1: Cleaning Up the Phone Numbers

Open the CSV file in a spreadsheet program like Excel or OpenOffice. Look at the phone number column -- see how they're "dirty"?  Some have parentheses, some have hyphens, some periods. It's a mess; let's clean it up.

### Step 0 - Print What's There

Create a method named `print_numbers` that does the same thing as your existing `print_names` method, but print the phone number from `line[:homephone]`.

At the bottom of your program change the `manager.print_names` line to `manager.print_numbers`. Run your program and you should see the existing phone numbers scroll by.

### Step 1 - Removing Periods

When you're cleaning up data, the process goes something like this:

* Copy the original data
* Remove the junk
* Output the newly cleaned data

Simple, right?  Let's first remove the periods that some people put in their phone numbers. Change the body of your `print_numbers` method to match this:

```ruby
    @file.each do |line|
      number = line[:homephone]
      clean_number = number.delete(".")
      puts clean_number
    end
```

Run your program and you should see the numbers scroll by again. There's still plenty of junk in there (parentheses, hyphens, etc), but *there are no periods*!

### Step 2 - Removing Parentheses, Hyphens, and Spaces

Now we need to remove the other junk characters. Try working with the `delete` and `delete!` methods to clean up all right parentheses, left parentheses, hyphens, and blank spaces. RUN your program and you should see better data coming out like this:

{% terminal %}
$ ruby event_manager.rb
EventManager Initialized.
6143300000
6176861000
503278000
7579713000
...
9522007000
8146673000
19194755000
8282844000
bl000
6512603000
{% endterminal %}

Not perfect, but getting better.

### Step 3 - Checking Length

We've removed extraneous characters, but there are still some problems. Some of the numbers are "long" because they have a leading 1 on the front. A few of them are too short. A few others are just garbage -- like a misplaced email address or just some letter/number junk. Let's fix these problems by looking at the number's length.

The ideal length for our numbers is 10 total digits. We could write what's called "pseudocode" like this:

* If the number is 10 digits long
  * It's good
* If it's 11 digits long
  * Is the first number a 1?
    * If so, cut it off the leading 1
    * If not, it's junk
* Otherwise
  * It's junk.

Now we can translate that into real code using the `if`, `elsif`, and `else` like this:

```ruby
if number.length == 10
  # Do Nothing
elsif number.length == 11
  if number.start_with?("1")
    number = number[1..-1]
  else
    number = "0000000000"
  end
else
  number = "0000000000"
end
```

Insert that into your `print_numbers` method. RUN the resulting code and you should see nicely formatted numbers like this:

{% terminal %}
$ ruby event_manager.rb
EventManager Initialized.
3363171000
3363171000
2024818000
...
5034758000
8054481000
8145711000
{% endterminal %}

### Step 4 - Refactoring

*Refactoring* is an important part of programming -- it means taking working code and reorganizing it to make more sense, be more maintainable, and be more flexible for the future.

#### Splitting a Method

We've created a `print_numbers` method that prints out good-looking phone numbers, but we're lying a little bit. It's not just *printing* numbers; it's *cleaning* them then *printing* them. If we're doing two things they should be split up into two methods.

Create a method named `clean_number` that looks like this...

```ruby
  def clean_number(original)
    # Insert your "cleaning" code here
    return number  # Send the variable 'number' back to the method that called this method
  end
```

Note the comments that start with a `#` symbol. When you put a `#` the Ruby interpreter ignores everything after it on that line. So if we put a `#` then we can follow it with notes explaining what's going on with that code. Comments are just for your information.

See where we have the `original` variable next to the name of the method?  That's called a *parameter*. A parameter is some input that you need to put into an instruction so it can do what it's supposed to do. Without the parameter the instruction doesn't makes sense.

In order to perform `"clean_number"`, we need to give it the number to clean. Cut and paste your cleaning code from the old `print_numbers` method and put it into `clean_number`. After removing that code from `print_number` make it look like this:

```ruby
  def print_numbers
    @file.each do |line|
      number = clean_number(line[:homephone])
      puts number
    end
  end
```

Test your refactored code and make sure it still works properly.

If you're generating errors, check that the variables in your `clean_number` method make sense. You're starting with the incoming number named `original` and should end with the cleaned number named `number`.

## Iteration 2: Cleaning up the Zip Codes

When we got this file the zipcode data was a little surprising.

### Step 0: Print out What's There & Diagnosis

Why were so many of the zipcodes entered incorrectly?  Look at a few example addresses and zipcodes...

```bash
1 Old Ferry Road, Box # 6348	Bristol	RI	2809
90 University Heights , 401h1	Burlington	VT	5405
123 Garfield Ave	Blackwood	NJ	8012
239 S Prospect St	Burlington	VT	5401
50 Ledgewood Dr	York	ME	3909
```

See the pattern?  Most of the short zipcodes are in the Northeast, where many zipcodes start with a `0`. The ticket database must have stored the zipcode as an integer, which trimmed off the leading zero. Now that we know the problem, we can fix it.

Let's write a method to print out the current zipcodes from the CSV. We'll call it `print_zipcodes` and model it after our `print_numbers` method:

```ruby
  def print_zipcodes
    @file.each do |line|
      zipcode = line[:zipcode]
      puts zipcode
    end
  end
```

Run that and you should see the list of uncleaned zipcodes scroll by.

### Step 1: Zero-Padding Existing Zipcodes

Let's write a little pseudo-code:

* If the zipcode is less than 5 digits, add zeros on to the front until it becomes five digits
* If the zipcode is exactly 5 digits, assume it's ok

#### Beginning the Implementation

Turning that into code we should create a `clean_zipcode` method. Model it after the structure of your `clean_number` method. Name the parameter `original` like we did in `clean_number`. Assuming you have that structure we can start to map out the method's code...

```ruby
  def clean_zipcode(original)
    if original.length < 5
      # Add zeros on the front
    else
      # Do nothing
    end

    #return the result
  end
```

Then, to use it:

* In your `print_zipcodes` method change `zipcode = line[:zipcode]` to `zipcode = clean_zipcode(line[:zipcode])`
* Change the instruction at the very bottom of the script from `manager.print_numbers` to `manager.print_zipcodes`
* Run the program and see if it fixes the short zipcodes

#### Dealing with `nil`

Uh-oh. Did you get an error? The program got through a bunch of the zipcodes then spat this out:

{% terminal %}
$ ruby event_manager.rb
'clean_zipcode': undefined method `length' for nil:NilClass (NoMethodError)
{% endterminal %}

In this case, CSV is giving us a `nil` if the CSV file doesn't have any information in the zipcode cell.

Dealing with `nil` values in your code can be a huge pain in the neck. The situation we have now is very typical: you write code that works great for most of the cases, then it hits one `nil` and blows up. Most frequently these problems are generated by trying to call methods or access attributes of `nil`. The solution, then, is to check if the zipcode is `nil` before doing other things to it.

Here's one approach to protect against nil:

```ruby
  def clean_zipcode(original)
    if original.nil?
      result = "00000"  # If it is nil, it's junk
    elsif length < 5
      # Add zeros on the front
    else
      # Do Nothing
    end

    #return the result
  end
```

#### Adding the Zeros

The zipcodes that are missing their leading zeros are mostly four digits long, so just adding one zero to the front would probably fix it. But 00601, for instance, is a valid zipcode. In our data there are a few of these two-leading-zero zipcodes.

There are several ways you can do this:

* Using a `while` or `until` loop
* Calculating the number of missing zeros and adding them to the front
* Adding a fixed number of zeros to the front and trimming the result
* Using a method from the String API for buffering strings to a certain length

See if you can make each of the four work!

### Step 2: Test & Refactor

The Ruby community has a saying "Keep it DRY" where DRY means Don't Repeat Yourself. Whenever you do the same thing twice you introduce the possibility for mistakes down the road. Try to cut any repetition down inside your code.

If you implemented more than one of the solutions for adding the zeros, which one best communicates the purpose? That's the one you should use.

#### Magic Numbers

Lastly, the invalid zipcode is a "Magic Number" inside the logic of your program. It's likely that, during the lifetime of the program, this marker will change. And that shouldn't really mean changing the logic of our program.

To improve the situation we should introduce a *constant*. A constant is a special variable that we don't change, think of it as a way to give a name to a piece of data throughout our program. In Ruby, a constant starts with a capital letter and is usually written in all caps like this:

```ruby
INVALID_ZIPCODE = "00000"
```

We normally define constants near the top of the class like this:

```ruby
class EventManager
  INVALID_ZIPCODE = "00000"
  #...everything else...
end
```

Then use the `INVALID_ZIPCODE` constant instead of the string `"00000"` in your `clean_zipcode`.

Similarly, use another constant `INVALID_PHONE_NUMBER` instead of the string `"0000000000"` in your `clean_number`.

RUN it and make sure there are no errors and the data looks good, then we're ready for the next iteration!

## Iteration 3: Outputting Cleaned Data

We've done good work cleaning the zipcodes and phone numbers. Let's now output the clean data to a new file.

### Step 0: Print Out What's There

Let's create a method that'll handle writing out the file:

```ruby
  def output_data
    output = CSV.open("event_attendees_clean.csv", "w")
    @file.each do |line|
      output << line
    end
  end
```

Then change the line at the bottom of your program from `manager.print_zipcodes` to `manager.output_data`. Run the program, check that no errors were generated, then look in your project folder and you should see a file `event_attendees_clean.csv`.

Open that file (with Excel, Numbers, OpenOffice, or a text editor) and see that it looks like the original -- almost. It's missing the headers.

### Step 1: Headers

How do we get the headers for the CSV? There are a few options, but the easiest is to ask one of the CSV line objects. Each line has a method `headers` that will return an array of the headers. So our method could look like this:

```ruby
  def output_data
    output = CSV.open("event_attendees_clean.csv", "w")
    @file.each do |line|
      # if this is the first line
      #   output the headers
      output << line
    end
  end
```

How do we figure out if it's the first line? The CSV object, stored in `@file`, has a `lineno` method that tells you what line it's on. Write an `if` condition that checks if `@file.lineno` is equal to 2. If it is, output the headers with `output << line.headers`.

### Step 2: In-Place Phone Number and Zipcode Cleaning

The `line` object we've been working with is loaded into memory using the data in the original file. Since it's in memory, we can make changes to `line` itself without affecting the original file:

```ruby
line[:homephone] = clean_number(line[:homephone])
```

#### Outputting the Clean Phone Number

Reading this line would start on the right side and sound like "Take the value of `line[:homephone]`, put it into the `clean_number` method, then take the return value that the method gives you back and store it into `line[:homephone]`."

Looking at your `output_data` method, add this line right before `output << line`. Try running the code and verify that the phone numbers are cleaned up in the output file.

#### Outputting the Clean Zipcode

Next, add a similar instruction that sends `line[:zipcode]` into the `clean_zipcode` method and stores it back into `line[:zipcode]` before sending the `line` out to the output file. RUN these new instructions and check out the `event_attendees_clean.csv` file -- does all the data look cleaned up?  It should!

### Step 3: Refactoring

Now that we've created a second file we have a little problem. Our program is going to keep accessing the "dirty" data file because that's what's specified in our `initialize` method. But we want the flexibility to open either the dirty or clean data files, or really any new files too. What should we do?  We need to _parameterize_ our filename.

1. Look at the `initialize` method. See how it has the `filename` in the method body? Remove that line and make `filename` a parameter to `initialize`.
2. Go to the script at the bottom of the file and change the line `manager = EventManager.new` to read `manager = EventManager.new("event_attendees.csv")`.
3. Go to the working folder and delete the file `event_attendees_clean.csv`
4. Run the program and see if the `event_attendees_clean.csv` is correctly regenerated

#### Setting the Output Filename

Let's also parameterize the filename inside `output_data`:

1. Add a parameter `filename` to the `output_data` method
2. Change the actual filename in the `CSV.open` method call to the variable `filename`
3. In the script, change `manager.output_data` to `manager.output_data("event_attendees_clean.csv")`
4. Delete the cleaned CSV file and run everything again to make sure it's working properly.

## Iteration 4: Congressional Lookup

This conference was about a political issue, and we wanted the participants to interact with their congresspeople. Since we already have their zipcodes we can take advantage of an API from the Sunlight Foundation to lookup the appropriate congresspeople.

### Step 0: Framework

Create a method that looks like this:

```ruby
  def rep_lookup
    20.times do
      line = @file.readline

      representative = "unknown"
      # API Lookup Goes Here
      puts "#{line[:last_name]}, #{line[:first_name]}, #{line[:zipcode]}, #{representative}"
    end
  end
```

This is a little different than the other methods we've started with. The first part that will stand out is this:

```ruby
    20.times do
      line = @file.readline
```

The CSV library reads one line at a time. Now that we're accessing a public API, it's unkind to generate the traffic of looking up thousands and thousands of attendees each time we run the program -- not to mention that'll take a long time.

CSV doesn't give us a way to just grab a certain number of lines from the file, so here we've used the `times` method on the integer `20`, creating a loop that will run twenty times. Each time through the loop it'll pull one line from the CSV file using the `readline` method, storing it into `line`.

Run this code and you should see output like this:

```
EventManager Initialized.
Nguyen, Allison, 20010, unknown
Hankins, SArah, 20009, unknown
Xx, Sarah, 33703, unknown
Cope, Jennifer, 37216, unknown
```

### Step 1: Experimenting with the Sunlight API

Most APIs work by requesting a very complicated web address. In the case of the Sunlight API, the API we'll be accessing can be found here:

http://services.sunlightlabs.com/api/legislators.allForZip.xml?apikey=e179a6973728c4dd3fb1204283aaccb5&zip=22182

Take a close look at that address. Here's how it breaks down:

* `http://` : Use the HTTP protocol
* `services.sunlightlabs.com` : The server address on the internet
* `/api/` : The 'folder', used to namespace the API from the rest of their website
* `legislators.` : The object name
* `allForZip.` : The method called on that object
* `xml` : The return format expected
* `?` : Parameters to the method
  * `apikey=e179a6973728c4dd3fb1204283aaccb5` : A registered API Key to authenticate our requests
  * `&` : The parameter separator
  * `zip=22182` : The zipcode we want to lookup

We're accessing the `legislators.allForZip` method of their API, we send in an `apikey` which is the string that identifies JumpstartLab as the accessor of the API, then at the very end we have a `zip`. Try modifying the address with your own zipcode and load the page.

If you're familiar with writing HTML then this XML document probably makes some sense to you. You can see there is a `response` object that has a list of `legislators`. That list contains five `legislator` objects which each contain a ton of data about a legislator. Cool!

### Step 2: Dealing with XML and JSON

What we want for this API lookup is a comma separated list of the first initial and the last name like this: F.Wolf, G.Connolly, J.Webb. We could retrieve the raw XML for each attendee and find the names in there, but there's an easier way.

#### Loading the Sunlight Gem

Luigi Montanez, a developer at Sunlight Labs, created the `sunlight` gem. We call this a wrapper library because its job is to hide complexity from us. We can interact with it as a regular Ruby object, then the library takes care of fetching and parsing data from the server.

Up at the very top of your program is the *Dependencies* section. There, add a `require` to load the `sunlight` gem. Remember you have to first install the `sunlight` gem thru your terminal before adding the adding `require` to your *Dependencies* section.

```ruby
require 'sunlight'
```

#### Set the API Key

Just like the request we examined in the browser, all our requests to the Sunlight API need to be signed with our API key.

Just below your `INVALID_ZIPCODE` and `INVALID_PHONE_NUMBER` constants, set the API key within the library like this:

```ruby
Sunlight::Base.api_key = "e179a6973728c4dd3fb1204283aaccb5"
```

#### Accessing the API

Now what can we actually DO with the `Sunlight` library?  Check out the README on the project homepage: http://github.com/sunlightlabs/ruby-sunlightapi

We're interested in the `Legislator` object. Looking at the examples in the ReadMe you'll see this:

```ruby
congresspeople = Sunlight::Legislator.all_for(:address => "123 Fifth Ave New York, NY 10003")
```

That's how to fetch information for a specific address, but our task is to find them via zipcode. Look back at the URL we used to view the XML. See how it has `legislators.allForZip`?  The wrapper library should have a similar method. If you dig into the project's source code, open the `lib` folder, open the `sunlight` folder, then `legislator.rb`. Search the page for `zipcode` and find a method that starts like this:

```ruby
def self.all_in_zipcode(zipcode)
```

Perfect!  It takes in a zipcode and returns a list of legislators.

#### Fetching Legislators

Let's try it within the loop of our `rep_lookup` method:

```ruby
legislators = Sunlight::Legislator.all_in_zipcode(clean_zipcode(line[:zipcode]))
puts legislators
```

Run your program and check out the results.

#### Accessing Legislator Attributes

Did it work? You're probably seeing lines like this:

```ruby
#<Sunlight::Legislator:0x102525280>
```

That's ruby's way of printing out a `Legislator` object. Not very informative, but it shows us that legislators are being found which is good!

Next we should access the name of the legislator within that object -- but how do we know what it's called?  Return to the `legislator.rb` source code and, near the top of the page, you'll see this:

```ruby
attr_accessor :title, :firstname, :middlename, :lastname,
  :name_suffix, :nickname,:party, :state, :district,
  :gender, :phone, :fax, :website, :webform, :email,
  :congress_office, :bioguide_id, :votesmart_id, :fec_id,
  :govtrack_id, :crp_id, :event_id, :congresspedia_url,
  :youtube_url, :twitter_id, :fuzzy_score, :in_office,
  :senate_class, :birthdate
```

This is a list of all the attributes (`attr_accessor` means "attribute accessor") that a `Legislator` has, all the information it knows. If we want their URL we ask for `.website`, or fax number with `.fax`. Here we're interested in their first and last name.

We'll need to loop through `each` of the legislators -- *replace* the `puts legislators` line with this code:

```ruby
legislators.each do |leg|
  puts leg.firstname
end
```

Run your program and check out the results. More impressive, right?

### Step 3: Pulling Names and Formatting the Output

You can see that it's finding one or more representatives and spewing their first names out. But we want just the first initial and last name. We need to query each legislator object and fetch the first initial and last name. We should gather these results into an array so they can be printed all at once.

#### Using `.collect`

Ruby collections, like our `legislators` object, have a method named `.collect`. It accepts a block parameter, runs that block once for each element in the collection, then returns an array of the results.

For example, you could do this in IRB:

{% irb %}
$ [1,2,3].collect do |i|
$   i*10
$ end
# => [10, 20, 30]
{% endirb %}

Collect goes through the list, runs the block, and returns the collected results.

#### `.collect` on `legislators`

We can use that approach with our `legislators` collection:

```ruby
names = legislators.collect do |leg|
  first_name = leg.firstname
  first_initial = first_name[0]
  last_name = leg.lastname
  first_initial + ". " + last_name
end
```

That last line looks a little funny because it isn't being stored anywhere. The last line of a block is going to create the "return value" for the whole block, so in this case it will build the string that gets gathered by `.collect`. Our `names` array will now hold the formatted strings for each legislator.

#### Printing the Results

Change the final `puts` line in the method so it looks like this:

```ruby
puts "#{line[:last_name]}, #{line[:first_name]}, #{line[:zipcode]}, #{names.join(", ")}"
```

The significant change being the last part that says `names.join(", ")`. Calling the `.join` method means "take each thing in the list `names` and `join` them together with a comma and space between each one."  Run your program and you should see output like this:

{% terminal %}
$ ruby event_manager.rb
EventManager Initialized.
Nguyen, Allison, 20010, E.Norton
Hankins, SArah, 20009, E.Norton
Xx, Sarah, 33703, M.Martinez, B.Nelson, C.Young
Cope, Jennifer, 37216, J.Cooper, B.Corker, L.Alexander
Zimmerman, Douglas, 50309, T.Harkin, C.Grassley, L.Boswell
{% endterminal %}

#### Extra Challenges

1. Output the party in parens like `"E.Norton (D)"`
2. Prefix the name with their title `"Sen"`, `"Rep"`, or `"Del"`

## Iteration 5: Form Letters

Every organization has to generate form letters and somehow it seems to always be a pain in the neck. Here's one way we could do it with Ruby and HTML.

### Step 0: Framework & Goals

First, download the HTML form letter here: [form_letter.html](/assets/eventmanager/form_letter.html)

Open that HTML file in your editor and check out the structure. You'll see markers like `#first_name` which we can use to fill in the attendee's details.

#### Adding the Method

Next, add a method to your `EventManager` class like this:

```ruby
  def create_form_letters
    letter = File.open("form_letter.html", "r").read
    20.times do
      line = @file.readline

      # Do your string substitutions here
    end
  end
```

`File.open` tells Ruby to look for a file named `form_letter.html` and the `"r"` tells it to open it read-only. The `.read` method says "load the whole file as a string" and we save it into `letter`.

### Step 1: Customizing the Text

Use the `gsub` method to find the markers in the text and replace them with the data from `line`. `gsub` takes two parameters: the first is the string to search for and the second is the string to replace it with.

```ruby
custom_letter = letter.gsub("#first_name", line[:first_name].to_s)
custom_letter = custom_letter.gsub("#last_name", line[:last_name].to_s)
```

Continue writing `gsub` lines like the last one for your other variables.

### Step 2: Writing out the File

Now that you're creating the customized text you need to output it to a file.

#### Creating an `output` Directory

To keep the output files separate from your program, create a directory named `output` inside your project directory.

#### Writing the Files

You can create a filename, open the file, and write the `custom_letter` to that file with these instructions:

```ruby
filename = "output/thanks_#{line[:last_name]}_#{line[:first_name]}.html"
output = File.new(filename, "w")
output.write(custom_letter)
```

#### Check the Results

Run the method from your script and examine the output. Are all the markers replaced correctly?

## Iteration 6: Time Targeting

The boss is already thinking about the next conference: "Next year I want to make better use of our Google and Facebook advertising. Find out which hours of the day the most people registered so we can run more ads during those hours."  Interesting!

### Step 0: Framework

We'll create a list of 24 slots, one for each hour of the day. Each slot will start with a count of zero. We'll go through the registrant list and, for each one, increase the hour that they registered by one. Then we'll print out the list of hours with their total registration counts.

```ruby
  def rank_times
    hours = Array.new(24){0}
    @file.each do |line|
      # Do the counting here
    end
    hours.each_with_index{|counter,hour| puts "#{hour}\t#{counter}"}
  end
```

#### A First Run

Change the instruction in your script to `manager.rank_times` and run it. You should see a column of hours (0 to 23) and a column of totals (all zero).

The only thing new here is the method `each_with_index`. It works just like `each`, but it includes an `index` value which indicates the current element's position in the list. So for the first item in the list, the `index` is `0`, for the second it is `1` and so on.

### Step 1: Find the Hour & Update the Counter

If you look at the spreadsheet you'll see that the `regdate` field data looks like this: `11/12/08 10:47`. We need a way to pull out just the hour.

#### Understanding `.split`

We'll use the method `.split` to help us out. `split` takes one parameter which is the string that you want to split on. So if my string were `"hello jumpstart lab"` and I called `.split(" ")` on it, Ruby would split it up each time it finds a space and give me back a list like this: `["hello","jumpstart","lab"]`.

Once you have that array, you can pull out individual parts by position. If I wanted the first chunk I would ask for `[0]`, or the second would be `[1]`, or the third `[2]`. Check out this example:

```ruby
my_string = "hello and welcome to jumpstart lab"
parts = my_string.split(" ")
puts parts[0] # This would print out "hello"
puts parts[3] # This would print out "to"
```

#### Parsing the Regdate

Go into an IRB terminal and enter `timestamp = "11/12/08 10:47"`. Then experiment with using `split`. How can you pull out just the `10`?  HINT: You'll need to use `split` twice.

#### Incrementing the Counter

Once you figure it out, write code in your `rank_times` method that pulls out the hour and stores it into the variable `hour`. Once you know the `hour`, you can update the counter by doing this:

```ruby
hours[hour.to_i] = hours[hour.to_i] + 1
```

#### Checking Results

Once you think you've got it, run the method. My first few lines look like this:

{% terminal %}
EventManager Initialized.
0	276
1	68
2	41
3	9
{% endterminal %}

### Step 2: Requirements Always Change

The big boss gets excited about the results from your hourly tabulations. It looks like there are some hours that are clearly more important than others. But now, tantalized, she wants to know "What days of the week did most people register?"

Given that you're pretty much a genius programmer at this point, I'll just give you some tips:

* Create a method named `day_stats`
* Create an array list, just like you did for `hours` but call it `days` and make the size `7`
* Turn a string like `11/12/08` into a Ruby Date with this instruction:
  * `date = Date.strptime("11/12/08", "%m/%d/%y")`
* Once you have a `date` object, you can get the numeric day of the week by calling the `.wday` method. Note that Sunday is `0` and Saturday is `6`
* Which two days have dominantly more registrations than the others?

## Iteration 7: State Stats

So you cleaned up the data, output the file, and sent it to your team. "Hey, that data looks great," they say, "it makes me wonder about our stats. Can you tell us more about our attendees?"  Of course you can.

### Step 0: Goals & Framework

Let's start with state-based information. How many attendees are from each state?  Let's output a list in the format "State: Attendee" count, like "MD: 26". We'll put it together in a method called `state_stats`:

```ruby
  def state_stats
    state_data = {}
    @file.each do |line|

    end
  end
```

In the second line there we've created a *Hash* named `state_data`.

### Step 1: Counting with a Hash

In this case, we'll use our Hash to keep track of how many attendees are from each state. Imagine if we were sorting out paper attendee registrations by hand:

For each attendee...

* Figure out which state they're from
* If a bucket does not exist for that state, create the bucket then put the paper in there
* If a bucket exists for that state, put the paper in there
* At the end, the number of papers in each bucket shows how many attendees are from that state

#### Building the Counter

Inside the `@file.each` loop, let's add instructions to implement this logic:

```ruby
  def state_stats
    state_data = {}
    @file.each do |line|
      state = line[:state]  # Find the State
      if state_data[state].nil? # Does the state's bucket exist in state_data?
        state_data[state] = 1 # If that bucket was nil then start it with this one person
      else
        state_data[state] = state_data[state] + 1  # If the bucket exists, add one
      end
    end
  end
```

#### Running the Method

Change your script to call the method:

```ruby
manager = EventManager.new("event_attendees_clean.csv")
manager.state_stats
```

Run that program. Did it work?  If it generated an error, get it fixed. If there was no error, though, you probably have no idea if it worked. We didn't print out anything. Let's add that in now.

#### Printing a Hash

We're collecting all the state stats in a *hash*. A hash is made up of "key-value pairs" -- the "key" is the address that helps us find what we're looking for. The "value" is the data that the address is pointing to. Each key points to one value. When we have a collection of these key-value pairs, we frequently want to walk through the list and do something to each pair. This state data is a perfect example.

What we really want is to print out lines like "CA: 206". "CA", the state abbreviation, is the key of the key-value pair while the number of attendees, 206, is the value of the pair. Ruby has a really great way of walking through collections like this using the `each` method, like this:

```ruby
state_data.each do |key,value|
  puts key
  puts value
end
```

The `each` method means "take each pair in this hash and `do` what's inside this `do`/`end` block of code. Right after the `do` is a part that trips up a lot of people.

We need to give the data names. `|key,value|` basically translates to "for each pair, call the first thing `key` and the second thing `value`". There's nothing magical about these particular names, they can be whatever makes sense to you. In this case, actually, we can be more explicit with our naming. Go ahead and add the following code before the `end` statement of your `state_stats` method:

```ruby
state_data.each do |state, counter|
  puts state
  puts counter
end
```

#### Slightly Improved Output

Run this code to see what you get. Mine looks like this...

{% terminal %}
$ ruby event_manager.rb
EventManager Initialized.
ND
11
AL
26
VA
382
NY
503
{% endterminal %}

### Step 2: Cleaning up the Output

Getting there, but not quite right. We want it to look like `ND: 11`, not have `ND` and `11` on different lines. Look at the `each` loop where we have the lines `puts state` and `puts counter`. Take out those two and replace them with this interpolated string:

```ruby
puts "#{state}: #{counter}"
```

This line could be read as "printout whatever is in the variable named `state`, then a colon, then a space, then whatever is in the variable named `counter`."  Once you've put in this improved `puts` line, RUN your code and you should see output like this:

{% terminal %}
$ ruby event_manager.rb
EventManager Initialized.
ND: 11
AL: 26
VA: 382
{% endterminal %}

Looking good!

### Step 3: Sorting

A hash is just a group of key-value pairs. They don't have an inherit order -- and this really frustrates a lot of people. You probably noticed that your output came out in some arbitrary order. It's not alphabetical by state, it's not by region, it's not by ascending or descending totals. These would all be reasonable ways to sort the hash, but we haven't told Ruby which to use.

#### Using `sort_by`

Thankfully hash has a method named `sort_by`. Using `sort_by` we can get the hash sorted by any criteria we wish. It uses a similar syntax to `each` that we used above. Here's how you could sort this hash alphabetically by the state name:

```ruby
state_data = state_data.sort_by{|state, counter| state unless state.nil?}
```

Reading this would sound like "take the `state_data` hash and sort it by looking at each pair, name the key `state` and name the value `counter`, then compare the `state` of each pair and ignore the value of `counter`.

This will result in an ascending alphabetical sort, and save those results back into the name `state_data`. Try it in your code by sorting the data before printing it like this:

```ruby
state_data = state_data.select{|state, counter| state}.sort_by{|state, counter| state unless state.nil?}
state_data.each do |state, counter|
  puts "#{state}: #{counter}"
end
```

Run your code and you should see output like this:

{% terminal %}
$ ruby event_manager.rb
EventManager Initialized.
AK: 2
AL: 26
AR: 3
{% endterminal %}

#### Sorting by Registration Count

Now, try modifying the `sort_by` instruction to sort by `counter` instead of state. See how that affects your output. You can also try reversing the list by negating `counter`.

### Step 4: Alphabetical Order with Numbered Rank

This is really a little bit advanced for this point of your development, but here's how you could implement an alphabetical state list combined with an attendance-count ranking.

```ruby
    ranks = state_data.sort_by{|state, counter| -counter}.collect{|state, counter| state}
    state_data = state_data.select{|state, counter| state}.sort_by{|state, counter| state}

    state_data.each do |state, counter|
      puts "#{state}:\t#{counter}\t(#{ranks.index(state) + 1})"
    end
```

The most significant change is the first line. The `state_data.sort_by{|state, counter| counter}` is just the same as the sorting by the `counter` that you did before. Once I have that ordered list, I don't care any more about the actual counts anymore, I only care about the order.

I then use the `collect` method to pull out the state names...basically "for each pair in the hash, name the key of the pair `state` and the value of the pair `counter`, then give me just the `state`."  The results of this `collect` are put into the array list named `ranks`. If you were to print it out, this would look like this:

```
MH,BC,NV,WY,DE,NS,QC,AS,OK,AK,PW...
```

This list start with MH because it has 1 registrant and ends with NY because of its 503 registrants. I want my rankings in the opposite order (where the first position is the highest `counter`), so I added a `.reverse` to flip it around.

Then the second change is this line: `puts "#{state}:\t#{counter}\t(#{ranks.index(state) + 1})"`. The first thing I've changed is putting in `\t` which inserts a tab instead of a space so the output is more readable.

The interesting part is `#{ranks.index(state) + 1}` which reads as "look in the list `ranks` and find the `index` (or "position") of whatever is in the variable named `state` then add `1` to that address."  The list is indexed starting with zero; we add one so that the state rankings start at "1" like you'd normally rank things. Run this code and you should see output like this:

{% terminal %}
$ ruby event_manager.rb
EventManager Initialized.
AK:	2	(53)
AL:	26	(35)
AR:	3	(51)
{% endterminal %}

# And with that, you're done!
