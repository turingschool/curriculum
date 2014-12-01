---
layout: page
title: SQL Views
---

In this tutorial we'll be looking at using SQL views to simplify
interacting with more complex relational queries. We'll walk through
the steps to create a SQL view manually, and then look at using one from
within our rails project.

In a nutshell, an SQL view is what we call a "virtual table." Rather
than being persisted directly on disk like a normal table, it is
formed dynamically from the result set of a query on our existing
data. One of the powerful features of a Relational Database
Engine is that it does not distinguish between querying against real and virtual tables (updating data is sometimes a different story).

This allows us to use virtual tables as a transparent abstraction within our database layer. We can create a SQL view which encapsulates a chunk of query logic -- top-performing salespeople, for instance -- and then from our application we can address this data as if it were just another table in our DB, via ActiveRecord or another standard tool.

One of the most common use-cases for SQL views in web applications
is for encapsulating complicated Business Intelligence or reporting logic. Let's explore this in practice by adding some reporting features to our Storedom project.


## Setup: storedom base project

We'll use the Storedom sample project (https://github.com/turingschool-examples/storedom) as a basis for this exercise. Clone it and set it up like so:

```shell
git clone https://github.com/turingschool-examples/storedom.git sql-views-workshop
cd sql-views-workshop
```

One more bit of housekeeping before we continue -- this project is
actually using Sqlite at the moment, but we'd rather use postgres for
some of the DB features we'll be looking at. Fortunately it used to be
on postgres so this change is available in git history. We can get there easily
by reverting an old commit:

```shell
git revert b5888fbe684a9e48fbde40310cae711405f27efa
bundle
rake db:setup
```

You should see a bunch of console output as it seeds your database.

## Admin Reporting - Top Selling Items

A common BI insight we might wonder about is which items are selling
the most volume on our store. As we work through this tutorial, we'll
look at several ways to query this data, and ultimately see how to
encapsulate the related logic in a SQL view.

#### Finding Top-Selling Items with ActiveRecord

How might we find top-selling items using just ActiveRecord query
methods? Try this in rails console:

```ruby
Item.joins(:order_items).group(:item_id).order('count_id desc').count('id')
```

Our seed data is randomized, so the output will be different for
everyone, but this should return an ordered hash containing mappings of
`item_id -> number_of_orders`. Suppose we wanted to get the top 10 items themselves:

```ruby
item_ids = Item.joins(:order_items).group(:item_id).order('count_id desc').count('id').first(10).map { |i| i[0] }
items = Item.where(:id => item_ids)
```


#### Finding Top-Selling Items by SQL

As we can see, this problem is forcing us to chain together more query
methods than we might like. Additionally, the
ActiveRecord approach forces us to make an additional query at the end
to get a list of Item objects. Let's see if we can remove that extra
step using some good ol' raw sql.

Try this in your Storedom rails console:

```ruby
Item.find_by_sql("SELECT 'items'.*,
                  COUNT('order_items'.'item_id') AS 'orders_count'
                  FROM 'items' INNER JOIN 'order_items' ON 'order_items'.'item_id' = 'items'.'id'
                  GROUP BY items.id
                  ORDER BY orders_count desc
                  LIMIT 10")
```

Not too bad. Now we're at least getting all our item data back in one
go. But to expose this filtered item list as a method on `Item` would
mean leaking a lot of SQL into our application code which is pretty
oogly. It would be a
good application for a SQL view. By using a view, we can attach a domain
name to the concept represented by the query we just created. Something
like "Top Selling Items" would be good. Then we can encode the query
logic into the SQL view, and interact with it transparently from the
application.

#### Creating Views Manually from SQL Console

To get some practice creating SQL views, let's start by creating this
view manually from psql console. First fire up the postgres console by
running `psql` from your terminal:

```shell
psql
psql (9.3.5)
Type "help" for help.
worace=#
```

Remember that in psql you can see all your current databases with `\l`.
You can connect to a database with `\c <db_name>`. Once connected to a
DB you can see all tables with `\dt`. Let's connect to the
`storedom_development` db:


```
\c storedom_development
You are now connected to database "storedom_development" as user "worace".
```

As a quick data check, your DB seed task should have put 500 items in
the DB. We can check with a `select count` query:

```sql
storedom_development=# SELECT COUNT(*) from items;
 count
-------
   500
(1 row)
```

If you dont see 500 items in your DB, you may need to run `rake db:drop`
and `rake db:setup` again from the project root.

Now let's look at creating a view. The SQL syntax for this is similar to
creating a table or database, but after the name of the view you must
supply the query which you'd like it to be based on. So let's create a
`top_selling_items` view from `psql` console:

```sql
CREATE VIEW top_selling_items AS
SELECT "items".*,
COUNT("order_items"."item_id") AS "orders_count"
FROM "items" INNER JOIN "order_items" ON "order_items"."item_id" = "items"."id"
GROUP BY items.id
ORDER BY orders_count desc;
```

If you entered this correctly, you should see a `CREATE VIEW` message
from postgres. Now we can see our view in the list of views by entering
`\dv` in `psql`:

```
storedom_development=# \dv
             List of relations
 Schema |       Name        | Type | Owner
--------+-------------------+------+--------
 public | top_selling_items | view | worace
(1 row)
```

And we can select from it just like a normal table:

```sql
SELECT * FROM top_selling_items LIMIT 1;
```

Holy virtual tables batman! Not bad. Just one more thing -- typing long
strings of SQL into the postgres console is both labor-intensive and (as
you probably discovered) error-prone. Furthermore, if we want to share
this setup across multiple production or development machines, we'll
have to execute the SQL again on each machine.

Luckily rails gives us an easy way around this problem --  ActiveRecord Migrations!
Just as we use migrations to set up new tables and add or update columns, we can use
them to create new database views.

In order to practice making a view with a migration, let's remove the
one we just made manually (don't worry, your precious view will be back
soon):

```sql
DROP VIEW top_selling_items;
```

If this worked you'll get a `DROP VIEW` message from postgres. And if
you list all views with `\dv` you'll get a `no relations found` message.

#### Creating Views With ActiveRecord::Migration

Now on to the migration! We know how to create a migration with the
generator:

```shell
rails g migration CreateTopSellingItemsView
```

Open the migration file that this created and notice the SQL rails tried
to infer for you:

```ruby
class CreateTopSellingItemsView < ActiveRecord::Migration
  def change
    create_table :top_selling_items_views do |t|
    end
  end
end
```

This isn't what we want, so let's replace the `#change` method with our
view syntax:

```ruby
class CreateTopSellingItemsView < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE VIEW top_selling_items AS
      SELECT "items".*,
      COUNT("order_items"."item_id") AS "orders_count"
      FROM "items" INNER JOIN "order_items" ON "order_items"."item_id" = "items"."id"
      GROUP BY items.id
      ORDER BY orders_count desc;
    SQL
  end

  def down
    execute <<-SQL
      DROP VIEW top_selling_items;
    SQL
  end
end
```

As you can see this migration is pretty crude. We are just dumping the
SQL for creating our view in. But it will be good enough for our current
purposes. If you're interested in a more abstract approach to creating
views via migrations, check out the rails_sql_views gem: https://github.com/activewarehouse/rails_sql_views. 

Additionally, by default SQL views won't show in your `schema.rb` file. This can create issues when dropping or reloading DBs from the schema (as we sometimes do in test environments). An easy fix for this is to tell rails to use sql as the format for your schema records, by adding this line to `config/application.rb`:

```
config.active_record.schema_format = :sql
```

Run your migrations with `rake db:migrate`. If you're curious, check in
`psql` console to see that your view has re-appeared. You can also test
the "down" functionality by running `rake db:rollback`. Another cool
thing about views is that since they are dynamically generated, they can
be dropped without losing any data!

#### ActiveRecord Models Backed by Rails Views

So now we have written our view and have a migration to create it
portably on different systems. Finally let's look at using ActiveRecord
to access the new "table" within our application.

Remember how we said before that SQL doesn't distinguish between real
and virtual tables? One ramification of this is that we can build
ActiveRecord models on top of views just as we can on top of normal
tables. If we follow the standard convention of `CamelCaseModelName ->
under_score_table_name` there isn't even any configuration needed.

Add a new model file to your project called `top_selling_item.rb` and
give it a new class inheriting from ActiveRecordBase:

```ruby
class TopSellingItem < ActiveRecord::Base
end
```

Now from rails console, you should be able to pull the first top selling
item, and get the item which actually has the most orders.

```ruby
irb(main):008:0> TopSellingItem.first
  TopSellingItem Load (1.3ms)  SELECT  "top_selling_items".* FROM "top_selling_items"  LIMIT 1
=> #<TopSellingItem id: 243, name: "Gorgeous Rubber Gloves", description: "Ut laborum at. Unde fugit voluptas et quod enim ni...", image_url: "http://robohash.org/242.png?set=set1&size=200x200", created_at: "2014-12-01 00:43:17", updated_at: "2014-12-01 00:43:17", orders_count: 7>
```

If we want to be able to get to order data through these, we'll need to
add the appropriate ActiveRecord association methods:

```ruby
class TopSellingItem < ActiveRecord::Base
  has_many :order_items
  has_many :orders, through: :order_items
end
```

Finally, a couple caveats. The first is that in general, SQL views are a
read-only table format. Since the data is dynamically aggregated from
underlying sources, it's dangerous to try to perform updates without
some careful consideration. We can make our ActiveRecord model reflect
this by defining `#readonly?` to always return `true`:

```ruby
class TopSellingItem < ActiveRecord::Base
  has_many :order_items
  has_many :orders, through: :order_items

  def readonly?
    true
  end
end
```

Now if we try to perform an update on the model, we'll get an error:

```ruby
irb(main):010:0> TopSellingItem.first.update_attribute(:image_url, "")
ActiveRecord::ReadOnlyRecord: ActiveRecord::ReadOnlyRecord
```

The last caveat is that in this example, we encoded some Ordering logic
into the view itself (remember we added `ORDER BY orders_count desc`).
This will cause some havoc if you try adding additional sorting
parameters on top, for example calling `TopSellingItem.last`. When it
comes to this sort of SQL modeling, your model should be tailored to
the use-case. So if we really only care about
the top-selling item, then encoding the order into the query was
probably the right move.

If, however, we wanted to perform other more flexible queries on the data, it might have made sense to model it more generally -- perhaps as
`ItemSalesRecord`s which aggregate the orders_count attribute but leave
sorting to the user. The point is that SQL modeling
is really a broad and flexible tool, so try to always keep an eye on
your current needs and adjust the data modeling accordingly. SQL views
can be a great way to take advantage of this flexibility without
crowding your application with unsightly SQL statements.
