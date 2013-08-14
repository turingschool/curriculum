---
layout: page
title: Sinatra with Active Record
sidebar: true
---

## IN PROGRESS - INCOMPLETE

### Nothing to see here, folks. Move along.

Working with Active Record outside of Rails is not difficult, but it requires you to jump through a few hoops that Rails generally takes care of for you.

We will for the most part stick with conventions that people are used to, because there's no reason to surprise people unless you have a good reason.

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
there's only one file, it's nice to have this from the start. It's a lot faster to type `rake` than `ruby test/ideabox_test.rb`.

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

A simple file store such as PStore or YAML::Store would probably be good enough for our needs, but we'll go ahead and point the big guns at it.

We're adding Active Record.

### Asserting that Idea Exists

Create a subdirectory under `test` named `ideabox`.

If you look at most gems, they have the following structure:

{% terminal %}
.
└── lib
.   └── gemname
.   │  └── domain_object_1.rb
.   │  └── domain_object_2.rb
.   └── gemname.rb
{% endterminal %}

Often `lib/gemname.rb` will only have the code that requires the rest of the project, but sometimes it will contain a little bit of code as well.

One way to structure test files is to have the same path as to the library file, but replacing `lib` with `test`. For example:

{% terminal %}
lib/ideabox/idea.rb
test/ideabox/idea.rb
{% endterminal %}

It isn't always necessarily a great idea to have exactly one test file per library file, but it's a reasonable place to start.

Since we're going to put domain objects within `lib/ideabox/*` we need an `ideabox` directory under test:

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
ArgumentError: wrong number of arguments(1 for 0)
```

Rather than do the stupidest thing that could possibly work, let's go ahead
and make Idea an Active Record model.

```ruby
class Idea < ActiveRecord::Base
end
```

That blows up:

```plain
test/ideabox/idea_test.rb:3:in `<main>': uninitialized constant ActiveRecord
(NameError)
```

We need to require Active Record:

```ruby
require './test/test_helper'
require 'active_record'

class Idea < ActiveRecord::Base
# ...
```

You may get a complaint that it can't find Active Record. If that's the case, install it with `gem install activerecord` and try again.

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

Eventually we'll need to configure the environment so we have a different
database for test, development, and production, and the database connection
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

In `config/environment.rb`:

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
in the test helper, making the test helper looks like this:

```ruby
$:.unshift File.expand_path("./../../lib", __FILE__)

require 'bundler'
Bundler.require
require './config/environment'
require 'minitest/autorun'
require 'ideabox'
```

Looking at it, though, it would make more sense to have the bundler stuff in
the environment file. Requiring the project with `ideabox` can probably go
there as well.

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

Rails puts database migrations in `db/migrate`, and there's no good reason to
do otherwise. Create a migrate subdirectory in db, and create an empty file
`0_create_ideas.rb` within `db/migrate`.

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

next: create rake task for migration
then: move idea class into lib/ideabox/idea

----------------------------------------------------
         Raw materials to work from
----------------------------------------------------

In order to make the fewest changes possible to the `Rating` object, and make
any data migrations as simple as possible, we're going to use the same ActiveRecord `Rating`object in the stand-alone application.

There's more to it than just requiring 'active_record' and copying the file over, however.

We're going to need to deal with

* configuration
* opening and closing the connection to the database
* database migrations
* running tests in transactions so that tests don't interfere with each other

#### Adding Files to the New Application

The new files we'll be adding are:

{% terminal %}
├── config
│   ├── database.yml
│   └── environment.rb
├── db
│   ├── migrate
│   │   └── 0_initial_migration.rb
├── lib
│   ├── opinions
│   │   └── rating.rb
└── test
    └── opinions
        └── rating_test.rb
{% endterminal %}

#### Dependencies in the `Gemfile`

We need to add both ActiveRecord and an appropriate adapter to the Gemfile. The primary application uses SQLite3, so we'll use that here as well.

```ruby
source 'https://rubygems.org'

gem 'activerecord', require: 'active_record'
gem 'sqlite3'
```

Run `bundle install` to install the dependencies.

#### Unit Testing `Rating`

We'll add a separate test file for the `Rating` class. Since the code will live in
`lib/opinions/rating.rb` we'll put the test in `test/opinions/rating_test.rb`.

We won't test anything fancy yet. If our test manages to load a new `Rating`
class, even if it doesn't save it, it means that:

* the active record gem is being required
* the database configuration is being loaded
* we're connecting to the database correcly
* the test has access to all of it

```ruby
require './test/test_helper'

class RatingTest < MiniTest::Unit::TestCase
  def test_existence
    rating = Opinions::Rating.new(stars: 3)
    assert_equal 3, rating.stars
  end
end
```

Run `rake`.

It blows up with `NameError: uninitialized constant Opinions::Rating`.

#### Copying `Rating`

Copy the `Rating` class from the primary application to
`lib/opinions/rating.rb`. Make sure to *delete* any methods that refer to parts
of the primary application that we no longer have access to.

Also, put `Rating` inside the `Opinions` namespace:

```ruby
module Opinions
  class Rating < ActiveRecord::Base
    # ...
  end
end
```

Run `rake` again.

It blows up with the same error, because we're not loading
the class anywhere.

#### Requiring the Model

Open `lib/opinions.rb` and require 'opinions/rating'.

Run `rake` again.

Now it complains about an `uninitialized constant
Opinions::ActiveRecord (NameError)`. It's not loading ActiveRecord.

#### Loading ActiveRecord

Rather than manually load all the dependencies, let's create an `environment.rb`
file that loads bundler and anything required explicitly in the Gemfile.

Create a file `config/environment.rb`, and add the following to it:

```ruby
require 'yaml'
require 'bundler'
Bundler.require

module Opinions
  class Config
    def self.db
      @config ||= YAML::load(File.open("config/database.yml"))
    end

    def self.env
      return @env if @env
      ENV['OPINIONS_ENV'] ||= "development"
      @env = ENV['OPINIONS_ENV']
    end

    def self.active_record
      db[env]
    end
  end
end

ActiveRecord::Base.establish_connection(Opinions::Config.active_record)
require 'opinions'
```

The tests still fail with the same error, because the test helper isn't
requiring the environment file.

Open up the test helper and replace `require 'opinions' with:

```ruby
require './config/environment'
```

Run `rake` and we're making progress.

The next error is a complaint that `No such file or directory -
config/database.yml (Errno::ENOENT)`.

#### Writing a `database.yml`

Create the file and add a basic sqlite3 config in it:

```ruby
---
development:
  adapter: sqlite3
  database: db/opinions_development
  pool: 5
  timeout: 5000
  username: opinions

test:
  adapter: sqlite3
  database: db/opinions_test
  pool: 5
  timeout: 5000
  username: opinions
```

Run the tests again, and you'll get a complaint that
`ActiveRecord::StatementInvalid: Could not find table 'ratings'`.

#### Writing a Migration

We need a migration. In `db/migrate/0_initial_migration.rb` copy over the part
of the migration in the primary application that is relevant to the ratings
feature, which is the ratings table:

```ruby
class InitialMigration < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.integer :product_id
      t.integer :user_id
      t.string :title
      t.text :body
      t.integer :stars, default: 0

      t.timestamps
    end
    add_index :ratings, [:product_id, :user_id], unique: true
  end
end
```

#### Rake Task to Run Migrations

To run the migration we'll need a rake task. Open up the Rakefile and add the
following:

```ruby
namespace :db do
  desc "migrate your database"
  task :migrate do
    require './config/environment'
    ActiveRecord::Migrator.migrate('db/migrate')
  end
end
```

Then you can run `rake db:migrate`. Try the tests again.

#### Migrating for the Test Environment

When you run `rake`, it will *still* not find the ratings table. That's because
the `rake db:migrate` task defaulted the environment to development, and the
tests are running against the test environment.

Run the migration with the test configuration:

{% terminal %}
OPINIONS_ENV=test rake db:migrate
{% endterminal %}

Run `rake` again, and **finally the tests should pass**.

#### Cleaning Up

We no longer need the wiring test. Delete the `test/opinions_test.rb` file.
Open up `lib/opinions.rb` and delete everything inside the module, so it looks
like this:

```ruby
require 'opinions/rating'

module Opinions
end
```

#### Writing to the Database

Now let's have a test that writes to the database:

```ruby
def test_persist
  assert_equal 0, Opinions::Rating.count # guard against weird behavior

  data = {
    user_id: 1,
    product_id: 1,
    stars: 3,
    title: "Adorable",
    body: "Very cute monster."
  }
  rating = Opinions::Rating.create(data)
  assert rating.persisted?, "Expected rating to persist"
  assert_equal 1, Opinions::Rating.count
end
```

Run the tests. They should pass. Run them again. They fail. **WAT**.

#### Rolling Back Test Saves

The test is writing to the database, but there's nothing that deletes it when
the test is done. We could require the `database_cleaner` gem, but let's go old-school and
hand-roll some rollback functionality.

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

Include the module in the test class:

Change the `test_persist` to `test_rollback`, wrapping the write action in a
`temporarily` block. We'll also make an assertion at the very end, outside the
`temporarily` block, that the rating count is zero.

```ruby
class RatingTest < MiniTest::Unit::TestCase
  include WithRollback

  # ...

  def test_rollback
    assert_equal 0, Opinions::Rating.count # guard against weird behavior

    temporarily do
      data = {
        user_id: 1,
        product_id: 1,
        stars: 3,
        title: "Adorable",
        body: "Very cute monster."
      }
      rating = Opinions::Rating.create(data)
      assert rating.persisted?, "Expected rating to persist"
      assert_equal 1, Opinions::Rating.count
    end
    assert_equal 0, Opinions::Rating.count
  end
end
```

Let's clear and re-migrate the database.

* delete the `db/opinions_test` file
* rerun `OPINIONS_ENV=test rake db:migrate`

Then run the tests a couple times and they should pass *consistently*.

### Wiring up Sinatra

To add Sinatra into the mix we need to add a few more files and a few more gems.

#### Additional Files

Create the following files in your existing app:

{% terminal %}
.
├── config.ru
├── lib
│   ├── api.rb
└── test
    └── api_test.rb
{% endterminal %}

#### Additional Dependencies

The gems are `sinatra` itself, a web server to run it (we'll use Puma), and a gem to help us test the Sinatra controller actions.

Change the `Gemfile` to the following:

```ruby
source 'https://rubygems.org'

gem 'activerecord', require: 'active_record'
gem 'puma'
gem 'sinatra', require: 'sinatra/base'
gem 'sqlite3'

group :test do
  gem 'rack-test', require: false
end
```

#### Validating the Setup

As before, we're going to write a very simple test to make sure
that everything is wired together correctly.

Create a file `test/api_test.rb`, and add this code to it:

```ruby
require './test/test_helper'
require 'rack/test'
require 'sinatra/base'
require 'api'

class APITest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    OpinionsAPI
  end

  def test_hello_world
    get '/'
    assert_equal "Hello, World!\n", last_response.body
  end
end
```

Once everything is wired up correctly, that test will pass. But first you'll have to follow and fix a series of errors:


* `cannot load such file -- api` -- Create an empty file `lib/api.rb`
* `NameError: uninitialized constant APITest::OpinionsAPI` -- add this  Sinatra application in `lib/api.rb`:

```ruby
class OpinionsAPI < Sinatra::Base
  get '/' do
    "Hello, World!\n"
  end
end
```

This should get the test passing.

#### Creating a `rackup` File

We also want to be able to run the server so that we can hit the API over
HTTP using Rack.

Create a file at the root of the directory named `config.ru` (ru stands for **r**ack**u**p), with the following:

```ruby
$:.unshift File.expand_path("./../lib", __FILE__)

require 'bundler'
Bundler.require

require './config/environment'
require 'opinions'
require 'api'

use ActiveRecord::ConnectionAdapters::ConnectionManagement
run OpinionsAPI
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

#### Next Steps

Admittedly, our Sinatra application doesn't do anything. Let's start with a



## Configuring the Environment

TODO: rework this section to TDD the env stuff correctly.

```ruby
def test_environment
  assert_equal 'test', Opinions.env
end
```

Well that's easy:

```ruby
def teardown
  ENV['OPINIONS_ENV'] = 'test'
end
```

Easy, but not very good.

We should be able to configure the environment.

```ruby
def test_environment_is_configurable
  ENV['OPINIONS_ENV'] = 'production'
  assert_equal 'production', Opinions.env
end
```

Let's read from an environment variable:

```ruby
module Opinions
  def self.env
    @env ||= ENV.fetch("OPINIONS_ENV") { "development" }
  end
end
```

If you're not familiar with `fetch`, it will look for the `OPINIONS_ENV` key in the `ENV` hash of environment variables. If the key is found, the value will be returned. If it is not found, `"development"` will be used like a default value.

At this point the test should pass. 
