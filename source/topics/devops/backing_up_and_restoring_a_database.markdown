---
layout: page
title: Backing Up and Restoring a Database
section: DevOps
sidebar: true
---

You made it! You've launched your e-commerce platform and now you have millions of users accessing it every day. Your site is flooded with users' information, orders, items, promotions. 

That data is tremendously valuable. Lose it and your business is in serious trouble. You have to backup your database.

## A Sample Application

We will be using the [storedom](https://github.com/JumpstartLab/storedom) Rails application for these exercises. Start by cloning this repository:

{% terminal %}
$ git clone git@github.com:JumpstartLab/storedom.git
$ cd storedom
{% endterminal %}

Once you cloned the repo, make sure that you install all the gems.

{% terminal %}
$ bundle
Using rake (10.1.0)
Using i18n (0.6.9)
...
Your bundle is complete!
{% endterminal %}

## Creating Some Data

We are going to create the dabase, run the migrations and seed it with fake information. We have prepared a seed file to do that for you. To setup the database, just run `rake db:setup`.

{% terminal %}
$ rake db:setup
rake db:setup
-- enable_extension("plpgsql")
   -> 0.0242s
-- create_table("items", {:force=>true})
   -> 0.0100s
-- create_table("order_items", {:force=>true})
   -> 0.0037s
-- create_table("orders", {:force=>true})
   -> 0.0048s
-- create_table("users", {:force=>true})
   -> 0.0051s
-- initialize_schema_migrations_table()
   -> 0.0070s
User 0: Wilbert Zieme - jannie_balistreri@weimann.org created!
User 1: Jerel Reilly - darrel@dietrich.info created!
User 2: Wayne Abbott - serenity.auer@kiehn.biz created!
User 3: Jeremie Thiel - burdette_hills@sporer.biz created!
User 4: Jules Volkman V - deie@goodwin.biz created!
User 5: Margarete Wolff - cary_bartell@beatty.name created!
User 6: Jessica Gibson - cali@hills.biz created!
User 7: Hilda Rutherford III - donny_emmerich@kemmer.com created!
User 8: Rudy Bayer - tristin_erdman@lubowitzhammes.org created!
User 9: Jaylen Hessel - hailey@grady.org created!
User 10: Mrs. Jerrod Davis - anjali.walker@braunmayert.org created!
...
{% endterminal %}

Once it finishes, you'll have 50 users, 100 orders and 500 items in your database.

If you want to see the data, just start your rails server and visit `localhost:3000`.

{% terminal %}
$ rails s
{% endterminal %}

## `pg_dump`

PostgreSQL gives you a handy utility to do that called `pg_dump`. This utility makes consistent backups even if the database is being used while the backup is being run. `pg_dump` does not block other users accessing the database (readers or writers).

Dumps can be output in script or archive file formats. Script dumps are plain-text files containing the SQL commands required to reconstruct the database at the time it was saved.

Script files can be used to reconstruct the database even on other machines and other architectures, and in some cases, even on other SQL databases.



## Dumping the Data

Let's use `pg_dump` to get all your database data into a file.

{% terminal %}
$ pg_dump -F t storedom_development > development_backup.tar
{% endterminal %}

* `-F` configures the file format of the dump file. It can be a tar (t), plain (p) or custom (c).
* `-U` configures the username. In this case, our database doesn't have any.
* `-h` specifies the host name of the machine on which the server is running. When not specified, it connects to localhost.
* `-p` specifies the TCP port or local socket file extension on which the server is listening for connections. If not specified, it will use the default, which for most purposes will work.

After the options, we need to specify which database we want to back up. In this case, it is `db/development`. The `>` means pipe the output into the specified file. If you don't do that it will output to `STDOUT`, which usually isn't what you want.

After you run the command, you will be able to see a `development_backup.tar` file in your directory. This file contains your database data.

## Dropping the database

Now, we are going to drop your existing database to check that we actually restored the data from our backup.

{% terminal %}
$ rake db:drop
{% endterminal %}

Restart the server, and visit `localhost:3000`. You should see an error message that says `FATAL: database "db/development" does not exist`.

Your data is gone.

## Restoring the Database

Fortunately, we have your information backed-up. Let's restore the database by using `pg_restore`.

{% terminal %}
$ pg_restore -C -d storedom_development development_backup.tar
{% endterminal %}

* `-C` Create the database before restoring into it. If --clean is also specified, drops and recreate the target database before connecting to it.
* `-d <dbname>` Connect to database `dbname` and restore directly into the database.

Now, start your rails server. Visit `localhost:3000`... and your information is back.

## In the Wild

Manipulating real data is a very delicate affair. Before attempting any of these steps, you should backup your information. Also, be sure that your database backups are stored in a secured place. Otherwise, your users' information might be exposed.

## Heroku Postgres Backups

Let's say that you have an application running on Heroku. You can create a backup by running `PG Backups`. First, let's install the addon first.

From your application folder, run the following command:

{% terminal %}
$ heroku addons:add pgbackups
Adding pgbackups on storedom... done, v45 (free)
You can now use "pgbackups" to backup your databases or import an external backup.
Use `heroku addons:docs pgbackups` to view documentation.
{% endterminal %}

Once that you have the addon, create a copy of your database information by running the following command:

{% terminal %}
$ heroku pgbackups:capture

HEROKU_POSTGRESQL_IVORY_URL (DATABASE_URL)  ----backup--->  b001

Capturing... done
Storing... done
{% endterminal %}

PG Backups uses pg_dump to create its backup files, making it trivial to export to other PostgreSQL installations.

Now that you have created the backup, let's get your backup locally via `curl`.

{% terminal %}
$ curl -o latest.dump `heroku pgbackups:url`
32m  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 22590  100 22590    0     0  15805      0  0:00:01  0:00:01 --:--:-- 15797
{% endterminal %}

If you run `ls` on your terminal, you'll see a `latest.dump` file listed. That is the local copy of your database.

## Restoring your Database on Heroku

To restore your database, you will need to upload your dump file to a remote host such as Amazon Web Services. You will need to access that link when running `pg_restore`.

{% terminal %}
heroku pgbackups:restore HEROKU_POSTGRESQL_IVORY_URL https://s3-us-west-2.amazonaws.com/jumpstartlab/latest.dump

HEROKU_POSTGRESQL_IVORY_URL (DATABASE_URL)  <---restore---  latest.dump

 !    WARNING: Destructive Action
 !    This command will affect the app: storedom
 !    To proceed, type "storedom" or re-run this command with --confirm storedom

> storedom

Retrieving... done
Restoring... done
{% endterminal %}

In this example, `HEROKU_POSTGRESQL_IVORY_URL` is the database name given to us by Heroku. Make sure that you change that name to your existing database.

Now, if you visit your app, you'll see all the data restored.

## For Further Reading

* [pg_dump](http://www.postgresql.org/docs/8.4/static/app-pgdump.html): check more advanced options for dumping your PostgreSQL database into a file.
* [pg_restore](http://www.postgresql.org/docs/9.2/static/app-pgrestore.html): check more advanced options for restoring your PostgreSQL database.
* [Heroku Dev Center](https://devcenter.heroku.com/articles/heroku-postgres-import-export): contains documentation about importing and exporting databases on Heroku.
