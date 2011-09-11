# Outputting Text

The first and most widely used method of debugging Ruby application is simply outputting text data. Let's look at a few approaches at increasing levels of expertise.

## Reading a Request/Response

Greatly undervalued by newer Rails developers, the first stop when observing unexpected behavior should be the server log and the request/response information. Let's pick apart an example.

### Sample Request/Response

Here's an actual request from a sample application:

```text
1 Started POST "/products" for 127.0.0.1 at 2011-07-19 12:42:48 -0700
2   Processing by ProductsController#create as HTML
3   Parameters: {"utf8"=>"✓", "authenticity_token"=>"E3aGszU+Xmdq3bs9woAtMzH93zy34Z9lQqiNHwLACRY=", "product"=>{"title"=>"Apples", "price"=>"5.99", "stock"=>"12", "description"=>"A bag of apples.", "image_url"=>"apples.jpg"}, "commit"=>"Create Product"}
4   User Load (0.3ms)  SELECT "users".* FROM "users" WHERE "users"."id" IS NULL LIMIT 1
5   Order Load (1.1ms)  SELECT "orders".* FROM "orders" WHERE "orders"."id" = 48 LIMIT 1
6   AREL (0.5ms)  INSERT INTO "products" ("title", "price", "description", "image_url", "created_at", "updated_at", "stock") VALUES ('Apples', 5.99, 'A bag of apples.', 'apples.jpg', '2011-07-19 19:42:48.457003', '2011-07-19 19:42:48.457003', 12)
7 Redirected to http://localhost:3000/products/3
8 Completed 302 Found in 117ms
```

Here are some of the facts we can learn from reading the request:

* Line1: It executed a `POST` request for `/products` which should trigger the `create` action of `ProductsController`. Is this the controller and action intended? Especially scrutinize the request verb, this is a common place for mixups.
* Line2: It did attempt to execute `ProductsController#create`
* Line3: The params hash. Look for elements that are blank/nil. Is the structure reasonable? Unfortunately, because of the UTF-8 checkmark, this hash can't be copy/pasted into the console for testing. If you have trouble navigating this hash:
  * Copy it from the log output
  * Paste it into a text editor
  * Remove the `utf8` key/value pair
  * Copy the result
  * Paste it into console and experiment
  * Inspect whether attributes are correctly nested, correctly named, etc
* Lines 4-6: See the SQL interactions. Particularly pay attention to `INSERT` statements. Is the information from the Line 3 params in the `INSERT` or are there a bunch of `nil` fields? The most common issue you'll spot here is this:
  ```text
    WARNING: Can't mass-assign protected attributes: [your attributes here]
  ```
  In that case, look in the model for the `attr_accessible` method call and see if additional fields should be made accessible. Note that the suffix matters, so making `product` accessible will not automatically accept `product_id`, list both to allow mass-assignment via ID number or actual object.
* Last Lines: Redirect or render and HTML status code. Usually not helpful unless the app is redirecting you somewhere unexpected.

Just to say it one more time, the issue about *Can't mass-assign protected attributes* is the number one most common issue new Rails developers spend hours debugging. Just look for that message in the log and you'll have it fixed in seconds.
 
## Temporary Instructions

Let's next look at adding temporary instructions to our application. 

### Using Warn

Looking at the server log gave lots of great info, but it doesn't help with inspecting the values of variables or instructions. For that job, use the `warn` method of Ruby's `Kernel` object. Here's how I might insert it into the `create` action used above:

```ruby
def create
  @product = Product.new(params[:product])
  warn "Product before save:"
  warn @product.inspect
  if @product.save
    redirect_to @product, :notice => "Successfully created product."
  else
    render :action => 'new'
  end
end
```

Then in the output log see the results:

```text
Product before save:
#<Product id: nil, title: "Apples", price: nil, description: nil, image_url: nil, created_at: nil, updated_at: nil, stock: 0>


Started POST "/products" for 127.0.0.1 at 2011-07-19 13:18:26 -0700
  Processing by ProductsController#create as HTML
```

Notice that the warn comes out before where the log claims it is "starting" the response. The `warn` is output immediately, while the normal logging operations are buffered and output all together. When I use warn I'll typically put in some label to the output, like the `Product before save` here. The messages for `warn` are just strings, so you can use `\n` newlines or other text formatting to make them easier to read.

### Platform Notifications

[TODO: Section on Growl? Does it work via the Growl gem?]

### Raising Exceptions

One of my most frequently used techniques is to intentionally raise an exception. If I wanted to check out the `@product` object during the `create` action and maybe look at the parameters of the request, I'd typically do this:

```ruby
def create
  @product = Product.new(params[:product])
  raise @product.inspect
  if @product.save
  #...
```

The `raise` will immediately halt execution and display Rails' normal error page. The `raise` method accepts one parameter, a string, which will be output as the error message.

With this usage you'd see something like this:

```
RuntimeError in ProductsController#create
#<Product id: nil, title: "Apples", price: nil, description: nil, image_url: nil, created_at: nil, updated_at: nil, stock: 0>
```

The first line specifying that it was a general `RuntimeError` exception and the second line is the message, the result of our `inspect`. Generally `inspect` is a better choice than `to_s` as it'll show more about the object's internal state.

Also, further down the page you'll see the request's parameters formatted in a YAML debug block.

This is my favorite debugging technique when writing Rails applications because you don't have to dig through anything -- execution halts right at your message.  You can even use `raise` in conjunction with Ruby's here-docs and string interpolation:

```
raise <<-EOS

params: #{params.inspect}


@product: #{@product.inspect}

>>
```

### Debug Helper

If you can get to the point of execution where a view template is being rendered, then you can take advantage of the `debug` helper method. It accepts one object as an argument and outputs a nicely formatted YAML representation of the object wrapped in `<pre>` tags. The build-in Rails stylesheet already has styles for the `<pre>` tags for this reason.
  
For instance, in the form used with the `create` action, I could insert `debug` like this:

```erb
<%= debug @product %>
```

Then when the view is rendered the YAML output will be visible. 

But there's a serious problem with adding debug code -- it tends to get left behind and sent into production! One solution I've used is to define this helper in `ApplicationHelper`:

```ruby
  def d(object)
    debug object if Rails.env == "development"
  end
```

Then in the view templates just use it instead of the built in `debug`:

```erb
<%= d @product %>
```

Now any debug code would be hidden in production. Want to take it a step further? How about this:

```ruby
def d(object)
  if Rails.env == "development"
    debug object 
  else
    raise "Debug code running in test & production!"
  end
end
```

Now, assuming that you have coverage of your views in automated tests, debug code will both not be displayed and never be permitted to run in production!

## A Custom Logger

Let's say you want to debug or log a more complex process. Maybe it involves several "checkpoints" across multiple methods. Or you want to build an audit trail for actions in your application. You need a custom logger.

It's very easy to create and use thanks to Rails `ActiveSupport::BufferedLogger`. Imagine we want to build an audit log for our application. Start with an initializer `config/initializers/audit_logger.rb`

```ruby
module Kernel
  @@audit_log = ActiveSupport::BufferedLogger.new("log/audit.log")
  def audit(message)
    return unless %w(development test).include?(Rails.env) # production guard!
    preamble = "\n[#{caller.first}] at #{Time.now}\nMessage: " 
    @@audit_log.add 0, preamble + message.inspect
  end
end
```

Then anywhere in your application call the `audit` method:

```ruby
def create
  @product = Product.new(params[:product])
  audit @product.inspect
  if @product.save
    #...
```

Pop open `log/audit.log` and you'll find messages like this:

```text
[/path/to/your/app/controllers/products_controller.rb:18:in `create'] at 2011-07-19 14:12:16 -0700
Message: "#<Product id: nil, title: \"Apples\", price: nil, description: nil, image_url: nil, created_at: nil, updated_at: nil, stock: 0>"
```

Tweak the formatting to your liking, then add auditing wherever needed in your application!

### Heroku Logs

That's great for development, but what about accessing our logs in production?

The first step is to enable Heroku's "Expanded" logging add-on. From within your project directory, assuming it is already running on Heroku:

```bash
heroku addons:add logging:expanded
```

#### Fetching Logs

Getting logs from Heroku is simple:

```bash
heroku logs --tail
```

Which will give you output like this:

```text
$ heroku logs
2010-09-16T15:13:46-07:00 app[web.1]: Processing PostController#list (for 208.39.138.12 at 2010-09-16 15:13:46) [GET]
2010-09-16T15:13:46-07:00 app[web.1]: Rendering template within layouts/application
2010-09-16T15:13:46-07:00 app[web.1]: Rendering post/list
2010-09-16T15:13:46-07:00 app[web.1]: Rendered includes/_header (0.1ms)
2010-09-16T15:13:46-07:00 app[web.1]: Completed in 74ms (View: 31, DB: 40) | 200 OK [http://myapp.heroku.com/]
2010-09-16T15:13:46-07:00 heroku[router]: GET myapp.heroku.com/posts queue=0 wait=0ms service=1ms bytes=975
2010-09-16T15:13:47-07:00 app[worker.1]: 2 jobs processed at 16.6761 j/s, 0 failed ...
```

The marker in `[]` corresponds to the dyno generating the message. The log aggregates information from all your dynos and workers, so it's great for tracking down complex interactions between components.

For more extensive discussion, check out the Heroku resource center here: http://devcenter.heroku.com/articles/logging

# Exercises

[TODO: Add Exercises]