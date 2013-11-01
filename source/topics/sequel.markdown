---
layout: page
title: Getting Started with Sequel
sidebar: true
---

Sequel is a library for interacting with databases from Ruby.

This tutorial is geared towards developers who have just finished our [Fundamental SQL]({% page_url topics/fundamental_sql %}) tutorial.

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

**NOTE**: PostgreSQL will *not* automatically create a database. To use Postgres with Sequel you'll need to create the database first using [the `createdb` tool](http://www.postgresql.org/docs/8.3/static/app-createdb.html)

After connecting to the database we can try running a query:

{% irb %}
> database.run "CREATE TABLE people (id integer primary key autoincrement, name varchar(255))"
 => nil 
> database[:people].select
 => #<Sequel::SQLite::Dataset: "SELECT * FROM `people`"> 
> database[:people].select.to_a
 => [] 
{% endirb %}

Not surprisingly, there are no people in our table yet.

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

## Abstracted SQL

Using SQL fragments is error/typo prone and can be a security issue if you accidentially inject user input into the middle of query strings.

Sequel offers you wrapper methods that make the most important SQL functions easier to use.

### On the `Database` Object

Continuing from the previous examples, we have a `database` object:

{% irb %}
> database.inspect
 => "#<Sequel::SQLite::Database: {:adapter=>:sqlite, :database=>\"database.sqlite3\"}>" 
{% endirb %}

The [full API lists all available methods](http://sequel.rubyforge.org/rdoc/classes/Sequel/Database.html), but let's look at some of the most useful.

#### `#create_table`

[The `#create_table` method](http://sequel.rubyforge.org/rdoc/classes/Sequel/Database.html#method-i-create_table) provides you a simplified way to create tables using a Ruby DSL:

```ruby
database.create_table :addresses do
  primary_key :id
  String      :line_1,  :size => 255
  String      :city
  String      :state,   :size => 2
  String      :zipcode, :size => 5
  Integer     :person_id
end
```

That's equivalent to this SQL:

```sql
CREATE TABLE addresses(id INTEGER PRIMARY KEY AUTOINCREMENT, line_1 VARCHAR(255, city VARCHAR(255), state VARCHAR(2), zipcode VARCHAR(5), person_id INT)
```

Run the Ruby fragment above in your IRB session and you'll get back `nil`. The `create_table` method always returns `nil`. Did it work?

#### `#schema`

You can check out the existance of and column definitions for a table with the `#schema` method:

{% irb %}
> database.schema(:addresses)
 => [[:id, {:allow_null=>false, :default=>nil, :primary_key=>true, :db_type=>"integer", :type=>:integer, :ruby_default=>nil}], [:name, {:allow_null=>true, :default=>nil, :primary_key=>false, :db_type=>"varchar(31)", :type=>:string, :ruby_default=>nil}], [:quantity, {:allow_null=>true, :default=>nil, :primary_key=>false, :db_type=>"integer", :type=>:integer, :ruby_default=>nil}]] 
{% endirb %}

Which breaks down each column, its type, and options.

#### Other Table Manipulations

There are other methods for common table manipulations including:

* [`add_column`](http://sequel.rubyforge.org/rdoc/classes/Sequel/Database.html#method-i-add_column)
* [`rename_column`](http://sequel.rubyforge.org/rdoc/classes/Sequel/Database.html#method-i-rename_column)
* [`drop_column`](http://sequel.rubyforge.org/rdoc/classes/Sequel/Database.html#method-i-drop_column)
* [`set_column_default`](http://sequel.rubyforge.org/rdoc/classes/Sequel/Database.html#method-i-set_column_default)
* [`set_column_type`](http://sequel.rubyforge.org/rdoc/classes/Sequel/Database.html#method-i-set_column_type)

#### `#from`

The method you'll use most frequently is `#from` which returns a `Sequel::Dataset` object.

If you [look at the `#from` documentation](http://sequel.rubyforge.org/rdoc/classes/Sequel/Database.html#method-i-from), you'll see this example:

```ruby
DB.from(:items) # SELECT * FROM items
```

How is that useful? Most of the time you want to append `WHERE` clauses on to your `SELECT` to scope down the query. The key here is that Sequel uses a *delayed query* pattern. It doesn't actually run the database query until you **need** the data. 

When you run `#from` you get back a `Dataset` object that you can continue to build upon, adding sorts, scopes, and other SQL features. Only when you call `#to_a` or iterate over the enumeration will the data actually be fetched from the database.

So what can you do with a `Dataset`? Let's see...

### On the `Dataset` Object

Once you have a `Dataset` you can refine your query using methods that imitate the functionality of SQL. You can chain together the methods below to build up a complex query.

For each example, assume you've done something like this to create `dataset`:

```ruby
dataset = database.from(:people)
```

#### `#select`

Use [the `#select` method](http://sequel.rubyforge.org/rdoc/classes/Sequel/Dataset.html#method-i-select) to define which of the available columns you want to retrieve. 

If you pass in no parameter, it'll default to all of them (like `*`).

{% irb %}
> dataset.select
 => #<Sequel::SQLite::Dataset: "SELECT * FROM `people`"> 
{% endirb %}

Pass in a single symbol, and only that field will be retrieved

{% irb %}
> dataset.select(:id)
 => #<Sequel::SQLite::Dataset: "SELECT `id` FROM `people`"> 
{% endirb %}

Pass in an array of symbols to retrieve multiple fields:

{% irb %}
> dataset.select([:id, :name])
 => #<Sequel::SQLite::Dataset: "SELECT (`id`, `name`) FROM `people`"> 
{% endirb %}

#### `#where` / `#filter`

The `#where` and `#filter` methods are effectively aliases, though the query parameter documentation [is under the `#filter` method](http://sequel.rubyforge.org/rdoc/classes/Sequel/Dataset.html#method-i-filter). Use either method to scope your queries to only matching rows.

##### Single Attribute

Most often you'll want to match a specific attribute:

{% irb %}
> dataset.where(:id => 1)
 => #<Sequel::SQLite::Dataset: "SELECT * FROM `people` WHERE (`id` = 1)"> 
{% endirb %}

##### Single Attribute In a Set

Or maybe you want to get all matches within a set:

{% irb %}
> dataset.where([[:id, [2,3]]])
 => #<Sequel::SQLite::Dataset: "SELECT * FROM `people` WHERE (`id` IN (2, 3))
{% endirb %}

_Note_: It seems like there is a redundant pair of array brackets there. But Sequel requires them for some non-apparent reason.

##### Chaining

It is very common to chain multiple scopes together, like you could do this:

{% irb %}
> dataset.where(:name => 'George').where([[:id, [1,2]]])
 => #<Sequel::SQLite::Dataset: "SELECT * FROM `people` WHERE ((`name` = 'George') AND (`id` IN (1, 2)))"> 
{% endirb %}

Keep calling `.where` and it'll add on more `WHERE` clauses. A row has to match *all* the `WHERE` clauses to be returned.

You can use `#or` to allow rows which only match one or more of the `WHERE` clauses:

{% irb %}
> dataset.where(:name => 'George').or([[:id, [2,3]]])
 => #<Sequel::SQLite::Dataset: "SELECT * FROM `people` WHERE ((`name` = 'George') OR (`id` IN (2, 3)))"> 
{% endirb %}

#### `#grep`

You'll use `#where` when you know exactly what you want, but the `#grep` method is handy when you want to do a fuzzy match.

{% irb %}
> dataset.grep(:name, 'G%')
 => #<Sequel::SQLite::Dataset: "SELECT * FROM `people` WHERE ((`name` LIKE 'G%'))"> 
1.9.3-p385 :053 > dataset.grep(:name, 'G%').to_a
 => [{:id=>1, :name=>"George"}]
{% endirb %}

The first parameter specified is the field to match. The second is a match string.

##### Writing Match Strings

Any literal letters are required matches against the row's data

The `%` means "zero or more of any characters". So `'G%'` matches `"George"` because there's a `"G"` then other characters. `'G%'` does **not** match `"SING"` because there are letters before the `"G"`. To match both `"George"` and `"SING"`, your match string would be `"%G%"`.

The `_` means "exactly one character". So `'G_'` matches `"Go"` but not `"George"`.

Most databases do these matches *case sensitive*, so `'g%'` would not match `'George'`. To search in a case-insensitive fasion, use the SQL `lower` function:

{% irb %}
> dataset.grep(Sequel.function(:lower, :name), 'g%')
 => #<Sequel::SQLite::Dataset: "SELECT * FROM `people` WHERE ((lower(`name`) LIKE 'g%'))">
> dataset.grep(Sequel.function(:lower, :name), 'g%').to_a
 => [{:id=>1, :name=>"George"}] 
{% endirb %}

#### `#limit`

Use [the `#limit` method](http://sequel.rubyforge.org/rdoc/classes/Sequel/Dataset.html#method-i-limit) to limit how many response rows you'll accept from the database.

For instance, when you're searching based on an `id` column, you're probably only expecting a single row back since the ID should be unique. Write the query like this:

{% irb %}
> dataset.select(:id, :name).where(:id => 1).limit(1)
 => #<Sequel::SQLite::Dataset: "SELECT `id`, 'name' FROM `people` WHERE (`id` = 1) LIMIT 1">
1.9.3-p385 :059 > dataset.select(:id, :name).where(:id => 1).limit(1).to_a
 => [{:id=>1, :name=>"George"}]
{% endirb %}

Using `limit` appropriately can make your queries and overall program higher performing.

#### `#order`

The [`#order` method](http://sequel.rubyforge.org/rdoc/classes/Sequel/Dataset.html#method-i-order) can sort your results:

{% irb %}
> dataset.order(:name)
 => #<Sequel::SQLite::Dataset: "SELECT * FROM `people` ORDER BY `name`"> 
> dataset.order(Sequel.desc(:name))
 => #<Sequel::SQLite::Dataset: "SELECT * FROM `people` ORDER BY `name` DESC">
{% endirb %}

By default the database will do an ascending sort on the named attribute. To get a descending sort, rely on `Sequel.desc()` as shown in the second example.

#### `#exclude`

The [`#exclude` method](http://sequel.rubyforge.org/rdoc/classes/Sequel/Dataset.html#method-i-exclude) is a way to write negative `WHERE` clauses.

Say I want to find all the records who do *not* have the name `'George'`:

{% irb %}
> dataset.exclude(:name => 'George')
 => #<Sequel::SQLite::Dataset: "SELECT * FROM `people` WHERE (`name` != 'George')"> 
> dataset.exclude(:name => 'George').to_a
 => [{:id=>2, :name=>"Thomas"}, {:id=>3, :name=>"Douglas"}]
{% endirb %}

#### `#insert`

Use [the `#insert` method](http://sequel.rubyforge.org/rdoc/classes/Sequel/Dataset.html#method-i-insert) to add rows to a table represented by the `Dataset`.

A variety of parameter styles is supported, but the best bet is to use a hash syntax. Assuming you created the `addresses` table above:

{% irb %}
> addresses = database.from(:addresses)
 => #<Sequel::SQLite::Dataset: "SELECT * FROM `addresses`"> 
> addresses.insert(:line_1 => "1600 Penn Ave", :city => "Washington", :state => "DC", :zipcode => "20001", :person_id => 1)
 => 1
{% endirb %}

Notice that, after the first line, the object is planning to run a `SELECT`. When we call the `INSERT` method it changes. Note that `#insert` is _not_ delayed, so as soon as you hit enter on that instruction you get back a `1`, signifying that one row was affected in the table.

Verify the insertion using `#select`:

{% irb %}
> addresses.select.to_a
 => [{:id=>1, :line_1=>"1600 Penn Ave", :city=>"Washington", :state=>"DC", :zipcode=>"20001", :person_id=>1}]
{% endirb %}

#### `#join`

The `#join` method actually relies on [the `#join_table` method](http://sequel.rubyforge.org/rdoc/classes/Sequel/Dataset.html#method-i-join_table) and is used to execute an inner join across two or more tables.

Presuming you have the `addresses` object and the data inserted in the last method, you can do an inner join between addresses and people:

{% irb %}
> addresses.join(:people, :id => :person_id)
 => #<Sequel::SQLite::Dataset: "SELECT * FROM `addresses` INNER JOIN `people` ON (`people`.`id` = `addresses`.`person_id`)"> 
> addresses.join(:people, :id => :person_id).to_a
 => [{:id=>1, :line_1=>"1600 Penn Ave", :city=>"Washington", :state=>"DC", :zipcode=>"20001", :person_id=>1, :name=>"George"}]
{% endirb %}

Where the first parameter is the other table you want to join to (here `:people`). The second parameter specifies the fields to join in the `ON` clause. The mapping is the attribute of the joining table (here `:id` of `people`) pointing to the primary table attribute (here `:person_id` of `addresses`).

One word of caution.  If the tables you are joining have the same column names, the join method will put the data from the second table into the matching columns of the first table in the resulting dataset.  To prevent this, use Aliasing.

Sequel.as(:column, :alias)

The syntax in Sequel also allows for implicit aliasing in column symbols using the triple underscore:

:column___alias # "column" AS "alias"
or
:table__column___alias # "table"."column" AS "alias"

#### `#update`

The [`#update` method](http://sequel.rubyforge.org/rdoc/classes/Sequel/Dataset.html#method-i-update) is used to change information within an existing row or rows. 

It is **very likely** that you want to use this in combination with a `#where` call, lest you change the attribute for every row in the table.

To change the zipcode of an address:

{% irb %}
> addresses.where(:id => 1).update(:zipcode => "20500")
 => 1 
1.9.3-p385 :092 > addresses.where(:id => 1).to_a
 => [{:id=>1, :line_1=>"1600 Penn Ave", :city=>"Washington", :state=>"DC", :zipcode=>"20500", :person_id=>1}] 
{% endirb %}

An `UPDATE`, like an `INSERT`, is run immediately. So the `where` needs to come earlier in the call chain.

#### `#delete`

The [`#delete` method](http://sequel.rubyforge.org/rdoc/classes/Sequel/Dataset.html#method-i-delete) is just like `#update` except that it removes the matching row(s).

{% irb %}
> dataset.where(:id => 2).delete
 => 1 
{% endirb %}

The returned `1` shows you that one row was deleted. If that number is large, it's time to look for your backups!

#### Counting & Math

##### `#count`

You can count the number of responses using `#count`:

{% irb %}
> dataset.count
 => 2
{% endirb %}

The `#count` method is advantageous because it runs a `COUNT *` query in the database and only retrieves the integer result.

Imagine you have 10,000 rows in a table. Calling `COUNT *` is going to return just the integer `10000`. But if you run a `SELECT *` query then call Ruby's `#count` on the collection, you're going to get back all the data in all those rows then count the objects. The latter version will be, approximately, one billion percent slower and cause you to be judged by your colleagues.

##### Other Functions That Might Be Interesting:

* `#avg`: http://sequel.rubyforge.org/rdoc/classes/Sequel/Dataset.html#method-i-avg
* `#sum`: http://sequel.rubyforge.org/rdoc/classes/Sequel/Dataset.html#method-i-sum
* `#max`: http://sequel.rubyforge.org/rdoc/classes/Sequel/Dataset.html#method-i-max
* `#min`: http://sequel.rubyforge.org/rdoc/classes/Sequel/Dataset.html#method-i-min

#### Enumerable

As mentioned previously, the `Dataset` object implements `Enumberable`, so methods like `#each`, `#map`/`#collect`, `#inject`/`#reduce`, `#sort` and will all work as expected.

## Full ActiveRecord-style ORM

If you're going to use the ActiveRecord-style mappers, maybe you should just use ActiveRecord.
