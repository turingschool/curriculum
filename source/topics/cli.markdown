---
layout: page
title: DIY CLI
sidebar: true
---

Let's practice writing a CLI.

## Goal Setting

By the end of this tutorial you should:

* understand what a CLI is and have some ideas of why/when you'd build one
* know how to use Ruby to interact with / manipulate standard UNIX tools
* be able to test a CLI using Aruba

## What is a CLI?

A CLI (command line interface) is a text based interface to a computer operating system or application. You are working with a CLI when you use your terminal.

In contrast, most interactions for standard computer users are completed with a GUI (pronounced gooey) Graphical User Interface. Some examples would be using iMessage or Photoshop. While the graphical user interface is very helpful for visualizing what's going on, the command line is a very powerful tool.

With ruby and bash scripting, many daily activities can be automated. Getting comfortable in the terminal will help you as a developer.

Learning Goals

* Write a bash script
* Write a ruby script
* Manipulate PATH
* Make files executable
* Use automated tests to verify functionality of scripts

## Hello World

Our first step will be to create a directory for this tutorial, and within it, a bin directory for storing our scripts. Creating a `bin` directory is not required, but it is a convention that will help keep the files organized.

{% terminal %}
mkdir diy-cli
cd diy-cli
mkdir bin
{% endterminal %}

### In Ruby

Create a file named `hello_ruby.txt` in the `bin` directory with the following
code in it:

```ruby
puts "Hello, World!"
```

Run the script in your terminal with the `ruby` command:

{% terminal %}
$ ruby bin/hello_ruby.txt
Hello, World!
{% endterminal %}

### In Bash

Create another file in the `bin` directory named `hello_bash.txt` with the
following code in it:

```bash
echo "Hello, World!"
```

Run it in your terminal with the `bash` command:

{% terminal %}
$ bash bin/hello_bash.txt
Hello, World!
{% endterminal %}

### The Right Tool for the Job

Try running the Bash program with `ruby`:

{% terminal %}
$ ruby bin/hello_bash.txt
hello_bash.txt:1:in <main>: undefined method echo for main:Object (NoMethodError)
{% endterminal %}

Now try running the Ruby program with `bash`:

{% terminal %}
$ bash hello_ruby.txt
hello_ruby.txt: line 1: puts: command not found
{% endterminal %}

It doesn't work. `bash` doesn't know how to interpret Ruby code, and `ruby`
code doesn't know how to interpret bash code.

### File Extensions

It's common to make the file extension reflect which programming language a file is written in. For ruby, the commonly accepted extension is `.rb`. Changing the file extension doesn't change the type of the file, it's still just plain text.

Rename the Ruby file to `hello.rb`:

{% terminal %}
$ mv bin/hello_ruby.txt bin/hello.rb
{% endterminal %}

You can check that your change was successful by typing `ls` in the terminal
to see all the files your directory. `ls` is short for `list`, which is
shorthand for _computer, please list the files in the current directory_.

Now, to run the Ruby file you would say:

{% terminal %}
$ ruby bin/hello.rb
{% endterminal %}

The commonly accepted extension for Bash is `sh`.

Rename the Bash file to `hello.sh`:

{% terminal %}
$ mv bin/hello_bash.txt bin/hello.sh
{% endterminal %}

Now run the Bash program with:

{% terminal %}
$ bash bin/hello.sh
{% endterminal %}

## Command-Line Commands

_NOTE: This tutorial assumes that you are working with a UNIX based machine. If you are working on a Windows, you may want to cross reference the [Microsoft Commands](http://www.microsoft.com/resources/documentation/windows/xp/all/proddocs/en-us/ntcmds.mspx?mfr=true)_

Some things on the command line feel like they're built in. For example, the
`date` command, which tells you the current time and date:

{% terminal %}
$ date
Mon Feb 17 09:24:03 MST 2014
{% endterminal %}

Or, take the `cal` command, which by default shows you the current calendar
month:

{% terminal %}
$ cal
   February 2014
Su Mo Tu We Th Fr Sa
 1
 2  3  4  5  6  7  8
 9 10 11 12 13 14 15
16 17 18 19 20 21 22
23 24 25 26 27 28
{% endterminal %}

Many command take options and additional parameters.

For example, if you want to see a particular month in the current year, tell the Command Line which month by adding the `-m` flag:

{% terminal %}
$ cal -m June
     June 2014
Su Mo Tu We Th Fr Sa
 1  2  3  4  5  6  7
 8  9 10 11 12 13 14
15 16 17 18 19 20 21
22 23 24 25 26 27 28
29 30
{% endterminal %}

You can get a full year's calendar by specifying the year. For example: `cal 2014`.

When you're running a ruby program by saying `ruby bin/hello.rb`, you are using the `ruby` command with `bin/hello.rb` as the argument.

## Custom Scripts

Instead of having to specify which program to execute our script with, and where it is, it would be nice to be able to go anywhere on our file system and
just say `hello`, and have it run our `hello.sh` script using `bash`. Or perhaps it would run our `hello.rb` script using `ruby`, since the result is
the same, it doesn't matter which language the script is in.

**There are two parts to this:**

**First**, we need to make it possible to run the command without saying which
program to use.

**Second**, we need make it so the computer can find the script without typing out the full path.

To be able to make sense of this, we need to take a detour into the subject of
file permissions.

### File Permissions

There are three types of permissions for a file:

- **read** (`r`) - you are allowed read the file.
- **write** (`w`) - you are allowed to change the file.
- **execute** (`x`) - you are allowed to run the program defined in the file.

We'll mess around with this a bit first, then explain.

#### Create the File

Create a file called `haha.txt`, and stick some text in it, for example
_Wow. That was very funny._.

Get the longhand listing for the current directory:

{% terminal %}
$ ls -l .
{% endterminal %}

We used the `ls` command earlier to see a list of all of the files in the
directory. The `ls` command has an option `-l` (for `long`) which will display
the file permissions.

Let's just look at the first part, which is the permissions bit pattern.

{% terminal %}
-rw-r--r--
{% endterminal %}

The very first thing that appears is `-` for the file. If this had been a directory, it would have had a `d` first.

Next there are 9 bits that can be turned on and off. The first three are for
the user, the next three are for the group, and the final three are for
`other` (in other words: "everyone else").

For the moment, let's ignore the group and other permissions and just focus on
the user's permissions in the `haha.txt` file.

In fact, let's change the permissions so that group/other don't have access at all.

####Changing Permissions

Permissions are historically called modes, and the command we use to change them is called `chmod`, for _change mode_.

As a reminder, the current permissions on the file are:

{% terminal %}
-rw-r--r--
{% endterminal %}

Run the following command:

{% terminal %}
$ chmod 600 haha.txt
{% endterminal %}

This sets the permissions to

{% terminal %}
-rw-------
{% endterminal %}

You can open the file in your text editor, and change the text.

You can also use the command `cat` to read the contents of the file into your
terminal window:

{% terminal %}
$ cat haha.txt
Wow. That was very funny.
{% endterminal %}

Another way of editing the file is to append text to it:

{% terminal %}
$ echo "I laughed out loud." >> haha.txt
{% endterminal %}

Then look at the contents again:

{% terminal %}
$ cat haha.txt
Wow. That was very funny.
I laughed out loud.
{% endterminal %}

Now, let's make the permissions more restrictive by changing the permissions
to 400:

{% terminal %}
$ chmod 400 haha.txt
{% endterminal %}

Then look at the permissions again with `ls -l`:

{% terminal %}
-r--------
{% endterminal %}

This is a read only file. You can open it in your text editor or read it with
the `cat` command:

{% terminal %}
$ cat haha.txt
Wow. That was very funny.
I laughed out loud.
{% endterminal %}

You can't change it, though:

{% terminal %}
$ echo "It totally made my day." >> haha.txt
-bash: haha.txt: Permission denied
{% endterminal %}

Now change the permissions to 200:

{% terminal %}
$ chmod 200 haha.txt
{% endterminal %}

The bit pattern now looks like this:

{% terminal %}
--w-------
{% endterminal %}

We can now write to the file, but not read it.

{% terminal %}
$ cat haha.txt
cat: haha.txt: Permission denied
{% endterminal %}

But we don't get an error message when we try to append more text to the file:

{% terminal %}
$ echo "It totally made my day." >> haha.txt
{% endterminal %}

So... how can we know if it worked?

Well, we could change the permissions again so that we can read it, or we can
ask for god powers using `sudo`:

{% terminal %}
$ sudo cat haha.txt
{% endterminal %}

It will ask you for your password, and then output the text.

Using `sudo` in this context allows you to act as the 'superuser' or 'root'. It is a very powerful command and should be used sparingly.

<hr>
### Optional Side Step!
#### Where did 600, 400, and 200 come from?

The way to come up with the magic number that will set the correct permissions
is to create a binary number using the bit pattern, and then turn that into a base 8 number. Every hyphen becomes a `0`, and for every letter becomes a `1`.

Ignore the first spot, since that's not part of the permissions bit
pattern.

Here's the original bit pattern before we started using `chmod` to change it:

{% terminal %}
-rw-r--r--
 110100100
{% endterminal %}

In IRB you can translate a binary into an octal like this:

{% terminal %}
$ irb
irb:001> 0b110100100.to_s(8)
=> 644
{% endterminal %}

So running `chmod 644 haha.txt` will set the permissions back to what they
were.

<hr>

### What about `x` for Executable?

So putting this all together:

It seems like perhaps the `hello.rb` and `hello.sh` scripts would need to have `execute` turned on in order to run.

**Change the permissions of `hello.rb` to 400.**

This will give the file the `read` ability, but not `write` or `execute`.

**Then run the script.**

{% terminal %}
$ ruby hello.rb
Hello, World!
{% endterminal %}

It works.

**Now change the permissions to 200**, which is `write-only`, **and run the script again**.

{% terminal %}
$ ruby bin/hello.rb
ruby: Permission denied --bin/hello.rb (LoadError)
{% endterminal %}

It doesn't work with `write only` permission.

The program that is being executed in this case is not actually `hello.rb`, but actually `ruby` itself.
`hello.rb` is just an argument to the `ruby` program, and as long as `ruby` is
allowed to read it, it can run the program.

#### So, how and why do we use `x` permission, you ask?

Well, good question.

Let's set the permissions back to read-write (without execute):

{% terminal %}
$ chmod 600 hello.rb
{% endterminal %}

The permissions have changed accordingly:

{% terminal %}
$ ls -l hello.rb
-rw-------  1 kytrinyx  staff  21 Feb 18 09:40 hello.rb
{% endterminal %}

Now, let's try running the script directly, rather than using the `ruby`
program to run it:

{% terminal %}
$ cd ..
$ bin/hello.rb
-bash: bin/hello.rb: Permission denied
{% endterminal %}

It looks like `bash` is trying to execute it, but isn't allowed to.

Change the permissions again, this time to 700:

{% terminal %}
$ chmod 700 bin/hello.rb
{% endterminal %}

Check the permissions:

{% terminal %}
$ ls -l bin/hello.rb
-rwx------  1 kytrinyx  staff  21 Feb 18 09:40 bin/hello.rb
{% endterminal %}

Now let's try to run it directly again:

{% terminal %}
$ bin/hello.rb
bin/hello.rb: line 1: puts: command not found
{% endterminal %}

That's a familiar error message. Bash is trying to run the program, but it's
ruby code. We need to find a way to tell the computer to use `ruby`, not
`bash`, to run the script.

### Introducing the Shebang

We can embed information into the file itself so that it knows which program to use
to be executed.

Edit the `hello.rb` file:

```ruby
#!/usr/bin/env ruby

puts "Hello, world!"
```

The first line starts with a hash (`#`) and a bang (`!`). This is pronounced _shebang_.

Next we include the path to the program that should be used to run
the script. In this case we want whichever `ruby` the current environment has
defined as the `ruby` program.

Now, try running the program again from the main `diy-cli` directory:

{% terminal %}
$ bin/hello.rb
Hello, World!
{% endterminal %}

That fixes it.

It's good form to tell to tell the computer where to find the program to run a script with.

Now let's do the same thing to our bash script 'hello.sh` and change that file to be executable (reminder, 700 is the code that can turn executable on).

If you’re not sure where `bash` lives, you can use `which` to find out:

{% terminal %}
$ which bash
/bin/bash
{% endterminal %}

Add `#!/bin/bash` to the top of the script `hello.sh` script.

## PATH

Now that we've set the executable bit and used shebang to identify the programs
that should be used to run the files, we can run them by just calling the path to
the file.

**That has limitations.**

First of all, you need to remember the full path, and that's a pain.

Second of all, if you happen to be in the same directory as the script, you
still have to specify a path.

{% terminal %}
$ bin/hello.sh
Hello, World!
$ cd bin
$ hello.sh
-bash: hello.sh: command not found
{% endterminal %}

This is because the computer doesn't look in the current directory for
scripts. If you specify that it should look in the current directory (`.`)
then it will:

{% terminal %}
$ ./hello.sh
Hello, World!
{% endterminal %}

So, if it doesn't look in the current directory, where does it look?

It looks in something called `PATH`, which is an environment variable.

You can see the value of this on your system by running:

{% terminal %}
$ echo $PATH
{% endterminal %}

Right now, mine is a complete mess, with a bunch of duplicates:

```plain
/Users/kytrinyx/.gem/ruby/2.1.0/bin:/Users/kytrinyx/.rubies/ruby-2.1.0/lib/ruby/gems/2.1.0/bin:/Users/kytrinyx/.rubies/ruby-2.1.0/bin:/Users/kytrinyx/bin:/usr/local/bin:/usr/bin:/usr/local/share/npm/bin:/usr/local/go/bin:/usr/local/bin:/Users/kytrinyx/code/go/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/go/bin:/usr/texbin:/Users/kytrinyx/bin:/usr/local/share/npm/bin:/Users/kytrinyx/code/go/bin
```

Each part of the path is separated by a colon (`:`).
We'll simplify and pretend that your path looks like this:

```plain
/usr/bin:/usr/local/bin:/bin
```

In this case there are three directories in your path:

- `/usr/bin` (the `bin` directory that lives in `unix system resources`)
- `/usr/local/bin` (a folder that homebrew typically uses when installing things)
- `/bin` (the top-level `bin` directory)

If you type `zomg` in your terminal window, your computer will go to the first
place in your path, and look for an executable file there named `zomg`.

{% terminal %}
$ zomg
{% endterminal %}

So first it looks in:

```plain
/usr/bin/zomg
```

Then, since it doesn't find it there, it goes to the next place, and tries:

```plain
/usr/local/bin/zomg
```

Still no luck. So it tries:

```plain
/bin/zomg
```

Since this doesn't exist, and the computer has no further places to look, it
gives up and complains:

```plain
-bash: zomg: command not found
```

If we want the computer to look in more places, we can expand the path.

For now, figure out what the path to your `diy-cli/bin` directory is.

You can do so by using the `pwd` bash command in the terminal:

{% terminal %}
$ pwd
/Users/kytrinyx/code/tmp/diy-cli/bin
{% endterminal %}

To add this path to the PATH, I can export the directions:

{% terminal %}
export PATH=/Users/kytrinyx/code/tmp/diy-cli/bin:$PATH
{% endterminal %}

Check your path again:

{% terminal %}
echo $PATH
{% endterminal %}

You should see all the old stuff, and at the very front, you should see the
path where your `hello.sh` and `hello.rb` files live.

The `$PATH` value has only been updated for that particular terminal window.
If you open a second terminal window and type `echo $PATH`, you will only see
the original path.

Back in your first window, you're probably still standing in the `diy-cli/bin`
directory.

Try running the script without specifying the `./`:

{% terminal %}
$ hello.rb
{% endterminal %}

If your path is set up correctly, you will now get `Hello, World!` rather than
`no such command`.

If that works, change directories to your home directory, and try again:

{% terminal %}
$ cd
$ hello.rb
{% endterminal %}

The computer knows where to find it.

Now try it in a different terminal window.
It should give you the
`command not found` message.

It's quite common to create a `~/bin` directory that you put on your PATH
permanently, by adding this line of code to your `.bash_profile` or `.zshrc`
file:

```bash
export PATH=~/bin:$PATH
```

## Adding automated tests for `hello.sh`

**Make sure you're in your `diy-cli` directory.**

{% terminal %}
gem install aruba
{% endterminal %}

The `aruba` gem adds some basic functionality to the testing framework Cucumber, so installing aruba will also install cucumber.

Run the `cucumber` command:

{% terminal %}
$ cucumber
{% endterminal %}

This will give you an error message.

```plain
No such file or directory - features. Please create a features directory to get started. (Errno::ENOENT)
```

If you look closely, it tells you exactly what you need to do:

```plain
Please create a features directory to get started.
```

Go ahead and do that, then run cucumber again.

{% terminal %}
$ mkdir features
$ cucumber
{% endterminal %}

This gives the following output:

```plain
0 scenarios
0 steps
0m0.000s
```

We need a scenario to run.

Inside the `features` directory, create a new file, `hello-in-bash.feature`:

```plain
Feature: Saying hello in bash

Scenario: Greeting the world
  When I run `hello.sh`
  Then the output should contain:
  """
  Hello, World!
  """
```

This is a testing language called `gherkin` that is used with Cucumber. Each `Scenario` is a single test, and each line in the scenario is an instruction that gets translated into code. There are some default instructions that are widely recognized, but you can define your own instructions (or "steps") as well.

Notice that we're running `hello.sh` without specifying the full path. You don't need to have `diy-cli/bin` on your PATH, the `aruba` gem figures out which directory you are in, and puts the `bin` path in that current directory onto the path for you.

Running `cucumber` now gives you a lot more output:

```plain
Feature: Saying hello in bash

  Scenario: Greeting the world      # features/hello-in-bash.feature:3
    When I run `hello.sh`           # features/hello-in-bash.feature:4
    Then the output should contain: # features/hello-in-bash.feature:5
    """
    Hello, World!
    """

1 scenario (1 undefined)
2 steps (2 undefined)
0m0.002s

You can implement step definitions for undefined steps with these snippets:

When(/^I run `hello\.rb`$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^the output should contain:$/) do |string|
  pending # express the regexp above with the code you wish you had
end
```

So it is running our scenario, but it doesn't know how to interpret the steps.

This is where `aruba` comes in. Aruba has defined a lot of default steps that are helpful when testing command-line clients, for example:

```plain
When I run `some command`
```

and

```plain
Then the output should contain:
"""
some text
"""
```

Create a new directory `features/support`, and add an empty file to it named `env.rb`.

In `env.rb` add the following code:

```ruby
require 'aruba/cucumber'
```

Run `cucumber` again. This time the test should pass.

Let's complicate things. It would be nice to be able to greet specific people rather than the whole world. The world should still be the default, though.

Add a second scenario to your hello-in-bash.feature test:

```plain
Feature: Saying hello in bash

Scenario: Greeting the world
  When I run `hello.sh`
  Then the output should contain:
  """
  Hello, World!
  """

Scenario: Greeting a person
  When I run `hello.sh Alice`
  Then the output should contain:
  """
  Hello, Alice!
  """
```

Run `cucumber`, and the first scenario passes, as does the `When` step. The `Then` step fails, however, because we're still getting "Hello, World!" rather than "Hello, Alice!".

We need a way to get access to the things that got passed in to the script on the command line.

In bash, each variable gets assigned a number, which can be accessed by `$1`, `$2`, etc.

We could change the code to this:

```bash
#!/bin/bash

echo "Hello, $1!"
```

And that would get the second scenario running, but the first one would fail.

We need a way to set a default value. In bash, this looks like this:

```bash
#!/bin/bash

WHO=$1
WHO=${WHO:-"World"}
echo "Hello, $WHO!"
```

The first line assigns the value of `$1` into the variable `WHO`.
The second assigns the value `World` into `WHO`, but only if `WHO` is currently empty.
Finally, we use `$WHO` to access the `WHO` variable.

This gets the tests passing.

## Adding automated tests for `hello.rb`

Create a second file in features called `hello-in-ruby.feature`.

Write two scenarios, one for `"Hello, World!"` and one for `"Hello, Bob!"`.

In ruby you can access the arguments passed to your script using the `ARGV` constant. It's an array, and you can get the first thing out of it using `ARGV.first`.

You can use `||` in ruby to use a default:

```ruby
who = ARGV.first || "World"
puts "Hello, #{who}!"
```

Get the tests you've written to pass!

### Expanding hello.rb

Let's make it possible to greet multiple people at once.

For example:

{% terminal %}
$ hello.rb Alice Bob Charlie
Hello, Alice!
Hello, Bob!
Hello, Charlie!
{% endterminal %}

Add a scenario for it in your ruby feature test:

```plain
Scenario: Greeting many people
  When I run `hello.rb Alice Bob Charlie`
  Then the output should contain:
  """
  Hello, Alice!
  """
  And the output should contain:
  """
  Hello, Bob!
  """
  And the output should contain:
  """
  Hello, Charlie!
  """
```

#### Hints

Let's say you have an array called `fruits`.

You can check if it has anything in it by asking `fruits.empty?`.

You can add something to an array by using the _shovel_ method:

```ruby
fruits << 'apple'
```

You can loop through an array using `each`:

```ruby
fruits.each do |fruit|
  eat fruit
end
```

### Hello, Full Name!

What would you need to do to be able to greet Alice as follows?

```plain
Hello, Alice Smith!
```

Hint: If all your tests are passing, you shouldn't need to change anything in the code.

## Writing a slightly more complicated bash script

Let's try a more realistic scenario.

Get (clone) the [ambashed](https://github.com/JumpstartLab/ambashed) repository, and change directories into it.

{% terminal %}
git clone https://github.com/JumpstartLab/ambashed.git
cd ambashed
{% endterminal %}

Install the dependencies:

{% terminal %}
$ bundle install
{% endterminal %}

Here's our problem. We have a directory full of text documents that have very inconsistent names: upper and lowercase letters, spaces, underscores, and hyphens.

We need to standardize so that we get all lowercase, and only hyphens, no underscores or spaces. Also, we don't want multiple hyphens in a row.

{% terminal %}
$ ls -1 files/
2013 summary of stuff.txt
Carrot Cake.txt
Contact List - work.txt
contact_list   SCHOOL.txt
rESUME Alice Smith.txt
{% endterminal %}

What should the script do?

In its simplest form, it should take the files in a given directory and clean up all the names.

That's kind of scary, though. What if we accidentally get it wrong? We should probably not just rename the files in place, we need to find a way to make it so that we could delete things if they go badly, and then try again.

So our script should not touch existing files, it should make a copy of the file and put it in a new location.

### Wiring things together

Start by running `cucumber`. It tells you that it's missing the `features` directory. Go ahead and make it, and run cucumber again.

Now we need a test. What would a test look like?

Here is what we expect to happen:

We run the script, telling it which directory to clean up.

Then we list out the files in the new directory, and it should have the cleaned up files.

We shouldn't operate on the given production files for the tests, because we might mess them up.

What's the simplest case we could test?

Well, if we had a directory with a single file that already conformed to our standard, that file should end up in the new location.

```plain
Feature: Cleaning up file names

  Scenario: Beautiful names are left alone
    Given a directory named "stuff"
    And an empty file named "stuff/a-nice-name.txt"
    When I run `cleanup stuff`
    And I run `ls -1 clean-stuff`
    Then the output from "ls -1 clean-stuff" should contain "a-nice-name.txt"
```

Run `cucumber` again, and it will tell you about a bunch of missing steps.

We need to require `aruba`.

Create a directory `features/support`, and a file `features/support/env.rb` that has the require statement for `aruba/cucumber`.

Now when you run the `cucumber` command it should have a couple passing steps, since aruba knows how to create directories and files.

It fails at the _When I run `cleanup stuff`_ step.

We need a script named `cleanup` that is executable, and lives in the `bin` directory.

Create an empty 'cleanup' file in the `bin` directory, and change the mode to `700`.

That gets the cleanup step passing, but we're stuck on listing the contents of the new directory.

That's because the new directory doesn't exist. The script has to create it before it can copy things into it.

Here's what I came up with:

```bash
#!/bin/bash

source_dir=$1
target_dir="clean-$source_dir"

mkdir $target_dir
```

That gets the next step passing. To get the final step passing we need to figure out what's in the old directory and copy it to the new directory.

```bash
#!/bin/bash

source_dir=$1
target_dir="clean-$source_dir"

mkdir $target_dir

for source_file in $(ls $source_dir); do
  target_file=$source_file
  touch "$target_dir/$target_file"
done
```

For now we're using the same filename as the new name. We need to write a test that will force us to improve that part of the script.

```plain
Scenario: Uppercase names are made lowercase
  Given a directory named "loud"
  And an empty file named "loud/SHOUT.txt"
  When I run `cleanup loud`
  And I run `ls -1 clean-loud`
  Then the output from "ls -1 clean-loud" should contain "shout.txt"
```

Thais fails, of course. Here's what I came up with to make it pass:

```bash
target_file=$(echo $source_file | tr 'A-Z' 'a-z')
```

That puts the full script at:

```bash
#!/bin/bash

source_dir=$1
target_dir="clean-$source_dir"

mkdir $target_dir

for source_file in $(ls $source_dir); do
  target_file=$(echo $source_file | tr 'A-Z' 'a-z')
  touch "$target_dir/$target_file"
done
```

Let's handle underscores:

```plain
Scenario: It uses hyphens instead of underscores
  Given a directory named "many"
  And an empty file named "many/words_and_things.txt"
  When I run `cleanup many`
  And I run `ls -1 clean-many`
  Then the output from "ls -1 clean-many" should contain "words-and-things.txt"
```

We need a tiny bit of extra stuff in our `tr` command:

```bash
target_file=$(echo $source_file | tr 'A-Z_' 'a-z-')
```

Looking back at our original list of filenames, we also need to handle spaces.

Here's a test for a file with a space:

```plain
Scenario: It replaces spaces with hyphens
  Given a directory named "cowboy"
  And an empty file named "cowboy/rides a horse.txt"
  When I run `cleanup cowboy`
  And I run `ls -1 clean-cowboy`
  Then the output from "ls -1 clean-cowboy" should contain "rides-a-horse.txt"
```


This fails with the following diff:

```plain
Diff:
@@ -1,2 +1,4 @@
-rides-a-horse.txt
+a
+horse.txt
+rides
```

Instead of getting a single new file called `rides-a-horse.txt`, we got three files. Our code isn't handling whitespace correctly.

We need a different strategy in our loop. Let's switch to using the native globbing capability:

```bash
for source_file in $source_dir/*; do
  # ...
done
```

This makes all the scenarios fail, but the failure doesn't really tell us why.

Let's tweak our current scenario to get some more output.

```plain
Scenario: It replaces spaces with hyphens
  Given a directory named "cowboy"
  And an empty file named "cowboy/rides a horse.txt"
  When I run `cleanup cowboy`
  Then the output should contain:
  """
  abracadabra
  """
  # And I run `ls -1 clean-cowboy`
  # Then the output from "ls -1 clean-cowboy" should contain "rides-a-horse.txt"
```

Now we see all the error messages. In particular this should give us a hint:

```plain
touch: clean-cowboy/cowboy/rides-a-horse.txt: No such file or directory
```

There's no `clean-cowboy/cowboy` directory. The globbing gives us the entire filename, including the directory, so it ends up repeated.

We can use the `basename` command to strip off the extra stuff:

```bash
source_file=$(basename "$source_file")
```

That makes the full script:

```bash
source_dir=$1
target_dir="clean-$source_dir"

mkdir $target_dir

for source_file in $source_dir/*; do
  source_file=$(basename "$source_file")
  target_file=$(echo "$source_file" | tr 'A-Z_ ' 'a-z--')
  touch "$target_dir/$target_file"
done
```

This is now complaining because we're expecting to see "abracadabra", but we're not. Let's switch back to our real expectation and see what's happening.

```plain
Scenario: It replaces spaces with hyphens
  Given a directory named "cowboy"
  And an empty file named "cowboy/rides a horse.txt"
  When I run `cleanup cowboy`
  And I run `ls -1 clean-cowboy`
  Then the output from "ls -1 clean-cowboy" should contain "rides-a-horse.txt"
```

That's it. It passes.

The next case is a file with multiple spaces.

```plain
Scenario: It replaces multiple spaces with a single hyphen
  Given a directory named "universe"
  And an empty file named "universe/with       space.txt"
  When I run `cleanup universe`
  And I run `ls -1 clean-universe`
  Then the output from "ls -1 clean-universe" should contain "with-space.txt"
```

We need a way to edit the text. We'll use `sed`:

```bash
target_file=$(echo "$source_file" | tr 'A-Z_ ' 'a-z--' | sed -e 's/-\{1,\}/-/g')
```

Ok, we've got this working for the renaming part, but we're not actually copying those files, we're just making new files with the correct name.

Let's make a test that forces us to copy the files.

```plain
Scenario: The file contents are preserved
  Given a directory named "meals"
  And a file named "meals/BREAKFAST.txt" with:
  """
  eggs & bacon
  """
  And a file named "meals/Lunch Special.txt" with:
  """
  fish tacos
  """
  When I run `cleanup meals`
  And I run `cat clean-meals/breakfast.txt`
  And I run `cat clean-meals/lunch-special.txt`
  Then the output from "cat clean-meals/breakfast.txt" should contain "eggs & bacon"
```

Make it pass:

```plain
#!/bin/bash

source_dir=$1
target_dir="clean-$source_dir"

mkdir $target_dir

for source_file in $source_dir/*; do
  source_file=$(basename "$source_file")
  target_file=$(echo "$source_file" | tr 'A-Z_ ' 'a-z--' | sed -e 's/-\{1,\}/-/g')
  cp "$source_dir/$source_file" "$target_dir/$target_file"
done
```

## Implement the ambashed script in Ruby

Now delete all the code from `bin/cleanup` and re-implement the tests in Ruby.

Hints.

Remember that you have to tell the computer to use Ruby to execute the script:

```ruby
#!/usr/bin/env ruby
```

Also, recall that `ARGV` is where you'll find the commands/options/arguments to the script. It's an array.

You will need some methods on [`String`](http://ruby-doc.org/core-2.0/String.html).

Also, check out [`Pathname`](http://ruby-doc.org/stdlib-2.0.0/libdoc/pathname/rdoc/Pathname.html) and [`FileUtils`](http://ruby-doc.org/stdlib-2.0.0/libdoc/fileutils/rdoc/FileUtils.html).

## Scheduling stuff with cron

Create a new directory called `words`:

{% terminal %}
$ mkdir words
{% endterminal %}

Go to the words directory:

{% terminal %}
$ cd words
{% endterminal %}

Inside of `words/` create a file called `numbers.txt` and add the following to it:

```plain
one
two
three
four
five
six
seven
eight
nine
ten
eleven
twelve
thirteen
fourteen
fifteen
```

### reading without opening a file

There are several commands that can let you see the contents of a file, even without opening it. These commands just dump out the contents of the file into your terminal window.

Try the following in your terminal:

{% terminal %}
$ cat numbers.txt
{% endterminal %}

{% terminal %}
$ head numbers.txt
{% endterminal %}

{% terminal %}
$ tail numbers.txt
{% endterminal %}

How are they different?

Now try adding the `-n` option to each command:

{% terminal %}
$ cat -n numbers.txt
{% endterminal %}

{% terminal %}
$ head -n 5 numbers.txt
{% endterminal %}

{% terminal %}
$ tail -n 5 numbers.txt
{% endterminal %}

What do you think `n` stands for? Does it mean the same thing in all the commands?

### writing without opening a file

You can also write to a file without opening it up, using the `echo` command and then piping the result of the echo command into a file:

{% terminal %}
$ echo "sixteen" > numbers.txt
$ tail numbers.txt
$ echo "seventeen" > numbers.txt
$ tail numbers.txt
{% endterminal %}

### waiting for input

The `tail` command has an option `-f` that makes it so that it keeps waiting for input.

Open a second terminal window, and go to the words directory.

Now, in one terminal window, say

{% terminal %}
$ tail -f numbers.txt
{% endterminal %}

And in the other directory, say:

{% terminal %}
$ echo "eighteen" > numbers.txt
$ echo "nineteen" > numbers.txt
$ echo "twenty" > numbers.txt
{% endterminal %}

### cron

Write a script that puts a timestamp in a log file.

In bash this is a bit easier than in Ruby, let's write the script both ways.

Let's call the script `timytime`.

In bash (`timeytime.sh`):

```bash
#!/bin/bash

echo date > ~/timeytime.log
```

Chmod +x it.

Run it: `./timeytime.sh`

Totally works.

In Ruby (`timeytime.rb`):

```ruby
#!/usr/bin/env ruby

File.open('~/timeytime.log', 'a') do |file|
  file.puts Time.now.to_s
end
```

Chmod +x it, and run it: `./timeytime.rb`. Broken.

{% terminal %}
./timeytime.rb:3:in `initialize': No such file or directory - ~/timeytime.log (Errno::ENOENT)
{% endterminal %}

It doesn't like not having a file to open. We need to make it first:

{% terminal %}
.../fileutils.rb:1165:in `initialize': No such file or directory - ~/timeytime.log (Errno::ENOENT)
{% endterminal %}

```ruby
#!/usr/bin/env ruby

require 'fileutils'

FileUtils.touch '~/timeytime.log'

File.open('~/timeytime.log', 'a') do |file|
  file.puts Time.now.to_s
end
```

OK, clearly it didn't like the `~`. We need to give it the full path to the file we want it to make:

```ruby
#!/usr/bin/env ruby

require 'fileutils'

filename = File.expand_path('../../timeytime.log', __FILE__)
FileUtils.touch filename

File.open(filename, 'a') do |file|
  file.puts Time.now.to_s
end
```

There, this now works.

Now pick one and rename it to `timetime`, and put it in your path:

```bash
$ mv timeytime.rb ~/bin/timeytime
```

Now, edit your crontab so that it runs this script every minute:

**NOTE** This will open in the default text editor, which is vim. Dammit.

{% terminal %}
$ crontab -e
{% endterminal %}

```bash
* * * * * ~/bin/timeytime
```

Now, tail the timeytime.log file:

```bash
$ tail -f ~/timeytime.log
```
