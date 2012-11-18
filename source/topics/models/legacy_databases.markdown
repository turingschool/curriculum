---
layout: page
title: Legacy/Non-conformant Databases
section: Models
---

Not every application starts from scratch, sometime you have to deal with a legacy database. Walking the Rails golden path makes life easy, and there's a perception that stepping off that path is incredibly painful. 

It's not true. If your database is well designed but doesn't follow the Rails naming conventions, it's easy to make them play nicely together. However, if your database structure is crap to begin with, then there's only so much Rails can do for you. `ActiveRecord` is a mapper between the database and objects, but it's not a DBA-in-a-Box.

## Theory

In a green-field app, `ActiveRecord` and the Database fit right together:

```
+---------------+
| Active Record |
|               |
+---------------|
|               |
|   Database    |
+---------------+
```

But when they don't align, we need to insert an adapter. There are a few options to make the parts fit together. 

### Option 1: Database Views

If you're using a powerful database engine then it has the ability to create views. Think of them as a translation layer for your data. From the outside, the Rails application will interact with the view as though it were a real table. We thereby encapsulate the complexity within the database layer and our Rails application needs no modification.

You could think of it, graphically, like this:

```
+---------------+
| Active Record |
|               |
+---------------+
|   Data Views  |
| ------------- |
|   Real Data   |
+---------------+
```

This is the best option when:

* The Rails app is the only user of the database
* The database could be rewritten/restructured to follow Rails conventions in the future
* You have a sufficiently advanced database engine
* Database performance is not a major bottleneck (usually, it's not)

The implementation of views varies by database engine. Here are guides for the most common options:

* PostgreSQL Views: http://www.postgresql.org/docs/9.0/interactive/tutorial-views.html
* Introduction to MySQL Views: http://net.tutsplus.com/tutorials/databases/introduction-to-mysql-views/

The beauty of this approach is that our Rails application has the illusion of being on the "Golden Path".

### Option 2: Overriding Defaults

Creating views isn't always practical, such as when:

* You only want to override a few column names, table names, etc -- not change significant structure
* You don't have access/control of the database internal structure
* You're hopelessly scared of SQL

Your primary option, then, is to have `ActiveRecord` handle the translation:

```
+---------------+
| Active Record |
| ------------- |
| AR Overrides  |
+---------------+
|               |
|   Database    |
+---------------+
```

Assuming our database structure is sound but doesn't follow the Rails conventions, the typical overrides include:

* table names
* primary key (ID) name
* foreign key name

#### Specifying Table Name

Imagine a model named `Customer`. By default, Rails assumes the data is in a table named `customers`, but let's say it's in actually in a table named `existing_customers`. The override is simple within the `Customer` model:

```ruby
class Customer < ActiveRecord::Base
  set_table_name 'existing_customers'
end
```

Nothing else in the model or application needs to change.

#### Specifying Primary Key

Say that the `existing_customers` table doesn't use a primary key named `id`, instead it is `customer_id`. No problem:

```ruby
class Customer < ActiveRecord::Base
  set_table_name 'existing_customers'
  set_primary_key 'customer_id'
end
```

#### Foreign Keys

And what about relationships? Imagine there is an associated `Order` object where one `Customer` `has_many` `Order`s. Normally, that would imply that the `orders` table has a column `customer_id`, but in our DB it is `existing_customer_id`.

```ruby
class Customer < ActiveRecord::Base
  set_table_name 'existing_customers'
  set_primary_key 'customer_id'
  has_many :orders, foreign_key: 'existing_customer_id'
end
```

That is the `foreign_key` within the `orders` table pointing back to this `Customer` object. On the `Order` side we do the same thing:

```ruby
class Order < ActiveRecord::Base
  belongs_to :customer, foreign_key: 'existing_customer_id'
end
```

The same pattern holds true for a `has_one`/`belongs_to` relationship.

### Option 3: Rebuilding

The hardest option, of course, is rebuilding your database. Here are a few tools that might help you along the way:

#### Taps

The Taps gem (https://github.com/ricardochimal/taps) makes moving data between databases super simple. Have you ever done a `heroku db:pull` or `heroku db:push`? That magic happens through taps. It's useful for moving data between machines, but it can even convert between supported databases on the fly. 

When pulling data from Heroku, you're getting it out of PostgreSQL on the server and building SQLite locally. It can also translate between MySQL, PostgreSQL, and SQLite, even properly setting the auto-incrementing triggers. 

#### Sequel

Sequel is a simple, beautiful SQL "access toolkit". You can quickly build a customized object-relational mapping (ORM) for your existing data, then programmatically manipulate that data to output `ActiveRecord`-compliant structures. 

Developers have used Sequel to implement ORMs for non-SQL sources like flat files, CSV files, and even Google Spreadsheets. Check it out at https://github.com/jeremyevans/sequel

## References

* PostgreSQL Views: http://www.postgresql.org/docs/9.0/interactive/tutorial-views.html
* Introduction to MySQL Views: http://net.tutsplus.com/tutorials/databases/introduction-to-mysql-views/
* Rails associations and overrides: http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html
* Taps: https://github.com/ricardochimal/taps
* Sequel: https://github.com/jeremyevans/sequel
