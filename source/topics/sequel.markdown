---
layout: page
title: Getting Started with Sequel
sidebar: true
---

Sequel is a library for interacting with databases from Ruby.

This tutorial is geared towards developers who have just finished our [Fundamental SQL]({% page_url topics/sequel %}) tutorial.

## Getting Started

In the course of this tutorial we'll build a small sample project. Create a project directory we'll refer to as `sequel_tutorial`.

### `Gemfile`

Within that directory, create a `Gemfile` that has the following contents.

```ruby
source 'https://rubygems.org'

gem 'sequel'
gem 'sqlite3'
```

Save it and run `bundle` from the project directory.

### Create the Database

Let's see if we can get things rolling:

{% terminal %}
$ bundle exec irb
{% endterminal %}

Then, within IRB:

{% irb %}
> Bundler.require
 => [<Bundler::Dependency type=:runtime name="sequel" requirements=">= 0">, <Bundler::Dependency type=:runtime name="sqlite3" requirements=">= 0">] 
> database = Sequel.sqlite('database.sqlite3')
 => #<Sequel::SQLite::Database: {:adapter=>:sqlite, :database=>"database.sqlite3"}> 
{% endirb %}

We created a database in the file `database.sqlite3` just by attempting to connect to it. SQLite creates the file if it's not found.

**NOTE**: PostgreSQL will *not* automatically create a database. To use Postgres with Sequel you'll need to create the database first using [the `creatdb` tool](http://www.postgresql.org/docs/8.3/static/app-createdb.html)

After connecting to the database we can try running a query:

{% irb %}
> database.run "CREATE TABLE customers (id integer primary key autoincrement, name varchar(255))"
 => nil 
> database[:people].select
 => #<Sequel::SQLite::Dataset: "SELECT * FROM `people`"> 
> database[:people].select.to_a
 => [] 
{% endirb %}

Not surprisingly, there are no customers in our table yet.

### Layers of Abstraction

Sequel offers you three interaction patterns with your database, detailed below.

## Raw SQL

You can use Sequel as a dumb bridge between Ruby-land and the SQL database. This patterns is the "closest to the metal", so you can do anything that's possible in SQL -- but you have to be totally comfortable with writing SQL. 

Any errors or typos in your SQL fragments are going to get passed through to the database, with possibly catastrophic effects.

### Using `#run`

Above we used the `#run` method to create a table within the database. We pass it a string exactly like we're typing the SQL at the database's native prompt.

We could execute a `SELECT` using `#run`:

{% irb %}
> database.run "SELECT * from people;"
 => nil 
{% endirb %}

But `nil`? The `#run` method blindly executes a SQL fragment and does not pay attention to the return value. The `#run` method *always* returns `nil`.

### Using `#fetch`


#### Basic Usage

The `#fetch` method is used when you want to gather the response from the database:

{% irb %}
> results = database.fetch "SELECT * from people;"
 => #<Sequel::SQLite::Dataset: "SELECT * from people;"> 
> results.to_a
 => [] 
{% endirb %}

Or, if we could actually insert some data:

{% irb %}
> database.run "INSERT INTO people(name) VALUES('George')"
 => nil 
> database.run "INSERT INTO people(name) VALUES('Thomas')"
 => nil 
> database.run "INSERT INTO people(name) VALUES('Douglas')"
 => nil 
> results = database.fetch "SELECT * from people;"
 => #<Sequel::SQLite::Dataset: "SELECT * from people;"> 
> results.to_a
 => [{:id=>1, :name=>"George"}, {:id=>2, :name=>"Thomas"}, {:id=>3, :name=>"Douglas"}] 
{% endirb %}

You can see that `#fetch` returned a `Dataset` object. When converted to an array with `#to_a`, you get out an array of hashes. Recall that in database query results the order matters. The array here preserves the ordering as they came out of the DB, then each row is represented as a hash. You could then iterate through those hashes and do something interesting.

#### With a Block

The `#fetch` method also supports passing in a block which is run on each result:

{% irb %} 
> database.fetch "SELECT * from people;" do |data|
>   puts data[:name]
> end
George
Thomas
Douglas
 => #<Sequel::SQLite::Dataset: "SELECT * from people;"> 
{% endirb %}

The block is execute once for each row in the returned data.

#### As an Enumerator

You've seen that `#fetch` is returning an instance of `Sequel::SQLite::Dataset`. Digging into that object...


{% irb %}
> Sequel::SQLite::Dataset.ancestors
 => [Sequel::SQLite::Dataset, Sequel::SQLite::DatasetMethods, Sequel::Dataset, Sequel::SQL::StringMethods, Sequel::SQL::OrderMethods, Sequel::SQL::NumericMethods, Sequel::SQL::InequalityMethods, Sequel::SQL::ComplexExpressionMethods, Sequel::SQL::CastMethods, Sequel::SQL::BooleanMethods, Sequel::SQL::AliasMethods, Enumerable, Object, Kernel, BasicObject] 
> Sequel::SQLite::Dataset.ancestors.include? Enumerable
 => true
{% endirb %}

A `Dataset` acts as a Ruby enumerator. So we can use all our favorite collection methods like `#each`, `#collect`, `#inject`, etc:

{% irb %}
> database.fetch("SELECT * from people;").collect{|data| data[:name]}
 => ["George", "Thomas", "Douglas"] 
{% endirb %}

### There Is No Step 3

If you're comfortable working at the lowest level of abstraction, `#run` and `#fetch` are all you need!


