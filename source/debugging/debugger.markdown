---
layout: page
title: Debugger
---

Tests, logging (e.g. `info`, `warn`, `debug`), traditional output (e.g. `puts`), raising exceptions will assist you with finding most issues. However, there are situations when you are unsure about the state of several variables within a context or the state of a complex object within a given interaction. This is when it is useful to employ an interactive debugger.

Ruby's `ruby-debug` is a powerful tool that allows for you to stop the execution of the application at a particular moment and to investigate and interact within that context.

* Output the state and value of objects, variables all available within that scope.
* Move step-by-step through the code to ensure that your mental model of the execution maps to the actual execution.
* Change the state of objects to quickly test the effects within the system

## Ruby-Debug

### Installation

The following examples demonstrate how you can provide ruby debugging within your rails project by specifying the `ruby-debug` gem into your Gemfile.

Note that the debugger relies on native extensions, so you need to have the Ruby headers and compilation tools setup on your system.

#### Ruby 1.8.7

Assuming you're using Bundler, add the dependency to your development gems in the `Gemfile`:

```ruby
group :development do
  gem 'ruby-debug'
end
```

#### Ruby 1.9.X

Assuming you're using Bundler, add the dependency to your development gems in the `Gemfile`:

```ruby
group :development do
  gem 'ruby-debug19'
end
```

If you left off the `19` you would instead get the package for use with 1.8.7 and it is incompatible with 1.9.

### Booting

When you start your Rails server or console you have to explicitly enable the debugger. For the server:

```bash
rails server --debug
```

And for the console:

```bash
rails console --debug
```

Now the debugger is loaded, and any _breakpoint_ in your code will trigger it.  Auto-reloading is supported as normal.

### Interrupting Execution

Wherever you want to inspect execution add a call to `debugger` like this:

```ruby
def create
  @article = Article.new(params[:article])
  debugger
  if @article.save
    #...
```

If the debugger is *not* loaded when execution hits the `debugger` line, there will be a warning in the output log. 

If it is properly loaded, execution will pause and drop you into the debugger interface. If you're in the middle of a request this console will appear in the window/process where your server is normally outputting its logging information:

```
[Timestamp] INFO  WEBrick::HTTPServer#start: pid=78725 port=3000
/path/to/your/app/controllers/articles_controller.rb:19
if @article.save
(rdb:2) 
```

Which can be read like this:

* Line 1: Normal server startup line
* Line 2: The line of code containing the call to `debugger`
* Line 3: The next line of code pending execution
* Line 4: The debugger prompt

Now you have incredible power available to you with a few simple commands.

### Basic Usage

#### `continue`

Say you figure out the issue and you're ready to finish the request. Just issue the `continue` instruction and execution will keep running from wherever it paused.

#### `quit`

Rarely you want to exit the application all together. Quit will halt execution without finishing the request.

#### `list`

The `list` instructions shows the context of the current code, five lines before and four lines after the current execution point.

#### `next`

The `next` instruction will run the following instruction in the current context and move the marker to the next line in that context. Given this controller code:

```ruby
def create
  @article = Article.new(params[:article])
  debugger
  if @article.save
    redirect_to article_path(@article), :notice => "Your article was created."
  # ...
```

See how `next` moves the execution marker:

```irb
/path/to/your/app/controllers/articles_controller.rb:19
if @article.save
(rdb:2) next
/path/to/your/app/controllers/articles_controller.rb:20
redirect_to article_path(@article), :notice => "Your article was created."
(rdb:2) 
```

It advances from the `if @article.save` to the `redirect_to`.

#### `step`

The `step` command, on the other hand, will move the execution marker to the next instruction to be executed even in a called method. Using the same controller code as before, see how `step` has a different effect:

```irb
/path/to/your/app/controllers/articles_controller.rb:19
if @article.save
(rdb:2) step
/Users/you/.rvm/gems/ruby-1.9.2-p290@jsmerchant/gems/activerecord-3.0.9/lib/active_record/transactions.rb:239
rollback_active_record_state! do
(rdb:2) 
```

Execution has now paused inside the implementation of `.save` within `ActiveRecord`. This can be useful if you really want to dig through Rails internals, but for most purposes I find `step` impractical.

#### `eval` Ruby Code

You can use the `eval` instruction to run arbitrary ruby or display the value of a variable. For instance, to see the value of `@product`:

```irb
/path/to/your/app/controllers/articles_controller.rb:19
if @product.save
(rdb:8) eval @article
#<Article id: nil, title: nil, body: nil, created_at: nil, updated_at: nil, author_name: "Stan", editor_id: nil> 
(rdb:8) 
```

#### Watching Variables with `display`

Typically when running the debugger you're interested in how a variable changes over a series of instructions. First, let's move the debugger call up one line in our action:

```ruby
def create
  debugger
  @article = Article.new(params[:article])    
  if @article.save
    #...
```

I run that code then use the `display` command like this:

```irb
/path/to/your/app/controllers/articles_controller.rb:18
@article = Article.new(params[:article])    
(rdb:2) display @article
1: @article = 
(rdb:2) next
1: @article = #<Article id: nil, title: 'Hello', body: 'World'> 
/path/to/your/app/controllers/articles_controller.rb:19
if @article.save
(rdb:2) next
1: @product = #<Article id: 22, title: 'Hello', body: 'World'>
/path/to/your/app/controllers/articles_controller.rb:22
redirect_to article_path(@article), :notice => "Your article was created."
(rdb:2) 
```

* In line 3 I tell the debugger to `display @article`. 
* It will then show a line like #4 for each prompt. You can see `@article` starts as `nil` (a blank because the debugger calls `.to_s` on `nil` which gives you an empty string). 
* Then after I call `next` and a value is assigned to `@article`, the value appears on line 6. 
* Notice that the display persists for later instructions like line 10. 

In fact, when you `display` a variable it will show up for all further debugger calls in that process. So if your server stays running, you'll see variables displayed from a previous request's debugging. Want to stop displaying a variable? Call `undisplay` with the number displayed next to the variable. So in this case, I'd see the `1:` next to `@article` and call `undisplay 1`.

#### Dropping into IRB

Not satisfied with those options? Call the `irb` method and the debugger will drop you into a normal IRB console. Use all your normal Ruby functions and tricks, then `exit` to get back to the debugger. You can continue to invoke other instructions and any data you created/changed in the IRB session is persisted in the debugging session.

### Shortcuts

Almost all of the commands (e.g. `continue`,`next`,`step`) can be executed by using the first letter of the command. Allowing you to `continue` by entering the letter `c`.

All the commands that you have executed are in a command buffer that you can interact with by using the arrow keys. The `up-arrow` will move you back in history by one command. The `down-arrow` will move you forward in history.

The last command that you executed will be executed again by pressing the `return` key. This is extremely useful if you want to continually `step` through the code and want to save yourself the requirement of typing `s` or accessing the previous commands in the history.

### Rails: `request`

There are times when you are debugging the `request` within Rails. Perhaps you have a client, caching service, or routing service that sets or configures a number of http request environment variables. You may set a _breakpoint_ within your application and then start the `irb` to interact with the `request` object only to be met with the following error message:

```irb

/path/to/your/app/controllers/articles_controller.rb:18
@article = Article.new(params[:article])
(rdb:2) irb
ruby-1.9.2-p180 :001 > request.env
RuntimeError: can't add a new key into hash during iteration
    from /Users/you/.rvm/gems/ruby-1.9.2-p180@development/gems/rack-1.1.2/lib/rack/request.rb:201:in `[]='
    # ...
```

The following is caused because the `env` method is frozen and the interactive session is attempting to perform an operation on it which it will not allow. The way around this is  to `dup` the `env` and you will be allowed to inspect the request and the request environment variables.

```irb
ruby-1.9.2-p180 :009 > request.env.dup
 => {"GATEWAY_INTERFACE"=>"CGI/1.1", "PATH_INFO"=>"/", "QUERY_STRING"=>"", "REMOTE_ADDR"=>"127.0.0.1", "REMOTE_HOST"=>"localhost", "REQUEST_METHOD"=>"GET", "REQUEST_URI"=>"http://localhost:3000/", "SCRIPT_NAME"=>"", "SERVER_NAME"=>"localhost", "SERVER_PORT"=>"3000", "SERVER_PROTOCOL"=>"HTTP/1.1"
    # ...
```

## IDE Support

If using the debugger is rare, then using the debugger in an IDE must be the white elephant of Ruby development. But let's checkout how Rubymine tries to make using the debugger easier.

### RubyMine Setup

Load your project normally in RubyMine. When you start the server, look for the "Debug" icon just to the right of the normal green play button. It has a green bug with a light blue arrow. 

Click that and you'll be prompted to install `ruby-debug-base19x` into the system gems and accept it. Try to run again and you'll be prompted to install `ruby-debug-ide`. Once they're both installed you're ready to go.

### Setting Breakpoints

The first thing you want to do is *remove* any explicit calls to `debugger`. If execution hits one of those calls while using the IDE debugger, you'll get an error like this:

```
undefined method `run_init_script' for Debugger:Module
```

Once those are removed, you can set a breakpoint in RubyMine by left-clicking in the grey gutter to the left of the instruction. A red dot should appear.

Cause the code to run and RubyMine will snatch focus to show you the debugging tab.

### Usage

The concepts are the same as the normal debugger.

* To execute one instruction at a time, like `next`, click the `Step Over` button that's two small circles connected by an arrow
* To drop into any called methods like `step`, click the `Step Into` button
* To `continue` execution, click the green play button on the left menu
* To monitor the value of a variable like `display`, click the [+] in the *Watches* pane and enter the name of the variable

<div class="opinion">
<p>Overall, I'd say that the RubyMine debugger does some things well but overall feels like a complex solution on top of a complex tool on top of a simple language. It wouldn't be the first tool I deploy to assess a problem.</p>
</div>

## Exercises

[TODO: JSBlogger Setup]

1. Start the server _without_ `--debug`, then call `debugger` in the code, and observe the output
2. Start the server _with_ `--debug` and add a breakpoint to a controller method. Trigger that breakpoint and experiment with each of these commands:
  * `eval`
  * `list`
  * `next`
  * `step`
  * `continue`
3. If you have RubyMine available, set a breakpoint through the GUI, trigger it, then experiment with:
  * variable watches
  * step over 
  * step into
  * continue
4. Try to view/manipulate the frozen `request` object, then call `dup` and explore the data
5. `debugger` is just a method. Try combining it with a conditional branch to only execute on a certain pathway through your code (like a `nil` input, for example).

## References

* Rails guide on debugging and the debugger: http://guides.rubyonrails.org/debugging_rails_applications.html
* Extensive details about `ruby-debug` are available here: http://bashdb.sourceforge.net/ruby-debug.html
* RubyMine's info on the debugger: http://www.jetbrains.com/ruby/features/ruby_debugger.html
