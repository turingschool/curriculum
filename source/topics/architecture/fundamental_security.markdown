---
layout: page
title: Fundamental Rails Security
sidebar: true
---

## Background

Security is hard. It just takes a single mistake in one little place and your entire application can be compromised. Many major applications with teams of experienced engineers have had security problems at one time or another (GitHub, LinkedIn, Twitter, etc).

Security is a challenge you can never completely solve, but you can avoid the easy mistakes.

### Obscurity

Many of the attacks below will appear to necessitate knowledge of the code behind the application. *Don't be fooled by security through obscurity*. Hiding your vulnerabilities might increase the time until they're found, but it's a delay tactic, not prevention.

#### All Source Code Will Be Public

Even for closed-source projects, you should *assume* that a malicious user has complete access to your source code. You must construct your systems so they can't break in, regardless of knowledge.

Is that far fetched? Imagine you build a successful software business. Could one of these happen?

* An employee loses their laptop and, oops, they had been meaning to turn on FileVault but forgot. Now your complete source code is out there.
* Your trusted source-control hosting service (GitHub, Beanstalk, etc) has a wide-spread security issue of their own, allowing anyone to see, pull, and change your code. [That won't happen, right?](https://github.com/blog/1068-public-key-security-vulnerability-and-mitigation)
* You attend a conference, do some work while listening to presentations, and forget to use your secure VPN connection for pushing code. You just broadcast it to the entire local network, congrats.

All of the attacks we'll look at can be either prevented or mitigated, even when the attacker has perfect knowledge of your system.

## Privilege Escalation

Probably the most common, easy to exploit, and dangerous security vulnerability is "Privilege Escalation".

### Theory

When building web applications there are a plethora of available authentication libraries. In Rails, we often rely on Devise, OmniAuth, or Sorcery.

#### Authentication

It's important to remember that authentication answers the question "Are you who you say you are?" You've claimed to be user with email address `admin@example.com`, but do you know the secret which only I (the system) and that user know -- their password?

#### Authorization

After the user is known, the more important question is that of authorization: "Are you allowed to do what you're trying to do?"

Can you see that data? Can you delete that record? After authentication has verified your identity, authorization must decide whether you are authorized to execute the desired action.

**Too often, applications do not implement a robust authorization strategy**. By relying on only authentication, the system has only two known roles:

* Unauthenticated Users
* Authenticated Users

#### Insufficient Authorization Structures

As development proceeds, that usually expands to include some kind of administrator:

* Unauthenticated Users
* Authenticated Users
* Authenticated Administrators

The authentication tools often supply some `before_filter` like `require_login` that mandate the authentication process succeeds.

#### The Weakness

The vulnerability comes about when users are not differentiated from one another.

* When I log in as "User 1", I can see and manipulate my own data
* If a "User 2" logs in, they can see and manipulate their data
* When the application is vulnerable, authenticated User 1 can often view or change data for authenticated User 2

### Executing the Attack

Most Rails applications, in one place or another, expose URLs with a unique identifier (`id`) embedded in the URL.

Simply access one of those URLs through the normal interface (links, nav, etc), then change the ID in the URL. Some frequent patterns include:

* Browse to your user profile and something like `http://example.com/users/6`
* Change the ID to `http://example.com/users/5`, you might see the profile (profiles may or may not be intentionally public)
* Look in your normal screen for an edit link, probably `http://example.com/users/6/edit`
* Try `http://example.com/users/5/edit`, which shouldn't be allowed
* Try accessing your own `http://example.com/users/6/edit` and look in the HTML form to see if there's a hidden `id` attribute. Change it to `5` and submit the form.
* Try using CURL or another tool to `PUT` similar data to `http://example.com/users/5` and see if you can change their information. What about `DELETE`?

The same attack applies wherever you have custom records for your user, but know there are similar records for other users. Look for URLs like `/orders/6`, `/messages/92830`, `/dashboards/6` and try to exploit them.

### Recognizing Vulnerabilities

There's **nothing wrong** with having IDs in the URL. Attempts to obfuscate the ID (by using some kind of hashed value, text instead of a numeric ID, etc) are only delay tactics, they are not fixes. Rails, itself, bears no real blame for this issue, it's all about your application.

The fastest way to look for this vulnerability is to:

* Open each controller
* Look for any class methods called on models (such as `Article.find`, `Order.destroy`, etc)

Most often when class methods are used in controllers they are passed data from `params`. This is usually a vulnerability.

### Preventing the Attack

90% of the time, the fix is simple. You just need to scope the operation within the `current_user`. Instead of:

```ruby
def update
  order = Order.find(params[:id])
  if order.update_attributes(params[:order])
    redirect_to order, :notice => "Order Updated"
  else
    render :edit, :notice => "Validation Failed"
  end
end
```

You eliminate the class method and find the order within the orders owned by the current user:

```ruby
def update
  order = current_user.orders.find(params[:id])
  if order.update_attributes(params[:order])
    redirect_to order, :notice => "Order Updated"
  elsif order.nil?
    redirect_to current_user.orders, :notice => "Order Not Found"
  else
    render :edit, :notice => "Validation Failed"
  end
end
```

This fix probably necessitates *no change* at the model level, assuming that a `User` expresses a `has_many` relationship with the `Order`.

#### Why It Works

In the first snippet, we run this line:

```ruby
order = Order.find(params[:id])
```

Which generates SQL like this when given an ID of `1`:

```sql
SELECT * from orders where orders.id == 1;
```

In the improved version, we do this:

```
order = current_user.orders.find(params[:id])
```

Which generates SQL like this when given an ID of `1` and assuming a current user with ID of `6`:

```sql
SELECT * from orders where orders.id == 1 AND orders.user_id == 6;
```

Since we trust the `current_user` helper to provide us a correct `user_id`, a nefarious user cannot change the right side of the `AND`. If they manipulate the URL so an order ID of an order belonging to another user is put in for the `orders.id` clause, no row will be found.

Based on the second controller snippet, a not-found `order` will result in a safe redirect back to the current user's orders listing.

### Things to Remember

* Be very suspicious of *any* class method in a controller.
* Nefarious users can access any public action and pass in any combination of parameters they want. Just because there's no link or form doesn't mean an action can't be exploited.
* Scope all queries off of a trusted domain object, like the current user.
* Be careful with your order of operations -- don't change any data until you've successfully found the specified record.

### Exercise

#### Prepare Tooling

You'll want to be able to create raw HTTP requests without the limitations of the browser. Here are some options:

##### Faraday Gem

If you'd like to work from IRB, consider using the [Faraday Gem](https://github.com/lostisland/faraday) which will allow you to create and send requests, then read responses in a friendly Ruby style.

##### Postman Chrome App

Another option is the [Postman Chrome App](https://chrome.google.com/webstore/detail/postman-rest-client/fdmmgilgnpjigdojojpjoooidkmcomcm?hl=en) which provides a graphical interface for sending HTTP requests.

##### OS X GUI

If you'd prefer a native graphical interface for tweaking and sending HTTP requests, try [Graphical HTTP Client](https://itunes.apple.com/us/app/graphicalhttpclient/id433095876?mt=12) from the Apple App Store.

##### CURL

[You can do everything through CURL](http://superuser.com/questions/149329/what-is-the-curl-command-line-syntax-to-do-a-post-request), if you really feel like it.

#### Setup the Code

We'll look at a student project which exemplifies several common weaknesses. Clone the project:

```plain
git clone git@github.com:jmejia/store_engine.git fundamental_security
```
Get it setup to run locally:

{% terminal %}
$ cd fundamental_security
$ bundle
$ rake db:migrate && rake db:seed
$ bundle exec rails server
{% endterminal %}

#### Setup Accounts and Data

* Open three incognito browser windows
* In the first...
  * Create a user account and login ("Account A")
  * Place an order using Account A
* In the second...
  * Create a second user account and login ("Account B")
* In the third...
  * Login to the site using the admin account "demoXX+steve@jumpstartlab.com" and password "password"
  * View the order you just placed in the admin interface

#### Begin the Exploit

* Take a look at https://github.com/jmejia/store_engine/blob/master/app/controllers/orders_controller.rb
* Can you figure out how to change the `total_cost` of Account A's order to $0.00 through the `update` method?
* From your Account B window, can you completely erase Account A's order?

Create another order from Account A, then...

* Take a look at https://github.com/jmejia/store_engine/blob/master/app/controllers/line_items_controller.rb
* Without being logged in to *any* account, can you increase the quantity in the line items for Account A's order?
* Can you destroy *all* `LineItem` instances in the system?
* Take a look at https://github.com/jmejia/store_engine/blob/master/app/controllers/carts_controller.rb
* How can you manipulate other users' carts through the `update` action?

## Attribute Injection

Attribute Injection is the second most common security vulnerability in Rails applications. While Rails is not at fault, it is fair to say that applying common Rails patterns without understanding the ramifications causes the vulnerabilities.

### Theory

You generally create forms in Rails using the `form_for` helper. Within that form you specify some attributes and the types of input fields that you want. Then, the controller action that receives the data often looks like this:

```ruby
def update
  @order = Order.find(params[:id])

  if @order.update_attributes(params[:order])
    redirect_to @order, notice: 'Order was successfully updated.'
  else
    render action: "edit"
  end
end
```

#### Mass-Assignment

When your controller makes use of the `.new`, `.create`, or `#update_attributes` methods, you're using a feature named mass-assignment. It allows these methods to take in a hash of attribute/value pairs and updates each of these attributes on the model.

This is incredibly convenient because you don't have to go through and run a setter for every attribute. If mass-assignment didn't exist, the above action would look something like this:

```ruby
def update
  @order = Order.find(params[:id])
  @order.status = params[:order][:status]
  @order.confirmation = params[:order][:confirmation]

  if @order.save
    redirect_to @order, notice: 'Order was successfully updated.'
  else
    render action: "edit"
  end
end
```

If the `@order` has many attributes, this can be many stupid lines of code as well as one more piece that has to change whenever the makeup of the `Order` model changes.

#### The Problem with Mass-Assignment

The issue with mass-assignment is the hash that's passed into the method might contain attributes you weren't intending to change. Nefarious users can easily edit the HTML form to rename, change, or add input fields and values. Users sending `POST` requests using CURL or a Ruby client could send any parameter combo they can dream up.

What if that `@order` had a `paid` attribute, a boolean, that specified whether or not the order had been paid for. If the model allows mass-assignment to any attribute, the *the nefarious user could mark their own item as paid without paying anything.*

#### At the Model Layer

The solution in Rails versions 1-3 (but different in Rails 4), is to declare in the model which attributes are "accessible" to mass-assignment:

```ruby
class Order < ActiveRecord::Base
  attr_accessible :status, :confirmation

  #...
end
```

Calling the `attr_accessible` method defines a "white list" of attributes which may be passed in through mass-assignment. If any other attribute is passed in it will just be ignored.

#### Strong Parameters in Rails 4

One of the most significant changes in Rails 4 is the addition of the "Strong Parameters" functionality.

The technique involves calling the `require` and/or `permit` methods on the `params` within the controller action. For instance, the `update` action from `OrdersController` starts like this:

```ruby
def update
  @order = Order.find(params[:id])

  if @order.update_attributes(params[:order])
    redirect_to @order, notice: 'Order was successfully updated.'
  else
    render action: "edit"
  end
end
```

Then we add a call to `permit` in the `update_attributes`:

```ruby
def update
  @order = Order.find(params[:id])

  if @order.update_attributes(params[:order].permit(:status, :confirmation))
    redirect_to @order, notice: 'Order was successfully updated.'
  else
    render action: "edit"
  end
end
```

Now only the keys `:status` and `:confirmation` are allowed to pass through to the model's `update_attributes` method. Often this whitelisting of allowable attributes is shared across multiple actions, so developers will pull it out to a method:

```ruby
def update
  @order = Order.find(params[:id])

  if @order.update_attributes(order_attributes)
    redirect_to @order, notice: 'Order was successfully updated.'
  else
    render action: "edit"
  end
end

private

def order_attributes
  params[:order].permit(:status, :confirmation)
end
```

Which has the exact same functionality. If you're working on a Rails 3 app and would like to add the Strong Parameters functionality, you can [add it through a gem](https://github.com/rails/strong_parameters).

### Executing the Attack

This vulnerability can often be attacked right in the browser or via a non-browser HTTP client.

#### In the Browser

Most modern web browsers offer some kind of "Web Inspector" that allows a user to look at the HTML, CSS, and JavaScript that are creating the page.

What most users don't realize, though, is that the document is usually modifiable. In Chrome, for instance, you can double click any element in the inspector and change it's name, value, CSS class, etc. This functionality can be very valuable when you're building and debugging a web application.

But it also makes an easy way to exploit attribute injection vulnerabilities. You can browse to a normal form provided by the application, then go into the inspector to:

* Look for hidden fields and modify them
* Change the name of fields to other attributes that you think might be vulnerable
* Add or delete fields

Then submit the form and see what happens!

#### HTTP Client

If you can shape your own requests then the attack is even easier.

* Look at the documentation or the existing web form to determine which fields are required
* Construct a request with those fields
* Add in the vulnerable fields
* Submit the request and observe the results

### Recognizing Vulnerabilities

Finding these vulnerabilities can be done by dropping down to the model code and poking around, looking for `attr_accessible` lines which list attributes that shouldn't be changeable by a user.

For instance:

```ruby
class Order < ActiveRecord::Base
  attr_accessible :status, :user_id, :total_cost, :confirmation

  #...
end
```

The `:user_id` on that order is a giant red flag, not to mention the `:total_cost`. These are things that a user of the app should *not* be able to alter.

### Preventing the Attack

Your `attr_accessible` calls should **only** have attributes which you're ok with the user changing _at any time_. Anything that's even remotely "secure" or "important" should not be accessible through mass-assignment.

The consequence is that you'll have to do more explicit assignments. A few extra lines of code, though, is worth the security.

### Things to Remember

* Just because an attribute isn't in your form *doesn't* mean it's safe
* Anything listed by your `attr_accessible` is probably changable through the `create` and `edit` actions
* If you want to assign attributes that need more security, use explicit assignment like this: `model.attribute_name = X`

### Exercise

#### Model Research 1

* Take a look at https://github.com/jmejia/store_engine/blob/master/app/models/order.rb
* Notice the fields in the `attr_accessible` call
* Look at https://github.com/jmejia/store_engine/blob/master/app/controllers/orders_controller.rb to confirm that mass assignment is used for the `update` action

#### Data Setup 1

* Create an order under Account A

#### Exploit 1

* Submit a request to `update` that changes the `total_cost` of the order to $0.00
* Submit a request to `update` that moves the order from Account A to Account B

#### Model Research 2

* Take a look at https://github.com/jmejia/store_engine/blob/master/app/models/user.rb
* Notice the fields in the `attr_accessible` call
* Look at https://github.com/jmejia/store_engine/blob/master/app/controllers/users_controller.rb to confirm that mass assignment is used for the `create` action

#### Exploit 2

* Create a new user, Account C, who is automagically an Administrator in the system.
* Try visiting the admin tools and everything should work as expected

## Cross-Site Scripting

Cross-Site Scripting, often abbreviated (XSS), is generally an attack that is more dangerous to your users than to you.

### Theory

Any time you render HTML to the user, it could (and likely does) contain JavaScript code anywhere in the markup. If an attacker can embed JavaScript content into your page, then they can likely cause chaos for your users.

If an attacker can execute arbitrary JavaScript on your user's machine, some of the things they might be able to do include:

* Redirect them to any site on the web (phishing, porn, advertising, etc)
* Access other sites they are currently logged in to (Facebook, Amazon, etc)
* Rewrite your page to submit forms or other data to them
* Falsely ask them to verify their username and password, then send the results to the attacker

### Executing the Attack

How would an attacker "embed content" on your site? It can happen multiple ways:

* Maybe you allow user comments on a blog, and they can just embed `<script>` tags right in the text.
* Maybe you allow user reviews, then they embed the tags there
* Maybe they exploit one of the other weaknesses in order to edit the content you think is "safe" (created by an trusted user, like an admin)

### Preventing the Attack

Rails 3 made this vulnerability *much* less prevalent. You actually have to go out of your way to open the vulnerability.

In Rails 3, all strings output in the view template are considered "untrusted". Untrusted strings are run through an HTML-escaping processor.

Say your nefarious user creates a comment on your blog with this content:

```plain
This article is stupid! <script>alert("BOOM!")</script>
```

When it's run through the escaping filter, before output to the user, it becomes `This article is stupid! &lt;script&gt;alert("BOOM!")&lt;/script&gt;`

The `<` character is converted to a `&lt;` for "less than" and `>` becomes `&gt;` for "greater than". The web browser will not recognize this as JavaScript without the proper tags, so the attack is stopped.

### Opening Vulnerabilities

But you can open yourself up to the vulnerability with good intentions. Perhaps you decide that commenters on your website should be able to use formatting tags (like bold and italic) and embed links. So in the view template you replace:

```erb
<p><%= comment.body %></p>
```

With the more permissive:

```erb
<p><%= comment.body.html_safe %></p>
```

Or, the same effect by using the `raw` helper:

```erb
<p><%= raw comment.body %></p>
```

Now a nefarious user can embed any JavaScript they want with just a comment.

### Things to Remember

* Only use `.html_safe` or `raw` with **great caution** and **never** on untrusted user content
* If you want content to have embedded HTML, you should probably use something like https://github.com/rgrove/sanitize to limit it to certain tags

### Exercise

Unfortunately, our sample application doesn't have a vulnerability built in. Yay?

#### Creating a Vulnerability

In the previous section, we figured out that (as an attacker) we could create our own admin user. So with that user we can modify any of the trusted content on the site.

It is *very reasonable* that the site authors might have considered product names to be trusted data because they're written by the administrators.

* Open `app/views/products/_sm_product.html.erb`
* Change line 8 from `<%= p.name %>` to `<%= p.name.html_safe %>`
* Run the server and navigate to `http://localhost:3000/categories/2`
* The page should appear normal

#### Embedding The Attack

Either using your admin account created earlier, (or the built in admin account "demoXX+steve@jumpstartlab.com" / "password")...

* Visit the admin page at `/admin`
* In the "Product Management" section, go to the "Grub" tab and find "Rations"
* Edit the name to be `Rations <script>alert("BOOM!")</script>`
* Visit/refresh `http://localhost:3000/categories/1` and you should see a JavaScript alert box saying "BOOM!"

Now your user is exploited.

## References

* [Rails Security Guide](http://guides.rubyonrails.org/security.html)
