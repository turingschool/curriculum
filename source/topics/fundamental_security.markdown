---
layout: page
title: Fundamental Rails Security
sidebar: true
---

## Background

Security is hard. It just takes a mistake in one little place and your entire application can be compromised. Many major applications with big teams of experienced engineers have had security problems at one time or another (Github, LinkedIn, Twitter, etc). 

Security is a challenge you can never completely solve, but you can avoid the easy mistakes.

### Obscurity

Many of the attacks below will appear to necessitate knowledge of the code behind the application. *Don't be fooled by security through obscurity*. Referring to your "admin" users by the name "admn" might increase the time until your vulnerabilities are found, but it's a delay tactic not prevention.

#### All Source Code Will Be Public

Even for closed-source projects, you should assume that a malicious user has complete access to your source code. You must construct your systems so they can't break in, regardless of knowledge.

Is that far fetched? Imagine you build a successful software business. Could one of these happen?

* An employee loses their laptop and, oops, they had been meaning to turn on FileVault but forgot. Now your complete source code is out there.
* Your trusted source-control hosting service (Github, Beanstalk, etc) has a wide-spread security issue of their own, allowing anyone to see, pull, and change your code. [That won't happen, right?](https://github.com/blog/1068-public-key-security-vulnerability-and-mitigation)
* You attend a conference, do some work while listening to presentations, and forget to use your secure VPN connection for pushing code. You just broadcast it to the entire local network, congrats.

All of the attacks we'll look at can be either prevented or mitigated, even when the attacker has perfect knowledge of your system.

## Privledge Escalation

Probably the most common, easy to exploit, and dangerous security vulnerability is "Privledge Escalation".

### Theory

When building web applications there are a plethora of available authentication libraries. In Rails, we often rely on Devise, OmniAuth, or Sorcery.

#### Authentication

It's important to remember that authentication answers the question "Are you who you say you are?" You've claimed to be user with email address `admin@example.com`, but do you know the secret which only I (the system) and that user know -- their password?

Answering that question leaves you with a clear answer: yes or no.

#### Authorization

After the user is known, the more important question is that of authorization: "Are you allowed to do what you're trying to do?"

Can you see that data? Can you delete that record? After authentication has verified your identity, authorization must decide whether you are authorized to execute the desired action.

**Too often, systems do not implement an authorization strategy**. By relying on only authentication, the system has only two known roles:

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
* If a "User 2" logs in, they can see an manipulate their data
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

Most often when class methods are used in controllers they are passed in only data from `params`. This is a vulnerability.

### Preventing the Attack

90% of the time, the fix is simple. You just need to scope the operation within the `current_user`. Instead of:

```
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

```
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

This fix probably necessitates no change at the model level, assuming that a `User` expresses a `has_many` relationship with the `Order`.

#### Why It Works

In the first snippet, we run this line:

```
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

* Be vary suspicious of any class method in a controller.
* Nefarious users can access any public action and pass in any combiation of parameters they want. Just because there's no link or form doesn't mean an action can't be exploited.
* Scope all queries off of a domain object, like the current user.
* Be careful with your order of operations -- don't change any data until you've successfully found the specified record.

### Exercise

#### Prepare Tooling

You'll want to be able to create raw HTTP requests without the limitations of the browser. Here are some options:

##### Faraday Gem

If you'd like to work from IRB, consider using the [Faraday Gem](https://github.com/lostisland/faraday) which will allow you to create and send requests, then read responses in a friendly Ruby style.

##### OS X GUI

If you'd prefer a graphical interface for tweaking and sending HTTP requests, try [Graphical HTTP Client](https://itunes.apple.com/us/app/graphicalhttpclient/id433095876?mt=12) from the Apple App Store.

##### CURL

[You can do everything through CURL](http://superuser.com/questions/149329/what-is-the-curl-command-line-syntax-to-do-a-post-request), if you really feel like it. 

#### Setup the Code

* Clone https://github.com/jmejia/store_engine
* Get it setup to run locally:

```bash
$ bundle
$ rake db:migrate && rake db:seed
$ bundle exec rails server
```

#### Setup Accounts and Data

* Create a first user account and login ("Account A")
* Place an order using Account A
* Logout
* Create a second user account and login ("Account B")
* Open an incognito window and login to the site using the admin account "demoXX+steve@jumpstartlab.com" and password "password"
* View the order you just placed in the admin interface

#### Begin the Exploit

* Take a look at https://github.com/blairand/store_engine/blob/master/app/controllers/addresses_controller.rb
* In the window where you're logged in as "Account B", can you figure out how to display Account A's address?
* Can you edit that address? Delete it?
* Take a look at https://github.com/jmejia/store_engine/blob/master/app/controllers/orders_controller.rb
* Can you figure out how to change the `total_cost` of Account A's order to $0.00?
* Can you completely erase Account A's order?

## Attribute Injection

### Theory

### Executing the Attack

### Recognizing Vulnerabilities

### Preventing the Attack

### Things to Remember

### Exercise

## Cross Site Scripting

### Theory

### Executing the Attack

### Recognizing Vulnerabilities

### Preventing the Attack

### Things to Remember

### Exercise

## References

* [Rails Security Guide](http://guides.rubyonrails.org/security.html)