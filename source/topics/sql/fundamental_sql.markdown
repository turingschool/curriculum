---
layout: page
title: Fundamental SQL
sidebar: true
---

Databases are at the core of almost every web application. They are our means of storing, fetching, calculating, and sorting data.

## SQL

*S*tructured *Q*uery *L*anguage is how we interact with most databases. Through carefully constructed SQL instructions we can create, modify, or delete tables. We can find existing data within tables, insert new data, or change what's there. We can add modifiers to our queries to scope them down to only entries matching certain criteria, or calculate aggregates on the fly.

While it's somewhat English-like and approachable, don't be confused: SQL is a programming language. Using it effectively necessitates the same care and attention put into any program.

### Database Engines

There are many different database systems. The most popular SQL-based databases include PostgreSQL, MySQL, Oracle, MS SQL Server, and SQLite.

The core techniques of SQL are common to all of these systems. Hypothetically your queries and data should be portable between each of them.

In reality, database engines tend to follow Microsoft's old strategy of "embrace and extend." They implement the core SQL specification, then add on a lot of custom functionality. That extra functionality makes your job easier, performance better, or some other benefit -- but now you've strayed from the standard and your code is tied to one database engine.

In general our advice is:

* SQLite: Great for experiments and local development, never use in production
* MySQL: Popular and widely available, but avoid it if you can
* PostgreSQL: The best choice for both development and production
* MS SQL Server/Oracle: Trusting your production stack to closed-source code is a non-starter

#### Tutorial Experiments

For the purposes of this tutorial we'll use SQLite3, built into MacOS X and [installable on Windows](http://www.sqlite.org/download.html).

## Hands-On Experiments

We could talk on and on about databases, but it'll make more sense if you dig in and get your hands dirty.

### A Little SQLite Background

Most databases store your data in a hidden-away part of your computer's filesystem. You'd never interact with the data directly, only through the tools provided by the database engine.

SQLite, instead, stores its data in a plain-text file. This makes it incredibly easy to move, rename, delete, or transfer the database.

### Getting Started

Create a project directory we'll call `fundamental_sql`. Switch into that project directory and fire up SQLite:

{% terminal %}
$ sqlite3 example.sqlite3
SQLite version 3.7.7 2011-06-25 16:35:41
Enter ".help" for instructions
Enter SQL statements terminated with a ";"
sqlite> 
{% endterminal %}

You've run the `sqlite3` command-line tool, told it to create a database in the file `example.sqlite3`, and now the prompt is waiting for instruction.

### Creating a Table

The first thing to do is create a table:

{% terminal %}
sqlite> CREATE TABLE fruits(id INTEGER PRIMARY KEY AUTOINCREMENT, name VARCHAR(31), quantity INT);
{% endterminal %}

SQL commands are not case sensitive, but the convention is to write SQL instructions/keywords in ALL UPPERCASE and write data/names in lowercase.

This instruction creates a table named `fruits` that has three columns:

* an `id` column that is an "autoincrement primary key". That means whenever we insert a row into the table, the database engine will automatically assign a unique ID number to the row. The first row will get ID 1, the second one ID 2, etc. IDs will never be repeated.
* a `name` column that is type `VARCHAR` or "variable character", like a string, with a maximum length of 31 characters
* a `quantity` column that is an integer

### Inserting Data

Let's try inserting two fruits into our table:

{% terminal %}
sqlite> INSERT INTO fruits(name, quantity) VALUES ('apples', 6);
sqlite> INSERT INTO fruits(name, quantity) VALUES ('oranges', 12);
sqlite> INSERT INTO fruits(name, quantity) VALUES ('bananas', 18);
{% endterminal %}

Don't you love the feedback you get? Dead silence.

### Displaying Data

Let's see if our table actually has the data we put in.

{% terminal %}
sqlite> SELECT * FROM fruits;
1|apples|6
2|oranges|12
3|bananas|18
{% endterminal %}

Hey, it's data! We use the `SELECT` command to find rows in the table. Specifically, here we said `SELECT *` which means "find all the data/columns". Then `FROM fruits` means to look in the table named `fruits`.

#### Better Formatted Output

In SQLite there's a custom feature to format the output a bit more nicely. Try this:

{% terminal %}
sqlite> .mode column
sqlite> .header on
sqlite> SELECT * FROM fruits;
id          name        quantity  
----------  ----------  ----------
1           apples      6         
2           oranges     12        
3           bananas     18
{% endterminal %}

Now we can see that our three fruits are in there, the quantites are set, and the IDs were automatically incremented.

### Scoping Data

When you have a very small dataset, it's possible to just print out the whole table to find what you're looking for. But as the data grows that becomes impossible.

Let's look at how you can scope down your `SELECT` queries using `WHERE`:

{% terminal %}
sqlite> SELECT * FROM fruits WHERE name='apples';
id          name        quantity  
----------  ----------  ----------
1           apples      6         
sqlite> SELECT * FROM fruits WHERE quantity=18;
id          name        quantity  
----------  ----------  ----------
3           bananas     18        
{% endterminal %}

The `WHERE` limits the returned rows to only those with the specified attribute matching.

### Calculating Data

Queries aren't limited to just matching the existing data. They can also run functions or calculations on that data and match against the results:

{% terminal %}
sqlite> SELECT * FROM fruits WHERE LENGTH(name)=7;
id          name        quantity  
----------  ----------  ----------
2           oranges     12        
3           bananas     18         
{% endterminal %}

The `LENGTH` function returns the number of characters in a string. Both `oranges` and `bananas` have 7 characters, so those rows are displayed here.

### Limited Selection

Imagine that our table has many more columns of data, like a timestamp of when the fruit was last stocked, timestamp of the last sale, country of origin, etc.

Many times when we query a table we only care about a subset of the row's data. Say we only want to find the `name` of the fruit with `id` of `3`:

{% terminal %}
sqlite> SELECT name FROM fruits WHERE id=3;
name      
----------
bananas   
{% endterminal %}

We get back only the column we asked for, `name`, as opposed to all the columns when we used `*` before.

### Removing Rows

Removing rows works just like `SELECT` but with the instruction `DELETE`:

{% terminal %}
sqlite> DELETE FROM fruits WHERE name='oranges';
sqlite> SELECT * FROM fruits;
id          name        quantity  
----------  ----------  ----------
1           apples      6         
3           bananas     18        
{% endterminal %}

The `DELETE` instruction will delete all matching rows and there's no "undo". If your `WHERE` clause has a typo, mistake, or doesn't exist you could cause havoc on the data.

### Auto-Increment Keys

And note what happens when we now insert a new fruit:

{% terminal %}
sqlite> INSERT INTO fruits(name, quantity) VALUES ('grapes', 128);
sqlite> SELECT * FROM fruits;
id          name        quantity  
----------  ----------  ----------
1           apples      6         
3           bananas     18        
4           grapes      128       
{% endterminal %}

The IDs go `1`, `3`, `4`. The ID `2`, formerly used by the oranges, will not be reused.

### Updating Rows

We can change data of existing rows using `UPDATE`:

{% terminal %}
sqlite> UPDATE fruits SET quantity=17 WHERE name='bananas';
sqlite> SELECT * FROM fruits;
id          name        quantity  
----------  ----------  ----------
1           apples      6         
3           bananas     17        
4           grapes      128      
{% endterminal %}

### Adding Columns to the Table

As you develop an application you'll find that your tables need more and more columns. We can add columns to an existing table:

{% terminal %}
sqlite> ALTER TABLE fruits ADD COLUMN country_of_origin VARCHAR(127);
sqlite> SELECT * FROM fruits;
id          name        quantity    country_of_origin
----------  ----------  ----------  -----------------
1           apples      6                            
3           bananas     17                           
4           grapes      128                          
{% endterminal %}

Then maybe we want to set them all to Mexico:

{% terminal %}
sqlite> UPDATE fruits SET country_of_origin='Mexico';
sqlite> SELECT * FROM fruits;
id          name        quantity    country_of_origin
----------  ----------  ----------  -----------------
1           apples      6           Mexico           
3           bananas     17          Mexico           
4           grapes      128         Mexico                               
{% endterminal %}

### Ordering

Be default data will be output in the order it was inserted, but you can't count on that. If order matters to you, you need to add an `ORDER BY` clause:

{% terminal %}
sqlite> SELECT * from fruits ORDER BY name;
id          name        quantity    country_of_origin
----------  ----------  ----------  -----------------
1           apples      6           Mexico           
3           bananas     17          Mexico           
4           grapes      128         Mexico
{% endterminal %}

See! The order is totally diff...derp. We inserted them in alphabetical order. Let's display them in *reverse* alphabetical order:

{% terminal %}
sqlite> SELECT * from fruits ORDER BY name DESC;
id          name        quantity    country_of_origin
----------  ----------  ----------  -----------------
4           grapes      128         Mexico           
3           bananas     17          Mexico           
1           apples      6           Mexico        
{% endterminal %}

Adding `DESC` means "descending". Ordering defaults to `ASC` or "ascending". So using `DESC` flips the normal order -- here returning our fruits in reverse alphabetical order by name.

### Relationships

Relationships are where SQL starts to get both very powerful and tricky. Let's create a second table that records each fruit sale at our store:

{% terminal %}
sqlite> CREATE TABLE sales(id INTEGER PRIMARY KEY AUTOINCREMENT, fruit_id INTEGER, created_at DATETIME);
{% endterminal %}

This table should *not* hold the name of the fruit, it's current quantity, etc. Instead, it holds a reference to the fruit in the `fruits` table. This reference is held in the column `fruit_id` and is the numeric `id` from the `fruits` table for the associated row.

This is called a **foreign key**.

#### Insert Sales Data

We can then insert a bit of sales data:

{% terminal %}
sqlite> INSERT INTO sales(fruit_id, created_at) VALUES(1, CURRENT_TIMESTAMP);
sqlite> INSERT INTO sales(fruit_id, created_at) VALUES(3, CURRENT_TIMESTAMP);
sqlite> INSERT INTO sales(fruit_id, created_at) VALUES(1, CURRENT_TIMESTAMP);
sqlite> SELECT * FROM sales;
id          fruit_id    created_at         
----------  ----------  -------------------
1           1           2013-02-27 14:33:58
2           3           2013-02-27 14:36:08
3           1           2013-02-27 14:36:13
{% endterminal %}

#### Joining Tables

Let's say we want a summary of the fruit sales we can send to our boss. Explaining to him that "`fruit_id` of `1` means `apples`" won't go over well. We want to combine the data from the `fruits` table with that from the `sales` table:

{% terminal %}
sqlite> SELECT fruits.name, sales.created_at FROM fruits INNER JOIN sales ON fruits.id=sales.fruit_id;
name        created_at         
----------  -------------------
apples      2013-02-27 14:33:58
bananas     2013-02-27 14:36:08
apples      2013-02-27 14:36:13
{% endterminal %}

We want to find (`SELECT`) the field `name` from the `fruits` table along with the `created_at` from the `sales` table, connecting them where the `id` in `fruits` is equal to the `fruit_id` in sales.

In effect, a `JOIN` is like creating a new table composed of two of more other tables. The data is aligned/connected based on the `ON` criteria.

Note that our output has three rows because there were three sales. The name `apples` matched to two different sales, so it appears twice.

### Three-Way Relationships

Let's create customers and add them to the sales:

{% terminal %}
sqlite> CREATE TABLE customers(id INTEGER PRIMARY KEY AUTOINCREMENT, name VARCHAR(63));
sqlite> INSERT INTO customers(name) VALUES ('Jeff');
sqlite> INSERT INTO customers(name) VALUES ('Violet');
sqlite> INSERT INTO customers(name) VALUES ('Vincent');
sqlite> SELECT * FROM customers;
id          name      
----------  ----------
1           Jeff      
2           Violet    
3           Vincent   
sqlite> ALTER TABLE sales ADD COLUMN customer_id INTEGER;
sqlite> UPDATE sales SET customer_id=2 WHERE id=1;
sqlite> UPDATE sales SET customer_id=2 WHERE id=3;
sqlite> UPDATE sales SET customer_id=1 WHERE id=2;
sqlite> SELECT * FROM sales;
id          fruit_id    created_at           customer_id
----------  ----------  -------------------  -----------
1           1           2013-02-27 14:33:58  2          
2           3           2013-02-27 14:36:08  1          
3           1           2013-02-27 14:36:13  2    
{% endterminal %}

Then run a join between `sales`, `fruits`, and `customers`:

{% terminal %}
sqlite> SELECT customers.name, fruits.name, sales.created_at FROM fruits INNER JOIN sales ON fruits.id=sales.fruit_id INNER JOIN customers ON sales.customer_id=customers.id;
name        name        created_at         
----------  ----------  -------------------
Violet      apples      2013-02-27 14:33:58
Jeff        bananas     2013-02-27 14:36:08
Violet      apples      2013-02-27 14:36:13
{% endterminal %}

And we can conclude that Violet is a fan of apples.

To exit out of the `sqlite>` prompt type `.exit`

## SQL Support Tools

You do *not* need to use any special tool or library to run SQL and interact with databases.

*However*, SQL queries, like all programming, are prone to error. When you make an error quering or updating your database it might just give you back unexpected results. Or it might delete all your data. You run backups, right?

It's not an outlandish possibility. [Even great programmers make mistakes with their database](https://github.com/blog/744-today-s-outage). Just "being careful" probably isn't enough.

In addition, SQL is not the most fun thing to write. You end up doing a lot of string manipulation to put together a query just right. There are usually quotes and escaped quotes, even in a simple query.

Being both somewhat difficult to build up and error prone, many programmers prefer to use intermediary libraries to *generate* SQL. If you accept that SQL is a programming language, then these libraries do a form of metaprogramming: code that writes code.

### Object-Relational Mappers (ORMs)

In the Ruby world, we prefer to work in object. SQL is not object oriented, it's based on relationships.

Most Ruby libraries for interacting with databases are "Object-Relational Mappers" which means they convert, on the fly, the relational data from the database into Ruby objects.

This means that, in your Ruby code, you usually don't have to think about SQL. You get to stay in the context of objects with attributes and methods, not raw chunks of text like we've been outputting from the SQLite console.

### ActiveRecord

In the Ruby world, ActiveRecord (often abbreviated to AR) is by far the dominant player. It's the default database library for Rails. It is an awesomely powerful library.

However, it works hard to hide the database from you. If you're just getting started with databases, it's valuable for you to be a little closer to the SQL. An effective programmer might write code using AR, but simultaneously understand the SQL that's being generated behind the scenes.

Knowing what's happening at the SQL level can be important for security, performance, and data integrity.

### Sequel

The Sequel library allows you to stay a bit closer to the SQL. It provides APIs which are light wrappers around the SQL instructions we've practiced above.

Hop over the our [Getting Started with Sequel]({% page_url topics/sequel %}) tutorial.

## References

* [SQLite Tutorial by Zetcode.com](http://zetcode.com/db/sqlite/)
* [SQL Interactive Tutorial](http://sqlzoo.net/wiki/Main_Page)

