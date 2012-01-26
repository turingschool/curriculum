---
layout: page
title: Query Strategies
section: Performance
---

As development on a project progresses it's likely that some actions will grow to kick off too many queries or some requests may be taking too long for some reason, but how do we fix this problem?

Two ways to improve the speed of the query time during a request are to:

1. Ensure the database is appropriately indexed
2. Combine separate queries together

## Indices

Database tables without indices will degrade in performance as more records get added to them over time. The more records added to the table, the more the database engine will have to look through to find what it's looking for.  Adding an index to a table will ensure consistent long-term performance in querying against the table even as many thousands of records get added to it.

### What to Index

If a model uses the `find_by_x` method then the `x` column in the database should be indexed.  Thinking in terms of the application, the way users interact with your domain data will suggest what columns on your models could use indices.  Do you list articles written by a specific user?  Then indexing the `user_id` of the article author will be in order.

#### Indices Aren't Free

One might ask why an index isn't added to every column since the performance for searching the table will be improved.  Unfortunately, indices don't come for free. Each insert to the table will incur extra processing to maintain the index.  For this reason, indices should only be added to columns that are _actually queried_ in the application.

#### But Read Performance Is

When you add indices to your tables, the application will gain performance without having to alter any model code.  

For example, imagine you're fetching the comments associated with an article. If the article `has_many :comments` then the comments table will have an `article_id` column.  Adding an index on `article_id` will improve the speed of the query significantly.

### Indexing a Single Column

Consider the comment model in a blogging application.  The model has the following fields:

* `article_id`
* `author_name`
* `body`
* `created_at`
* `updated_at`

To add an index on `article_id` to the `comments` table we'd create a migration as follows:

```ruby
def AddIndexOnArticleIdToComments < ActiveRecord::Migration
  def change
    add_index :comments, :article_id
  end
end
```

### Indexing Multiple Columns

Searching against multiple columns of a model (using something like `find_by_x_and_y`) would need a _composite index_ in order to efficiently search against both columns.  

To add a composite index to a table pass an array of the columns to `add_index`.  Adding a composite index on the `author_name` and `created_at` fields to the `comments` table would like the following:

```ruby
def AddIndexOnAuthorNameAndCreatedAtToComments < ActiveRecord::Migration
  def change
    add_index, :comments, [:author_name, :created_at]
  end
end
```

### EXPLAIN

Standard SQL defines a keyword `EXPLAIN` which will output data about the database's query plan. This can show you how the database is locating your requested data. If you have a puzzlingly slow query, sometimes it can
shed light on what's happening behind the scenes.

#### Running Within the Database

To run an `EXPLAIN` inside your Rails application, you could
use the following from the database console:

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

#### Within Rails / Rails Console

As of Rails 3.2, the ARel engine which generates `ActiveRecord` queries supports an `explain` method. You might call `.explain` from the console line this:

```irb
Tag.where(:name => "ruby").explain
```

Which would generate output like this:

```plain
 Tag Load (0.1ms)  SELECT "tags".* FROM "tags" WHERE "tags"."name" = 'ruby'
 EXPLAIN (0.1ms)  EXPLAIN QUERY PLAN SELECT "tags".* FROM "tags" WHERE "tags"."name" = 'ruby'
EXPLAIN for: SELECT "tags".* FROM "tags"  WHERE "tags"."name" = 'ruby'
0|0|0|SCAN TABLE tags (~100000 rows)
```

The `SCAN TABLE` shows that it's not using an index. After adding an index and performing the same query:

```plain
  Tag Load (0.1ms)  SELECT "tags".* FROM "tags" WHERE "tags"."name" = 'ruby'
  EXPLAIN (0.1ms)  EXPLAIN QUERY PLAN SELECT "tags".* FROM "tags" WHERE "tags"."name" = 'ruby'
EXPLAIN for: SELECT "tags".* FROM "tags"  WHERE "tags"."name" = 'ruby'
0|0|0|SEARCH TABLE tags USING INDEX index_tags_on_name (name=?) (~10 rows)
```

You can see it using the index `index_tags_on_name`.

## Using `includes`

Another way to improve the total time of a request is to reduce the number of queries being made.  This is accomplished by selecting more data in a single query instead of executing multiple queries.  In the [Measuring Performance](measuring) section, we looked at this log snippet:

```text
1 Started GET "/articles/1" for 127.0.0.1 at 2011-09-12 13:07:21 -0400
2   Processing by ArticlesController#show as HTML
3   Parameters: {"id"=>"1"}
4   Article Load (0.3ms)  SELECT "articles".* FROM "articles" WHERE "articles"."id" = 1 LIMIT 1
5   Tag Load (0.3ms)  SELECT "tags".* FROM "tags" INNER JOIN "taggings" ON "tags".id = "taggings".tag_id WHERE (("taggings".article_id = 1))
6   SQL (0.2ms)  SELECT COUNT(*) FROM "comments" WHERE ("comments".article_id = 1)
7   Comment Load (0.2ms)  SELECT "comments".* FROM "comments" WHERE ("comments".article_id = 1)
8 Rendered articles/show.html.erb within layouts/application (102.8ms)
9 Completed 200 OK in 124ms (Views: 106.7ms | ActiveRecord: 1.0ms)
```

The purpose of the show action is to display an article, but the way our page is setup it's kicking off queries against `articles`, `tags`, and `comments` tables.

### Scopes with `includes`

The `includes` query method is used to eagerly load child records when the parent object is loaded.  Let's watch the development log as we interact with an article and its comments in the Rails console:

```irb
001 > a = Article.first
  Article Load (0.1ms)  SELECT "articles".* FROM "articles" LIMIT 1
 => #<Article id: 8, title: "More Samples", body: "Real data.", created_at: "2012-01-24 18:58:06", updated_at: "2012-01-24 18:58:13"> 
002 > a.comments.all
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = 8
 => [#<Comment id: 6, author_name: "Jeff", body: "This article is great!", article_id: 8, created_at: "2012-01-26 01:52:46", updated_at: "2012-01-26 01:52:46">, #<Comment id: 7, author_name: "Matt", body: "This article is boring!", article_id: 8, created_at: "2012-01-26 01:52:58", updated_at: "2012-01-26 01:52:58">, #<Comment id: 8, author_name: "Steve", body: "This article is objectionable!", article_id: 8, created_at: "2012-01-26 01:53:11", updated_at: "2012-01-26 01:53:11">]
```

The two instructions ran two separate queries. But if we use `includes` in the first query...

```irb 
003 > a = Article.includes(:comments).first
  Article Load (0.2ms)  SELECT "articles".* FROM "articles" LIMIT 1
  Comment Load (0.3ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" IN (8)
 => #<Article id: 8, title: "More Samples", body: "Real data.", created_at: "2012-01-24 18:58:06", updated_at: "2012-01-24 18:58:13">
```

The one instruction kicked off two queries, eager fetching both the article and its comments. There's no performance gain when using `includes` so far. 

#### Deeper Nested Objects

Let's see what happens when we add another `has_many` relationship to a `Comment`. Say we decide to add an `Approval` model to our application which tracks the moderator approval of a `Comment`:

```plain
rails generate model Approval approved_by:integer comment_id:integer
rake db:migrate
```

Then, adding the relationships to the two models:

```ruby
class Approval < ActiveRecord::Base
  belongs_to :comment
end
```

```ruby
class Comment < ActiveRecord::Base
  has_one :approval
  #...other relationships, methods, etc
  
  def approved?
    approval
  end
end
```

Then, from the console, just for our example let's approve all comments:

```
Comment.all.each{|c| c.create_approval(:approved_by => 0)}
```

Now let's fetch our sample `Article` and count the approved comments:

```irb
001 > a = Article.first
  Article Load (0.1ms)  SELECT "articles".* FROM "articles" LIMIT 1
 => #<Article id: 8, title: "More Samples", body: "Real data.", created_at: "2012-01-24 18:58:06", updated_at: "2012-01-24 18:58:13"> 
002 > a.comments.select{|c| c.approved?}.count
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = 8
  Approval Load (0.1ms)  SELECT "approvals".* FROM "approvals" WHERE "approvals"."comment_id" = 6 LIMIT 1
  Approval Load (0.1ms)  SELECT "approvals".* FROM "approvals" WHERE "approvals"."comment_id" = 7 LIMIT 1
  Approval Load (0.1ms)  SELECT "approvals".* FROM "approvals" WHERE "approvals"."comment_id" = 8 LIMIT 1
 => 3 
```

See how it queries the `approvals` table once for each `Comment`? That could get really expensive if articles are getting many comments.

But we can improve the query count dramatically by using `includes`:

```irb
001 > a = Article.includes(:comments => :approval).first
  Article Load (0.1ms)  SELECT "articles".* FROM "articles" LIMIT 1
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" IN (8)
  Approval Load (0.2ms)  SELECT "approvals".* FROM "approvals" WHERE "approvals"."comment_id" IN (6, 7, 8)
 => #<Article id: 8, title: "More Samples", body: "Real data.", created_at: "2012-01-24 18:58:06", updated_at: "2012-01-24 18:58:13"> 
002 > a.comments.select{|c| c.approved?}.count
 => 3 
```

The first instruction kicks off three queries _regardless of how many comments there are_, then the `select` line doesn't need to run any additional queries.

`includes` takes a hash parameter to specify the relationships that should be eager loaded.

### Using `default_scope`

If an object is _always_ going to load its child records then a `default_scope` can be setup on the model. Then every query will eagerly load the children. 

Continuing with our previous example, suppose we always want the comments for an article to be loaded.  Instead of having to remember to add `:include => :comments` to all finder calls add the following to the `Article` model:

```ruby
default_scope :include => {:comments => :approval}
```

After the above has been added to the model, then `Article.find(1)` will include the associated `comments`.  

`default_scope` has the drawback that this `:include` will *ALWAYS* be included in any fetch of an `Article` object by default.  

### Using `unscoped`

If you do want to break out of the `default_scope`, use the method `unscoped`:

```
Article.unscoped.first
```

And the default scope will be ignored.

### Writing Custom Scopes

You can write your own custom scopes in `ActiveRecord` models. To achieve the same goal as before, we might write this one:

```ruby
scope :with_comments, :include => {:comments => :approval}
```

The `Article` model now has a `with_comments` scope that can be used where associated `comments` and `approval` are eager loaded, but other calls to the model will not pay the cost of loading the comments.

```ruby
Article.with_comments.first
``` 

This approach gains the convenience of loading the associated comments only when desired.

### Writing Class Methods Instead of Scopes

If you choose not to use the `scope` method itself, you can achieve the exact same results by defining a class method:

```ruby
def self.with_comments
  includes(:comments => :approval)
end
```

Then use it just like the real scope:

```ruby
Article.with_comments.first
```

There's some thinking that the `scope` method will be deprecated in the future because it's unnecessary. This class method approach achieves the same goals and just relies on normal Ruby patterns.

## Counter Cache

If you frequently want to get a count of the associated objects from a `has_many` relationship then a *Counter Cache* is useful.  

### The Problem

Imagine on an articles `index` view that the listings show how many comments are on each article. Without a counter cache, you'd need one query to initially fetch all the articles, then one additional `COUNT` query per article to count the comments.

Using the counter cache will replace the need to repeatedly perform the `COUNT` operation on the `comments` table.

It works by adding a column onto the parent class.  The parent's association methods will then automatically increment or decrement the counter column when new objects are created or destroyed. No `COUNT` SQL query needs to be performed.

### Add the Column

First create a migration adding the `comments_count` column to the `articles` table and migrate the database.

```ruby
class AddCounterCacheToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :comments_count, :integer, :default => 0
  end
end
```

### Priming the Counts

The `comments_count` column for existing records in the `articles` table needs to be primed with the current count.

The `comments_count` attribute is marked as read-only in `Article` model, so attempts to modify it directly will fail.  The `update_counters` method allows the value to be modified, so we could run the following in a console session:

```ruby
Article.all.each do |article|
  Article.update_counters article.id, :comments_count => article.comments.count
end
```

### Modifying the Relationship

Now that the data is primed, tell the `Comment` model about the cache existing on the parent class:

```ruby
class Comment < ActiveRecord::Base
  belongs_to :article, :counter_cache => true
  ...
end
```

Notice that the `:counter_cache => true` is placed in the relationship declaration of the *child* model `Comment` and not in the parent model `Article`.

### Usage

When using the counter cache, you just use the normal `.count` method:

```irb
001 > Article.first.comments.count
Article Load (0.5ms)  SELECT "articles".* FROM "articles" LIMIT 1
 => 3
```

When a new comment is created via the association helper method we can see the count is kept up to date:

```irb
001 > Article.first.comments.create(:body => "New comment")
AREL (0.5ms)  INSERT INTO "comments" ("article_id", "author_name", "body", "created_at", "updated_at") VALUES (1, NULL, 'new comment', '2011-09-13 13:12:31.108336', '2011-09-13 13:12:31.108336')
Article Load (0.4ms)  SELECT "articles".* FROM "articles" WHERE "articles"."id" = 1 LIMIT 1
AREL (1.7ms)  UPDATE "articles" SET "comments_count" = COALESCE("comments_count", 0) + 1 WHERE "articles"."id" = 1
002 > Article.first.comments.size
Article Load (0.5ms)  SELECT "articles".* FROM "articles" LIMIT 1
 => 4
```

## Rethinking Data Storage

Another way to reduce time spent at the database level is to move data out of the database completely.

### Static Data

Many applications have sets of static data that don't change.  A common example would be a list of state names with abbreviations to be used in a form.  Something like this could be pulled out of the database and into an initializer:

```ruby
 # config/initializers/states.rb
STATE_ABBREVIATIONS = {
  "MD" => "Maryland",
  "ME" => "Maine",
  ...
}
```

This `STATE_ABBREVIATIONS` hash is now accessible everywhere in the application.

### Serialized Columns

Another possible way to restructure your data is to serialize structures such as arrays or hashes into a single column in the table.  `ActiveRecord` can convert structures into a YAML format to be stored in a text column by marking the attribute with the `serialize` property in the model:

```ruby
class Article < ActiveRecord::Base
  ...
  serialize :metadata
  ...
end
```

Then, to try it out:

```irb
001 > article = Article.create(:metadata => {:read_on => Date.today, :rating => 5})
002 > article.metadata[:read_on]
 => Tue, 13 Sep 2011
```

`ActiveRecord` takes care of converting to YAML when saving the property and converting back to the desired data structure when reading it out of the database.

## References

* https://github.com/zilkey/active_hash
* http://api.rubyonrails.org/classes/ActiveRecord/Base.html
* http://guides.rubyonrails.org/association_basics.html#belongs_to-counter_cache
