# Query Strategy

As development on a project progresses it's likely that some actions will grow to kick off too many queries or some requests may be taking too long for some reason, but how does one fix this problem?

Two ways to improve the speed of the query time during a request are to:

1. Ensure the database is appropriately indexed
2. Combine separate queries together if possible

## Indices

Database tables without indices will degrade in performance as more records get added to them over time, since the database engine will have to look through more records to find what it's looking for.  Adding an index to a table will ensure consistent long-term performance in querying against the table even as many thousands of records get added to it.

### What to Index

If a model uses the `find_by_x` method then the `x` column in the database should be indexed.  Thinking in terms of the application, the way users interact with your domain data will suggest what columns on your models could use indices.  Can they search for articles by keyword and written by a specific user?  Then indexing the user_id of the article author will be in order.

One might ask why an index isn't added to every column since the performance for searching against indexed columns of a table will be improved.  Unfortunately, indices don't come for free as extra processing will be required of the database when records are inserted or updated in order to maintain the index.  For this reason indices should only be added to columns that are queried against in the application.

One nice thing about applying indices to our tables is that the application will inherit the performance gains without having to alter our model code.  An example of this is getting a list of comments on an article.  If the article model contains `has_many :comments` then the comments database table will have an `article_id` column.  Adding an index on `article_id` will improve the speed of the query when processing something like `@article.comments.each ...` in a controller or view.

### Indexing a Single Column

Consider the comment model in a blogging application referred to in the previous section.  The model has the following fields:

* article_id
* author_name
* body
* created_at
* updated_at

To add an index on `article_id` to the `comments` table we'd generate a migration and edit it as follows:

```ruby
def AddIndexOnArticleIdToComments < ActiveRecord::Migration
  def self.up
    add_index :comments, :article_id
  end

  def self.down
    remove_index :comments, :article_id
  end
end
```

### Indexing Multiple Columns

Searching against multiple columns of a model (using something like `find_by_x_and_y`) would need a composite index in order to efficiently search against both columns.  To add a composite index to a table simply pass an array of the columns to index as the second parameter to `add_index`.  Adding a composite index on the `author_name` and `created_at` fields to the `comments` table would be look like the following:

```ruby
def AddIndexOnAuthorNameAndCreatedAtToComments < ActiveRecord::Migration
  def self.up
    add_index, :comments, [:author_name, :created_at]
  end

  def self.down
    remove_index :comments, [:author_name, :created_at]
  end
end
```

### EXPLAIN

Standard SQL defines a keyword called `EXPLAIN` which will output data
about the database's query plan, or how it was able to retrieve the
requested data. If you have a puzzlingly slow query, sometimes it can
shed some light just to let the database tell you what it's doing.

To run an `EXPLAIN` statement inside your Rails application, you could
use the following from the console:

```text
$ rails dbconsole
db_name=# EXPLAIN SELECT * FROM articles;
                           QUERY PLAN
-----------------------------------------------------------------
 Seq Scan on articles  (cost=0.00..10.70 rows=70 width=1052)
 (1 row)

db_name=# \q
$
```

The [PostgreSQL documentation](http://www.postgresql.org/docs/current/static/using-explain.html) covers `EXPLAIN` quite well.

## Using `includes`

Another way to improve the query time of a request is to reduce the number of queries being made.  This is accomplished by selecting more data in a single query instead of executing multiple queries.  In the [Measuring Performance](measuring) section we saw a log from showing an article page which displayed comments made on the article.

This type of loading should not be done in the controller.  Rather, a scope or method should be placed on the model so that the controller just calls a single method.  This way, if the model is used in another controller or elsewhere in the application that logic can be leveraged again without having to remember to copy it from the previous controller.

The `includes` query method is used to chain an ARel scope to note that an association should be eagerly loaded when the parent object is loaded.  Let's watch the development log as we interact with an article and its comments in the Rails console:

```text
 # commented below lines are output from the development.log file
ruby> a = Article.find(1)
 # Article Load (0.4ms)  SELECT "articles".* FROM "articles" WHERE "articles"."id" = 1 LIMIT 1
ruby> a.comments.all
 # Comment Load (0.4ms)  SELECT "comments".* FROM "comments" WHERE ("comments".article_id = 1)

 # Now with includes
ruby> a = Article.includes(:comments).find(1)
 # Article Load (0.4ms)  SELECT "articles".* FROM "articles" WHERE "articles"."id" = 1 LIMIT 1
 # Comment Load (0.3ms)  SELECT "comments".* FROM "comments" WHERE ("comments".article_id = 1)
```

Note that for the first two commands only a single SQL query shows up in the log file, yet when the `includes(:comments)` command is run it results in two SQL queries being executed.

There's not much performance gain using `includes` in this example, but let's see what happens when we add another `has_many` relationship to a `Comment`.  After creating a `Reply` model, adding `has_many :replies` to the `Comment` model, and editing and running the corresponding migration let's inspect the logs again:

```text
 # create an article and 3 corresponding comments, assume this article has an ID of 2
ruby> a = Article.find(2)
 # Article Load (0.4ms)  SELECT "articles".* FROM "articles" WHERE "articles"."id" = 2 LIMIT 1
ruby> a.comments.each {|comment| comment.replies.all}
 # Comment Load (0.4ms)  SELECT "comments".* FROM "comments" WHERE ("comments".article_id = 2)
 # Reply Load (0.3ms)  SELECT "replies".* FROM "replies" WHERE ("replies".comment_id = 1)
 # Reply Load (0.3ms)  SELECT "replies".* FROM "replies" WHERE ("replies".comment_id = 2)
 # Reply Load (0.2ms)  SELECT "replies".* FROM "replies" WHERE ("replies".comment_id = 3)
```

We see that an additional SQL query gets executed for each reply that each comment has.  How many do you think there will be after using `includes` to load the nested replies as well?

```text
ruby> a = Article.includes(:comments => :replies).find(2)
 # Article Load (0.5ms)  SELECT "articles".* FROM "articles" WHERE "articles"."id" = 1 LIMIT 1
 # Comment Load (0.4ms)  SELECT "comments".* FROM "comments" WHERE ("comments".article_id = 1)
 # Reply Load (0.4ms)  SELECT "replies".* FROM "replies" WHERE ("replies".comment_id IN (1,2,3,4))
```

Here we see a hash was passed to `includes` in order to specify the relationships that should be eagerly loaded when an `Article` is loaded. `includes` can also take an array to specify that multiple `has_many` relationships should be eagerly loaded.

If the application is Rails 2.x the finder methods have an `:include` option to achieve the same result.

### Using `default_scope`

If an object is always going to load its child records then a `default_scope` can be setup on the model so that the child is always eagerly loaded whenever the parent object is loaded.  Continuing with our previous example, suppose we always want the comments for an article to be loaded.  Instead of having to remember to add `:include => :comments` to all finder calls just add the following to the `Article` model:

```ruby
default_scope :include => :comments
```

After the above has been added to the model, then code as simple as `Article.find(1)` will include the associated `comments`.  `default_scope` has the drawback that this `:include` will *ALWAYS* be included in any fetch of an `Article` object by default.  The `unscoped` method will need to be called in order to prevent the associated comments from being included when the object loads.

### Using a Scope

In order to avoid having `default_scope` polute all object loads of an `Article` an alternative is writing a custom scope to do the same thing:

```ruby
scope :with_comments, :include => :comments
```

The `Article` model now has a `with_comments` scope that can be used where associated `comments` are eagerly loaded, but other calls to the model will not pay the cost of loading these extra comments.  This alternative is nice since we now gain the convenience of loading the associated comments when desired, but aren't forced to always do so.  It's heavy when you want it, light when you don't.

## Counter Cache

If you frequently want to get a count of the associated objects from a `has_many` relationship then a *Counter Cache* may be employed.  An example where this would be helpful is a page listing articles along with the number of comments each article has.  Using the counter cache will replace the need to repeatedly perform the count operation on each article.  It solves this by adding a column onto the parent class.  The parent's association methods will then automatically increment or decrement the counter column when new objects are created or destroyed, respectively and the object will remember the value of the counter column so no `COUNT` SQL query needs to be performed.

If we want to add a counter for the number of comments each article has, there are two steps:

1. Add `:counter_cache => true` to the `belongs_to :article` in the `Comment` model
2. Add a `comments_count` column to the `Article` table

```ruby
class Comment < ActiveRecord::Base
  belongs_to :article, :counter_cache => true
  ...
end
```

Notice that the `:counter_cache => true` is placed in the relationship declaration of the child model `Comment` and not in the parent model `Article`.

### Add the Column

Now create a migration adding the `comments_count` column to the `articles` table and migrate the database.

```ruby
class AddCounterCacheToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :comments_count, :integer, :default => 0
    # prime the new column for existing articles
    Article.reset_column_information
    Article.all.each do |article|
      Article.update_counters article.id, :comments_count => article.comments.length
    end
  end

  def self.down
    remove_column :articles, :comments_count
  end
end
```

### Priming the Counts

The `comments_count` column on existing records in the `articles` table needs to be primed with the correct number of comments on the article in order for the counter cache to work.  The `comments_count` attribute is marked as read-only in `Article` model, so attempts to modify it directly will fail.  The `update_counters` method in the above migration is what allows the value to be modified.

### Usage

Calling `size` on the `comments` association will use the cached value instead of performing the count, which is also why `length` was used in the migration above instead of `size`.  This can be verified by watching the logs:

```text
ruby> Article.first.comments.length
 => 3
 # Article Load (1.0ms)  SELECT "articles".* FROM "articles" LIMIT 1
 # Comment Load (0.6ms)  SELECT "comments".* FROM "comments" WHERE ("comments".article_id = 1)

ruby> Article.first.comments.count
 => 3
 # Article Load (1.1ms)  SELECT "articles".* FROM "articles" LIMIT 1
 # SQL (0.3ms)  SELECT COUNT(*) FROM "comments" WHERE ("comments".article_id = 1)

ruby> Article.first.comments.size
 => 3
 # Article Load (0.5ms)  SELECT "articles".* FROM "articles" LIMIT 1
```

When a new comment is created via the association helper method we can see the count is kept up to date:

```text
ruby> Article.first.comments.create(:body => "New comment")
 # AREL (0.5ms)  INSERT INTO "comments" ("article_id", "author_name", "body", "created_at", "updated_at") VALUES (1, NULL, 'new comment', '2011-09-13 13:12:31.108336', '2011-09-13 13:12:31.108336')
 # Article Load (0.4ms)  SELECT "articles".* FROM "articles" WHERE "articles"."id" = 1 LIMIT 1
 # AREL (1.7ms)  UPDATE "articles" SET "comments_count" = COALESCE("comments_count", 0) + 1 WHERE "articles"."id" = 1
ruby> Article.first.comments.size
 => 4
 # Article Load (0.5ms)  SELECT "articles".* FROM "articles" LIMIT 1
```

## Rethinking Data Storage

Another way to reduce time spent at the database level is to move data out of the database if possible.  If some of your data doesn't need to be in fully normalized database records then there's no reason to force something that doesn't fit.

### Static Data

If you have some static data that may be a candidate for something to move out of the database.  A common example would be a list of state names with abbreviations to be used in a form.  Something like this could be pulled out of the database and into an initializer:

```ruby
 # config/initializers/states.rb
STATE_ABBREVIATIONS = {
  "MD" => "Maryland",
  "ME" => "Maine",
  ...
}
```

This `STATE_ABBREVIATIONS` hash is now accessible everywhere in the application.

### ActiveHash

If you need to place a little more logic around dat that will remain mostly static where a vanilla `Hash` constant might be too basic, consider using the `active_hash` gem. It gives you the ability "query" static data in an `ActiveRecord` fashion which may be stored in memory, YAML files, or in a format of your choosing. It even provides some sugar letting you define relations between `ActiveHash` and `ActiveRecord` objects! Check out the [github repository](https://github.com/zilkey/active_hash) for more information.

### Serialized Columns

Another possibile way to restructure your data is to serialize structures such as arrays or hashes into a single column in the table.  Active Record can convert structures into a YAML format to be stored in a text column simply by marking the attribute with the `serialize` property in the model:

```ruby
class Article < ActiveRecord::Base
  ...
  serialize :metadata
  ...
end

ruby> article = Article.create(:metadata => {:read_on => Date.today, :rating => 5})
ruby> article.metadata[:read_on]
 => Tue, 13 Sep 2011
```

Active Record takes care of converting to YAML when saving the property or converting back to the desired data structure when reading it out of the database.

## References

* https://github.com/zilkey/active_hash
* http://api.rubyonrails.org/classes/ActiveRecord/Base.html
* http://guides.rubyonrails.org/association_basics.html#belongs_to-counter_cache

