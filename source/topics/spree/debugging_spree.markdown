---
layout: page
title: Debugging Your Spree Application
section: Building Applications with Spree
---

Now that you are able to get around the source it is time to use Ruby's
debugging tools to help you bridge your mental understanding of the code and
the actual way the code is working

### Setting up Debugger

Debugger is a gem that allows us to interrupt normal operation flow giving us
a chance to inspect the state of the application at a particular state.

* Open `Gemfile` and add the following code:

```ruby
group :development do
  gem 'debugger'
end
```

* Run `bundle install`

This will install the debugger gem and all of it's necessary requirements.

### Debugging the Root Page

Again, let's visit the application's root page, this time setting up a debug
session to give us a little more understanding of the state of the code.

* Open the `spree_frontend` gem with Bundler.

{% terminal %}
$ bundle open spree_frontend
{% endterminal %}

* Open the `app/controllers/spree/home_controller.rb` and append the following:

```
module Spree
  class HomeController < Spree::StoreController
    helper 'spree/products'
    respond_to :html

    def index
      debugger
      @searcher = Spree::Config.searcher_class.new(params)
      @searcher.current_user = try_spree_current_user
      @searcher.current_currency = current_currency
      @products = @searcher.retrieve_products
    end
  end
end
```

* Run `rails server`
* View `http://localhost:3000` in your browser.

The application should start to load and then halt its loading before any data
appears on the screen.

* Return to the terminal window where you launched the server

The server should be *paused at the line of code immediately following* the
`debugger` line.

```plain
[3, 12] in /Users/burtlo/.rvm/gems/ruby-2.0.0-p195@spree/gems/spree_frontend-2.0.3/app/controllers/spree/home_controller.rb
   3      helper 'spree/products'
   4      respond_to :html
   5
   6      def index
   7        debugger
=> 8        @searcher = Spree::Config.searcher_class.new(params)
   9        @searcher.current_user = try_spree_current_user
   10        @searcher.current_currency = current_currency
   11        @products = @searcher.retrieve_products
   12      end
(rdb:1)
```

We now have initiated an active debugging session.

### Debugging Commands

There are many [debugging commands](http://guides.rubyonrails.org/debugging_rails_applications.html#the-shell)
available. We are going to practice the most essential so that we are proficient
system debuggers.

#### irb

The most powerful, versatile command available to you is **irb**. This command
allows you to start an interactive sessions, similar to launching the irb
command from the terminal outside of a debugging session.

* Start or continue an active debugging session
* Type the command `irb`

```plain
[3, 12] in /Users/burtlo/.rvm/gems/ruby-2.0.0-p195@spree/gems/spree_frontend-2.0.3/app/controllers/spree/home_controller.rb
   3      helper 'spree/products'
   4      respond_to :html
   5
   6      def index
   7        debugger
=> 8        @searcher = Spree::Config.searcher_class.new(params)
   9        @searcher.current_user = try_spree_current_user
   10        @searcher.current_currency = current_currency
   11        @products = @searcher.retrieve_products
   12      end
(rdb:1) irb
2.0.0p195 :001 >
```

An irb prompt should appear and you are now able to inspect the state of your
rails application.

* Explore the various variables that are currently available: `params`;
  `request`; and `response`.

The current information and the complete state of the request are available.
You can interrogate and change the state of most of these request parameters to
explore different states.

* When you are done debugging in *irb* type command `exit`.

This will complete the irb session and allow you to continue with additional
debugging commands.

#### next

Our break point was placed above any of our controller logic. We were not able
to inspect the state of any of the instance variables that we create later in
the controller. We could remove our `debugger` line and move it later within
the controller and start our debug session again. It would be easier to instead
to move our debugging cursor to the next line of execution.

* Start or continue an active debugging session

```plain
[3, 12] in /Users/burtlo/.rvm/gems/ruby-2.0.0-p195@spree/gems/spree_frontend-2.0.3/app/controllers/spree/home_controller.rb
   3      helper 'spree/products'
   4      respond_to :html
   5
   6      def index
   7        debugger
=> 8        @searcher = Spree::Config.searcher_class.new(params)
   9        @searcher.current_user = try_spree_current_user
   10        @searcher.current_currency = current_currency
   11        @products = @searcher.retrieve_products
   12      end
(rdb:1) next
```

* Type the command `next`

This command will move you to the next line of execution. This is equivalent to
what most visual debuggers refer to as 'step over'.

```plain
[3, 12] in /Users/burtlo/.rvm/gems/ruby-2.0.0-p195@spree/gems/spree_frontend-2.0.3/app/controllers/spree/home_controller.rb
   4      respond_to :html
   5
   6      def index
   7        debugger
   8        @searcher = Spree::Config.searcher_class.new(params)
=> 9        @searcher.current_user = try_spree_current_user
   10        @searcher.current_currency = current_currency
   11        @products = @searcher.retrieve_products
   12      end
   13    end
(rdb:1) irb
```

#### print and p

Starting and stopping an **irb** session every time you want to inspect
variables is not the most ideal. That is why there are additional commands
like `print` and `p`.

* Start or continue an active debugging session

* Type the command `next`

This should place you at line 9 of your current application.

```plain
[3, 12] in /Users/burtlo/.rvm/gems/ruby-2.0.0-p195@spree/gems/spree_frontend-2.0.3/app/controllers/spree/home_controller.rb
   4      respond_to :html
   5
   6      def index
   7        debugger
   8        @searcher = Spree::Config.searcher_class.new(params)
=> 9        @searcher.current_user = try_spree_current_user
   10        @searcher.current_currency = current_currency
   11        @products = @searcher.retrieve_products
   12      end
   13    end
(rdb:1) irb
```

* Type the command `print @searcher`

This should output for you the `to_s` representation of the `@searcher` object.

```
(rdb:38) print @searcher
#<Spree::Core::Search::Base:0x007fd192db7638>nil
```

* Type the command `p @searcher`

This should output for you the `inspect` representation of the `@searcher`
object.

```
(rdb:38) p @searcher
#<Spree::Core::Search::Base:0x007fd192db7638 @current_currency="USD", @properties={:taxon=>nil, :keywords=>nil, :search=>nil, :per_page=>12, :page=>1}>
```

#### continue

When we are done with the debugging we want to return control to the rails
process to allow it to finish the execution of the request or move to the
next breakpoint.

* Start or continue an active debugging session

* Type the command `continue`

This will stop the debugging session and allow the index page to render.

#### Shortcuts

Several of the commands that we used have shortcuts to make it faster to
interact with the debugger.

* Most of the commands, like `next` and `continue` can be shortened to
  the first letter of the command.

Try using `n` instead of `next` and `c` instead of `continue`.

* The last commmand executed will be executed again if you simply press ENTER
  with no new command specified.

This is particularly useful if you are using `next` to move through a large
body of code. Continuing to type `next` or `n` for each step may become
tiresome so rely on this shortcut to save you from having to repeat yourself.

#### Debugger Gotcha

One important gotcha about using the debugger
is that that execution will pause on the line immediately *following* the `debugger` instruction.

So it is important to not use `debugger` as the **last line in a method**. If you do, the debugging session will start wherever that method returns to.

* Add debugger to the last line of the index action:

```ruby
module Spree
  class HomeController < Spree::StoreController
    helper 'spree/products'
    respond_to :html

    def index
      @searcher = Spree::Config.searcher_class.new(params)
      @searcher.current_user = try_spree_current_user
      @searcher.current_currency = current_currency
      @products = @searcher.retrieve_products
      debugger
    end
  end
end
```

* Run `rails server`
* View `http://localhost:3000` in your browser.
* Return to the terminal window that you launched the server

The debug session has started in the implicit render module's `send_action`.

```plain
[0, 9] in /Users/burtlo/.rvm/gems/ruby-1.9.3-p429/gems/actionpack-3.2.14/lib/action_controller/metal/implicit_render.rb
   1  module ActionController
   2    module ImplicitRender
   3      def send_action(method, *args)
   4        ret = super
=> 5        default_render unless response_body
   6        ret
   7      end
   8
   9      def default_render(*args)
(rdb:1)
```

### Something is Rotten in State of Debugging

At this point we have been modifying the code of the **spree_frontend** gem.
Which is very dangerous. Modifying the code within the gem itself is easy to do
but it comes with the risk of permanently changing the gem and not knowing
the differences. If we were to make a mistake we would need to uninstall and
then reinstall the gem.

Also, whenever we want to move, remove, or add a breakpoint in a gem we need
to restart our rails server.

When debugging it would be safer to instead make the changes within our own
project. But in our case we do not own the source code, how do we make those
changes?

* Remove all `debugger` lines from the **spree_frontend** gem that you made
  to the `home_controller.rb`.
* Within your Spree project create `app/controllers/spree/home_controller.rb`
  and copy the contents of `home_controller.rb` from the **spree_frontend** gem:

```
module Spree
  class HomeController < Spree::StoreController
    helper 'spree/products'
    respond_to :html

    def index
      @searcher = Spree::Config.searcher_class.new(params)
      @searcher.current_user = try_spree_current_user
      @searcher.current_currency = current_currency
      @products = @searcher.retrieve_products
    end
  end
end
```

* Add the `debugger` line within the new `home_controller.rb` that you created
  somewhere within the controller.
* Run `rails server`
* View `http://localhost:3000` in your browser.
* Return to the terminal window that you launched the server

The server should be *paused at the line of code immediately following* the
`debugger` line.

So instead of modifying the contents of the gem we have copied the contents
and modified within our application. This works because of Ruby's open classes
and is often called Monkeypatching.

When debugging like this it is far safer to monkeypatch our `debugger` line into
a piece of code instead of modifying the original gem.
