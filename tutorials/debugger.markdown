# Ruby Debugger

Most of the time simple output statements using `warn`, `raise`, or a logger will help you find your issue. But sometimes you need the big guns, and that means `ruby-debug`.

## Ruby-Debug

The `ruby-debug` package has had some rocky times during the transition from Ruby 1.8.7 to 1.9.2 and beyond. But now, finally, the debugger is reliable and usable.

### Installation

Assuming you're writing your app in Ruby 1.9 and using Bundler, just add the dependency to your development gems:

```ruby
group :development do
  gem 'ruby-debug19'
end
```

If you left off the `19` you would instead get the package for use with 1.8.7 and it's incompatible with 1.9. Note that the debugger relies on native extensions, so you need to have the Ruby headers and compilation tools setup on your system.

### Booting

When you start your Rails server or console you have to explicitly enable the debugger. For the server:

```bash
rails server --debug
```

And for the console:

```bash
rails console --debug
```

Now the debugger is loaded. Anywhere we insert breakpoints will trigger it, and auto-reloading is supported like normal.

### Interrupting Execution

Wherever you want to inspect execution just add a call to `debugger` like this:

```ruby
def create
  @product = Product.new(params[:product])
  debugger
  if @product.save
    #...
```

If the debugger is *not* loaded when execution hits the `debugger` line, there will be a warning in the output log. If it is properly loaded, execution will pause and drop you into the debugger interface. If you're in the middle of a request this console will appear in the window/process where your server is normally outputting it's logging information:

```
[Timestamp] INFO  WEBrick::HTTPServer#start: pid=78725 port=3000
/path/to/your/app/controllers/products_controller.rb:19
if @product.save
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
  @product = Product.new(params[:product])
  debugger
  if @product.save
    redirect_to @product, :notice => "Successfully created product."
    # ...
```

See how `next` moves the execution marker:

```irb
/Users/jcasimir/Dropbox/Projects/jsmerchant/app/controllers/products_controller.rb:19
if @product.save
(rdb:2) next
/Users/jcasimir/Dropbox/Projects/jsmerchant/app/controllers/products_controller.rb:22
render :action => 'new'
(rdb:2) 
```

It advances from the `if @product.save` to the `redirect_to`.

#### `step`

The `step` command, on the other hand, will move the execution marker to the next instruction to be executed even in a called method. Using the same controller code as before, see how `step` has a different effect:

```irb
/Users/jcasimir/Dropbox/Projects/jsmerchant/app/controllers/products_controller.rb:19
if @product.save
(rdb:2) step
/Users/jcasimir/.rvm/gems/ruby-1.9.2-p290@jsmerchant/gems/activerecord-3.0.9/lib/active_record/transactions.rb:239
rollback_active_record_state! do
(rdb:2) 
```

Execution has now paused inside the implementation of `.save` within `ActiveRecord`. This can be useful if you really want to dig through Rails internals, but for most purposes I find `step` impractical.

#### Simple Variables

The debugger executes in the same scope as the `debugger` instruction, so you can view and manipulate any variables available there. For instance, to see the value of `@product`:

```irb
/Users/jcasimir/Dropbox/Projects/jsmerchant/app/controllers/products_controller.rb:19
if @product.save
(rdb:8) @product
#<Product id: nil, title: "Apples", price: nil, description: nil, image_url: nil, created_at: nil, updated_at: nil, stock: 0>
(rdb:8) 
```

#### Watching Variables with `display`

Typically when running the debugger you're interested in how a variable changes over a series of instructions. First, let's move the debugger call up one line in our action:

```ruby
def create
  debugger
  @product = Product.new(params[:product])    
  if @product.save
    #...
```

I run that code then use the `display` command like this:

```irb
/Users/jcasimir/Dropbox/Projects/jsmerchant/app/controllers/products_controller.rb:18
@product = Product.new(params[:product])    
(rdb:2) display @product
1: @product = 
(rdb:2) next
1: @product = Apples
/Users/jcasimir/Dropbox/Projects/jsmerchant/app/controllers/products_controller.rb:19
if @product.save
(rdb:2) next
1: @product = Apples
/Users/jcasimir/Dropbox/Projects/jsmerchant/app/controllers/products_controller.rb:22
render :action => 'new'
(rdb:2) 
```

* In line 3 I tell the debugger to `display @product`. 
* It will then show a line like #4 for each prompt. You can see `@product` starts as `nil` (a blank because the debugger calls `.to_s` on `nil` which gives you an empty string). 
* Then after I call `next` and a value is assigned to `@product`, the value appears on line 6. 
* Notice that the display persists for later instructions like line 10. 
* *NOTE:* In this application, `Product` instances have a `to_s` that just returns their `title` attribute, which here causes the display of `Apples`.

In fact, when you `display` a variable it will show up for all further debugger calls in that process. So if your server stays running, you'll see variables displayed from a previous request's debugging. Want to stop displaying a variable? Just call `undisplay` with the number displayed next to the variable. So in this case, I'd see the `1:` next to `@product` and call `undisplay 1`.

#### Dropping into IRB

Not satisfied with those options? Just call the `irb` instruction and the debugger will drop you into a normal IRB console. Use all your normal Ruby functions and tricks, then `exit` to get back to the debugger. You can continue to invoke other instructions and any data you created/changed in the IRB session is brought back into the debugging session.

### References

* Rails guide on debugging and the debugger: http://guides.rubyonrails.org/debugging_rails_applications.html
* Extensive details about `ruby-debug` are available here: http://bashdb.sourceforge.net/ruby-debug.html

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

Overall, I'd say that the RubyMine debugger does some things well but overall feels like a complex solution on top of a complex tool on top of a simple language. It wouldn't be the first tool I deploy to assess a problem.