---
layout: page
title: Sinatra with Active Record
sidebar: true
---

Working with Active Record outside of Rails is not difficult, but it requires
you to jump through a few hoops that Rails generally takes care of for you.

We will for the most part stick with conventions that people are used to,
because there's no reason to surprise people unless you have a good reason.

We'll start with plain Ruby, add in Active Record to manipulate the database,
then mix in Sinatra for HTTP interaction.

At every step we will write tests before adding any code.

## Dependencies

* Sinatra
* Active Record
* SQLite3

For testing:

* Minitest
* Rack Test

Other dependencies

* git

## Creating a Stand-Alone Project

Create a project directory, and go to it in your terminal.

{% terminal %}
mkdir ideabox
cd ideabox
{% endterminal %}

### Starting the Project

We'll start with a test. Create an empty test directory:

{% terminal %}
mkdir test
{% endterminal %}

And create a file called `test/ideabox_test.rb`.

Our first goal is simply to wire up the project so that our tests connect to
the rest of our code.

Create a simple test:

```ruby
class IdeaboxTest < MiniTest::Unit::TestCase
  def test_it_works
    assert_equal 42, Ideabox.answer
  end
end
```

Run it:

{% terminal %}
ruby test/ideabox_test.rb
{% endterminal %}

You'll get an error in the vein of:

```plain
test/ideabox_test.rb:1:in `<main>': uninitialized constant MiniTest (NameError)
```

```ruby
require 'minitest/autorun'

class IdeaboxTest < MiniTest::Unit::TestCase
  # ...
end
```

This gives us a new error:

```plain
IdeaboxTest#test_it_works:
NameError: uninitialized constant IdeaboxTest::Ideabox
    test/ideabox_test.rb:6:in `test_it_works'
```

The Ideabox constant could refer to a class or a module. We don't know what we
need yet, but using a module to namespace projects is a very common and
idiomatic approach. Let's start there and change it if we see that we need to.

Add an empty module above the test suite inside the test file:

```ruby
require 'minitest/autorun'

module Ideabox
end

class IdeaboxTest < MiniTest::Unit::TestCase
  # ...
end
```

This gives us a new error:

```plain
IdeaboxTest#test_it_works:
NoMethodError: undefined method `answer' for Ideabox:Module
    test/ideabox_test.rb:9:in `test_it_works'
```

We can define the method in Ideabox to change the error:

```ruby
module Ideabox
  def self.answer
  end
end
```

Up until now we've been getting errors, now we get our first failure:

```plain
IdeaboxTest#test_it_works [test/ideabox_test.rb:11]:
Expected: 42
  Actual: nil
```

Hard-code 42 into the method to get it to pass.

### Putting Things Where They Belong

For the moment all of our code lives in a single file. We need to move the
project code out of our test file.

#### Separating out Library Code

Create a directory `lib/` in the root of your project and create a file
`lib/ideabox.rb`.

Move the `Ideabox` module from the test into the `lib/ideabox.rb` file, and
run your test.

We're back to an error that says we don't know anything about an Ideabox
constant.

```plain
IdeaboxTest#test_it_works:
NameError: uninitialized constant IdeaboxTest::Ideabox
    test/ideabox_test.rb:6:in `test_it_works'
```

Require the `ideabox` file in the test:

```ruby
require 'minitest/autorun'
require './lib/ideabox'

class IdeaboxTest < MiniTest::Unit::TestCase
  def test_it_works
    assert_equal 42, Ideabox.answer
  end
end
```

We can manipulate the load path in order to get rid of the `./lib/`.

```ruby
$:.unshift File.expand_path("./../../lib", __FILE__)

require 'minitest/autorun'

require 'ideabox'

class IdeaboxTest < MiniTest::Unit::TestCase
  def test_it_works
    assert_equal 42, Ideabox.answer
  end
end
```

Our project now looks like this:

{% terminal %}
.
├── lib
│   └── ideabox.rb
└── test
    └── ideabox_test.rb
{% endterminal %}

This is a good start, but we're missing a couple of essential pieces before we
have a full-fledged ruby project.

### Adding a README

First, there's no README. We'll add a simple markdown file called `README.md`:

```plain
# Ideabox

A small Ruby application that demonstrates how to use Active Record with
Sinatra.
```

### Running the Tests with Rake

Next, we'll add a default rake task to run the test suite. Even though
there's only one file, it's nice to have this from the start. It's a lot
faster to type `rake` than `ruby test/ideabox_test.rb`.

Create a file in the root of the project named `Rakefile`, and add this to it:

```ruby
$:.unshift File.expand_path("./../lib", __FILE__)
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.pattern = "test/**/*_test.rb"
end

task default: :test
```

### Creating a Test Helper

Now, move the require statements out of the test file and put it in
`test/test_helper.rb`:

```ruby
$:.unshift File.expand_path("./../../lib", __FILE__)

require 'minitest/autorun'
require 'ideabox'
```

We need to require the test helper in the `ideabox_test.rb` file:

```ruby
require './test/test_helper'

class IdeaboxTest < MiniTest::Unit::TestCase
  # ...
end
```

The test should pass.

#### Creating a Savepoint

The project looks like this:

{% terminal %}
.
├── README.md
├── Rakefile
├── lib
│   └── ideabox.rb
└── test
    ├── ideabox_test.rb
    └── test_helper.rb
{% endterminal %}

Initialize a git repository, and add and commit the files:

{% terminal %}
git init
git add .
git commit -m "Create a stand-alone Ruby project tested with minitest"
{% endterminal %}

## Wiring up Active Record

We're going to store ideas in the database. The ideas will be very simple,
containing a single field: `description`.

A simple file store such as PStore or YAML::Store would probably be good
enough for our needs, but we'll go ahead and point the big guns at it.

Enter Active Record.

### Asserting that Idea Exists

If you look at most gems, they have the following structure:

{% terminal %}
.
└── lib
.   └── gemname
.   │  └── domain_object_1.rb
.   │  └── domain_object_2.rb
.   └── gemname.rb
{% endterminal %}

Often `lib/gemname.rb` will only have the code that requires the rest of the
project, but sometimes it will contain a little bit of code as well.

One way to structure test files is to have the same path as to the library
file, but replacing `lib` with `test`. For example:

{% terminal %}
lib/ideabox/idea.rb
test/ideabox/idea.rb
{% endterminal %}

It isn't always necessarily a great idea to have exactly one test file per
library file, but it's a reasonable place to start.

Since we're going to put domain objects within `lib/ideabox/*` we need an
`ideabox` directory under test:

{% terminal %}
mkdir test/ideabox
{% endterminal %}

Create file named `test/ideabox/idea_test.rb` where we can start
developing the Idea model.

```ruby
require './test/test_helper'

class IdeaTest < MiniTest::Unit::TestCase

  def test_it_exists
    idea = Idea.new(:description => 'A wonderful idea!')
    assert_equal 'A wonderful idea!', idea.description
  end

end
```

We're informed that we have no Idea.

```plain
NameError: uninitialized constant IdeaTest::Idea
```

Let's define the class within the test file, as before:

```ruby
require './test/test_helper'

class Idea
end

class IdeaTest < MiniTest::Unit::TestCase
  # ...
end
```

Run the tests:

```plain
ArgumentError: wrong number of arguments(1 for 0) in `initialize'
```

Rather than do the stupidest thing that could possibly work, let's go ahead
and make Idea an Active Record model.

```ruby
class Idea < ActiveRecord::Base
end
```

That blows up:

```plain
test/ideabox/idea_test.rb:3:in `<main>': uninitialized constant ActiveRecord (NameError)
```

We need to require Active Record:

```ruby
require './test/test_helper'
require 'active_record'

class Idea < ActiveRecord::Base
# ...
```

You may get a complaint that it can't find Active Record. If that's the case,
install it with `gem install activerecord` and try again.

We now get an `ActiveRecord::ConnectionNotEstablished:
ActiveRecord::ConnectionNotEstablished` error.

Add the command to connect to the database:

```ruby
require './test/test_helper'
require 'active_record'

db_options = {adapter: 'sqlite3', database: 'ideabox_test'}
ActiveRecord::Base.establish_connection(db_options)

class Idea < ActiveRecord::Base
end
```

Now we're getting somewhere:

```plain
ActiveRecord::StatementInvalid: Could not find table 'ideas'
```

We're going to need a migration. Again, let's create the migration in the test
file, and instantiate and run the migration when we run the tests:

```ruby
# ...
ActiveRecord::Base.establish_connection(db_options)

class CreateIdeas < ActiveRecord::Migration
  def change
    create_table :ideas do |t|
      t.string :description
    end
  end
end

CreateIdeas.new.change

class Idea < ActiveRecord::Base
# ...
```

Run the tests, and they should pass.

Run them one more time, and they should fail with an
`ActiveRecord::StatementInvalid` error because the table already exists, and
we're trying to create it again.

Rescue the error:

```ruby
begin
  CreateIdeas.new.change
rescue ActiveRecord::StatementInvalid
  # it's probably OK
end
```

You should now be able to run the tests as many times as you like, and they
should pass.

We've got Active Record wired together, and it didn't take very much code.

It's a bit of a mess with everything in the same file.

Eventually we'll need to configure the environment to have a different
database for test, development, and production. Also, the database connection
options should probably include things like a connection pool and timeouts.

### Putting Things Where They Belong

The test file contains:

* dependency management
* database configuration
* migration
* database connection management
* production code

Oh, yeah. And tests.

All of these things belong in separate places.

#### Creating a Gemfile

Our dependencies are implicit at the moment. Let's make them explicit by
adding a Gemfile:

```ruby
source 'https://rubygems.org'

gem 'activerecord', require: 'active_record'
gem 'sqlite3'
```

Run `bundle install`.

In the test helper add the following code right after manipulating the load
path:

```ruby
require 'bundler'
Bundler.require
```

Delete the `require 'active_record'` line from `idea_test.rb`.

#### Moving Database Configuration into `config/`

The convention for database configuration from Rails is to have a config
directory which contains configuration files like `database.yml` and code to
start the project for the correct environment.

There's no good reason to do anything else.

First, we need a `config` directory:

{% terminal %}
mkdir config
{% endterminal %}

Then we need a `database.yml` file. First let's just use the exact same
configuration that we already have:

```yaml
---
adapter: sqlite3
database: ideabox_test
```

Change the code in your test file to get the configuration from the YAML file
rather than from a hard-coded options hash:

```ruby
db_options = YAML.load(File.read('./config/database.yml'))
```

The tests should still be passing.

If you look at your project, you'll see that the database (`ideabox_test`)
lives in the root directory of your project. This should probably go in a
subdirectory called `db/`.

Create the directory, and then update the `database.yml` file to match:

```yaml
---
adapter: sqlite3
database: db/ideabox_test
```

Delete the database file from your project directory and run the tests.

They should pass, and a new database file should be created in the `db/`
directory.

#### Configuring the Environment

In Rails the config directory contains 4 environment files:

{% terminal %}
config
├── environment.rb
└── environments
.   ├── development.rb
.   ├── production.rb
.   └── test.rb
{% endterminal %}

We don't have a configurable environment yet, so let's just start with a
single `config/environment.rb` file that we'll require directly:

Move the code that connects to the database from the test file into `config/environment.rb`:

```ruby
db_options = YAML.load(File.read('./config/database.yml'))
ActiveRecord::Base.establish_connection(db_options)
```

Replace those two lines in the test file with a single line that requires the
environment file:

```ruby
require './config/environment'
```

This doesn't feel quite right. It seems like that require statement should go
in the test helper. That gives us the following test helper:

```ruby
$:.unshift File.expand_path("./../../lib", __FILE__)

require 'bundler'
Bundler.require
require './config/environment'
require 'minitest/autorun'
require 'ideabox'
```

Looking at it, though, it would make more sense to have the bundler stuff in
the environment file.

Requiring the project with `ideabox` can probably go there as well.

The environment file now looks like this:

```ruby
require 'bundler'
Bundler.require

db_options = YAML.load(File.read('./config/database.yml'))
ActiveRecord::Base.establish_connection(db_options)

require 'ideabox'
```

And the test helper has been reduced to the following:

```ruby
$:.unshift File.expand_path("./../../lib", __FILE__)

require './config/environment'
require 'minitest/autorun'
```

#### Moving Database Migrations

Rails puts database migrations in `db/migrate`, and again, we'll follow the
convention since there's no compelling reason not to. Create a migrate
subdirectory in db named `migrate`, and create an empty file
`0_create_ideas.rb` within the `db/migrate` directory.

The 0 stands in for the timestamp, which is basically just a version number.
It doesn't matter when the migration was generated or what the version is,
since we're only ever going to have the one migration.

Move the database migration class from the test suite into the migration file:

```ruby
class CreateIdeas < ActiveRecord::Migration
  def change
    create_table :ideas do |t|
      t.string :description
    end
  end
end
```

Notice that we're not moving the code that actually runs the migration, just
the class definition.

We're going to need a way to run the migrations. Following Rails standards,
how about a Rake task called `db:migrate`?

Within the Rakefile, add the following code:

```ruby
namespace :db do
  desc "migrate your database"
  task :migrate do
    require 'bundler'
    Bundler.require
    require './config/environment'
    ActiveRecord::Migrator.migrate('db/migrate')
  end
end
```

This will not allow us to roll back versions, but it will work for running all
the migrations that get placed in the `db/migrate` directory.

Delete your database file and run `rake db:migrate`.

#### Moving the production code into `lib/`.

Our test suite is looking a lot more like a test suite. We just have one last
thing to move out of there: the class definition for Idea.

Create a directory `lib/ideabox` and put the class definition of Idea in
`lib/ideabox/idea.rb`.

The tests will fail at this point, because the test suite no longer knows
about Idea.

Put the require statement in `lib/ideabox.rb`:

```ruby
require 'ideabox/idea'
module Ideabox
  def self.answer
    42
  end
end
```

#### Cleaning Up

Now that we have a real test, we can delete the initial wiring test.

Delete `test/ideabox_test.rb`, and the `answer` method in `lib/ideabox.rb`.

#### Creating a Savepoint

The project now looks like this:

{% terminal %}
.
├── Gemfile
├── Gemfile.lock
├── README.md
├── Rakefile
├── config
│   ├── database.yml
│   └── environment.rb
├── db
│   ├── ideabox_test
│   └── migrate
│       └── 0_create_ideas.rb
├── lib
│   ├── ideabox
│   │   └── idea.rb
│   └── ideabox.rb
└── test
    ├── ideabox
    │   └── idea_test.rb
    └── test_helper.rb
{% endterminal %}

Make sure your test is passing, and commit your changes.

### Testing Writes to the Database

Our test helped us drive the migration and configuration, but we haven't
actually used the database yet.

Let's change the wiring test to save the idea, and assert that once it has
been saved, we have an idea in the database:

```ruby
def test_it_exists
  Idea.create(:description => 'A wonderful idea!')
  assert_equal 1, Idea.count
end
```

Run the test, and it should pass. Run it again, and it will fail.

We're saving to the database, but nothing is making sure that each test starts
in a clean state.

We could use a gem like `database_cleaner`, but that seems like a big solution
to a small problem. We can wrap a transaction around the test and then cause
it to be rolled back after the assertion has completed:

```ruby
Idea.transaction do
  Idea.create(:description => 'A wonderful idea!')
  assert_equal 1, Idea.count
  raise ActiveRecord::Rollback
end
```

Delete the database file `db/ideabox_test` and re-run the migrations, making
sure that they're running for the test environment:

{% terminal %}
RACK_ENV=test rake db:migrate
{% endterminal %}

Rerun the test. It should pass.
Run it again. It should pass again.

It seems a bit unweildy to have to run the tests twice to prove that it's
working, so let's add some assertions:

```ruby
def test_it_exists
  assert_equal 0, Idea.count # guard clause
  Idea.transaction do
    Idea.create(:description => 'A wonderful idea!')
    assert_equal 1, Idea.count
    raise ActiveRecord::Rollback
  end
  assert_equal 0, Idea.count
end
```

The guard clause at the beginning ensures that we're starting out with a clean
database table. The second assertion proves that we've wired everything up so
that the Idea can be saved. The third assertion proves that we're not going to
influence later tests by accidentally leaving things in the database.

#### Extracting an 'Around' Method

Writing the transaction and raising the Rollback error is a bit tedious if you
need to do it over and over again. In RSpec we could configure an around hook
to take care of it for us:

```ruby
RSpec.configure do |c|
  c.around(:each) do |example|
    ActiveRecord::Base.connection.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
end
```

In Minitest it's not immediately obvious how to do this. We can write a method
that will take care of the details for us, though:

In the test helper, add this module:

```ruby
module WithRollback
  def temporarily(&block)
    ActiveRecord::Base.connection.transaction do
      block.call
      raise ActiveRecord::Rollback
    end
  end
end
```

Include the module in the test class and replace the call to `transaction`
with the `temporarily` call:

```ruby
class IdeaTest < MiniTest::Unit::TestCase
  include WithRollback

  def test_it_exists
    assert_equal 0, Idea.count
    temporarily do
      Idea.create(:description => 'A wonderful idea!')
      assert_equal 1, Idea.count
    end
    assert_equal 0, Idea.count
  end
end
```

#### Creating a Savepoint

If your tests are passing, commit your changes.

### Configuring the Environment

There are two parts to configuring the environment:

* detecting the correct environment, and
* fetching the correct options for that environment

We could do it the quick-and-dirty way, by just sticking the following in the
`config/environment.rb` file:

```ruby
# the quick-and-dirty way
ActiveRecord::Base.establish_connection(YAML::load(File.open("./config/database.yml"))[ENV['RACK_ENV'] || 'development'])
```

We could, but it seems like such a shame to make so many untested assumptions
on a single line.

We don't have to do it on one line, of course. The current environment file
looks like this:

```ruby
require 'bundler'
Bundler.require

db_options = YAML.load(File.read('./config/database.yml'))
ActiveRecord::Base.establish_connection(db_options)

require 'ideabox'
```

We could just add another piece to get the environment.

```ruby
# the quick-and-dirty way, part deux
environment = ENV.fetch('RACK_ENV') { 'development' }
db_options = YAML.load(File.read('./config/database.yml')[environment])
ActiveRecord::Base.establish_connection(db_options)
```

That still doesn't help us test it, though.

Let's be systematic about it, and create a DBConfig class and prove that it
does what we want.

#### Testing the Database Configuration

In `test/ideabox/db_config_test.rb` add the following test suite:

```ruby
require './test/test_helper'

class DBConfigTest < MiniTest::Unit::TestCase
  def test_default_file
    file = './config/database.yml'
    assert_equal file, DBConfig.new('env').file
  end
end
```

Require `lib/ideabox/db_config` in the test file and make the test pass by
implementing as little code as possible in the DBConfig class.

Let's force it to make the filename configurable:

```ruby
def test_override_file
  file = './test/fixtures/database.yml'
  assert_equal file, DBConfig.new('env', file).file
end
```

Then we'll make sure we can read environment-specific values. Create a fixture
file in `test/fixtures/database.yml`:

```yaml
---
fake:
  adapter: sqlite3
  database: db/ideabox_fake
```

The environment we're configuring is called 'fake'. In the real config file,
we'll have 'test', 'development', and eventually 'production'.

Add a test for reading the configuration options:

```ruby
def test_read_environment_specific_values
  config = DBConfig.new('fake', './test/fixtures/database.yml')
  options = {
    'adapter' => 'sqlite3',
    'database' => 'db/ideabox_fake'
  }
  assert_equal options, config.options
end
```

For good measure, let's also make sure that we're notified if we're trying to
connect without having configured the correct environment:

```ruby
def test_blow_up_for_unknown_environment
  config = DBConfig.new('real', './test/fixtures/database.yml')
  assert_raises DBConfig::UnconfiguredEnvironment do
    config.options
  end
end
```

You can make this pass in any number of ways. Here's one of them:

```ruby
require 'yaml/store'

class DBConfig
  class UnconfiguredEnvironment < StandardError; end

  attr_reader :file, :environment
  def initialize(environment, file='./config/database.yml')
    @environment = environment
    @file = file
  end

  def options
    read_only = true
    result = store.transaction(read_only) do
      store[environment]
    end
    unless result
      error = "No environment '#{environment}' configured in #{file}"
      raise UnconfiguredEnvironment.new(error)
    end
    result
  end

  private
  def store
    @store ||= YAML::Store.new(file)
  end
end
```

#### Putting it all together

The tests are passing, but the integration test that connects to the database
is not using the new DBConfig class.

First, change the `environment.rb` file to use the DBConfig class:

```ruby
require 'bundler'
Bundler.require

require 'ideabox/db_config'

environment = ENV.fetch('RACK_ENV') { 'development' }
config = DBConfig.new(environment).options
ActiveRecord::Base.establish_connection(config)

require 'ideabox'
```

If you run the tests, they fail with a NameError:

```plain
uninitialized constant DBConfig (NameError)
```

Require `'ideabox/db_config'` below the `Bundler.require`.

The next error is:

```plain
No environment 'development' configured in ./config/database.yml (DBConfig::UnconfiguredEnvironment)
```

Development? Really? We're running the tests, so we should not be looking for
development configuration options at all.

Change the `test/test_helper.rb` to add a line that sets the environment
before the environment gets required:

```ruby
ENV['RACK_ENV'] = 'test'
```

This changes the error message:

```plain
No environment 'test' configured in ./config/database.yml (DBConfig::UnconfiguredEnvironment)
```

Better.

We do have configuration options for test in the `database.yml`:

```yaml
---
adapter: sqlite3
database: db/ideabox_test
```

We need to specify that this is relevant to the test environment only:

```yaml
---
test:
  adapter: sqlite3
  database: db/ideabox_test
```

Run the tests.

#### Adding a Savepoint

If your tests are passing, commit your changes.

At this point we have a stand-alone ruby project that is successfully using
Active Record. We could easily add a command line interface on it, or we could
make it consumed queued up jobs, or we could wrap it in a web application.

In other words, this tutorial could have been named "Using Active Record
outside of Rails".

### Adding Sinatra to the Mix

Once again, let's start with a wiring test:

### Wiring up Sinatra

As before, we're going to write a very simple test to make sure that
everything is wired together correctly.

#### Dependencies

To do this we need a gem called `rack-test`, as well as Sinatra itself. Add
them to the Gemfile and run `bundle install`.

```ruby
source 'https://rubygems.org'

gem 'activerecord', require: 'active_record'
gem 'sqlite3'
gem 'sinatra', require: false

group :test do
  gem 'rack-test', require: false
end
```

Both Sinatra and Rack Test are only going to be used by a small portion of the
application.

Sinatra will only be used for the API, Rack Test will only be used for the API
tests. If we decide to run a command line interface for the application, that
code will not need Sinatra. Rather it will probably use `main` or `thor` or
some other gem that helps manage command line applications.

Both of these endpoints would need to load the main part of the application,
however -- the part under `lib/ideabox`, which gets loaded in
`config/environment.rb`.

Create a file `test/api_test.rb`, and add this code to it:

```ruby
require './test/test_helper'
require 'rack/test'
require 'sinatra/base'
require 'api'

class APITest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    IdeaboxAPI
  end

  def test_hello_world
    get '/'
    assert_equal "Hello, World!", last_response.body
  end
end
```

Once everything is wired up correctly, that test will pass. But first you'll
have to follow and fix a series of errors:

```plain
cannot load such file -- api (LoadError)
```

Create an empty file `lib/api.rb`.

```plain
NameError: uninitialized constant APITest::IdeaboxAPI
```

Add a class to the `lib/api.rb` file:

```ruby
class IdeaboxAPI
end
```

Then we get a rather cryptic error:

```plain
NoMethodError: undefined method `call' for IdeaboxAPI:Class
```

Apparently, the IdeaboxAPI doesn't know how to respond to web requests.
If it inherits from Sinatra::Base, it will gain those capabilities.

```ruby
class IdeaboxAPI < Sinatra::Base
end
```

Finally, we get a failure, rather than an error:

```plain
  1) Failure:
APITest#test_hello_world [/Users/you/project/ideabox/test/api_test.rb:15]:
--- expected
+++ actual
@@ -1,2 +1 @@
-"Hello, World!
-"
+"<h1>Not Found</h1>"
```

Define a method that responds to `GET /`:

```ruby
class IdeaboxAPI < Sinatra::Base
  get '/' do
    "Hello, World!"
  end
end
```

And with this, the test should pass.

#### Running the Web Server

We also want to be able to run the server so that we can hit the API over
HTTP using Rack.

#### Adding a Web Server

Rather than using the default web server, WEBrick, we'll use Puma. Again, add
it to the Gemfile, but don't let it get required automatically:

```ruby
gem 'puma', require: false
```

#### Creating a Rackup file

Create a file at the root of the directory named `config.ru` (ru stands for **r**ack**u**p).

This file needs to do a bunch of things for us.

Put `lib` on the load path:

```ruby
$:.unshift File.expand_path("./../lib", __FILE__)
```

Require all the default dependencies using Bundler:

```ruby
require 'bundler'
Bundler.require
```

Load up the main configuration and the Ideabox application itself:

```ruby
require './config/environment'
```

Load up the requirements for running the web application:

```ruby
require 'sinatra/base'
require 'puma'
```

Load up the actual web application:

```ruby
require 'api'
```

Add middleware so that our connections don't stay open when requests are finished:

```ruby
use ActiveRecord::ConnectionAdapters::ConnectionManagement
```

And, finally, run the Sinatra application:

```ruby
run IdeaboxAPI
```

#### Start the Server

Start the server with:

{% terminal %}
$ rackup -p 4567 -s puma
{% endterminal %}

#### Test It Out

And now you can hit the site at [localhost:4567](http://localhost:4567) either
in your browser or from the command line:

{% terminal %}
$ curl http://localhost:4567
{% endterminal %}

That's it! We have a working, tested Sinatra application.

... but it doesn't yet use Active Record.

We can change the _hello world_ test to put something in the database, which
we can then ask for from the API. Remember to include the WithRollback module,
and to wrap the body of the test in a `temporarily` block.

```ruby
class APITest < MiniTest::Unit::TestCase
  include Rack::Test::Methods
  include WithRollback

  def app
    IdeaboxAPI
  end

  def test_hello_world
    temporarily do
      Idea.create(:description => 'A wonderful idea!')
      get '/'
      expected = "[{\"id\":1,\"description\":\"A wonderful idea!\"}]"
      assert_equal expected, last_response.body
    end
  end
end
```

Get the test passing by changing the Sinatra endpoint:

```ruby
class IdeaboxAPI < Sinatra::Base
  get '/' do
    Idea.all.to_json
  end
end
```

Run the tests, commit your changes, and pat yourself on the back, because
here, finally, all of the pieces come together: A pure ruby application that
integrates with Active Record, and which has a thin layer of a web application
wrapping it.

The final project tree looks like this:

{% terminal %}
.
├── Gemfile
├── Gemfile.lock
├── README.md
├── Rakefile
├── config
│   ├── database.yml
│   └── environment.rb
├── db
│   ├── ideabox_test
│   └── migrate
│       └── 0_create_ideas.rb
├── lib
│   ├── api.rb
│   ├── ideabox
│   │   ├── db_config.rb
│   │   └── idea.rb
│   └── ideabox.rb
└── test
.   ├── api_test.rb
.   ├── fixtures
.   │   └── database.yml
.   ├── ideabox
.   │   ├── db_config_test.rb
.   │   └── idea_test.rb
.   └── test_helper.rb
{% endterminal %}


