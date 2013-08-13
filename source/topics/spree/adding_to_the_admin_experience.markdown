---
layout: page
title: Adding to the Admin Experience
section: Building Applications with Spree
---

[ to integrate ]

## Adding to the Admin Experience

The Spree admin page suits most purposes but we have some ideas that we want
to override or replace to the existing experience. First we will examine the
current layout and examine how we can append additional features.

The current admin experience offers us the ability to list the current users
in the system. When we view this page we only have a list of email addresses
of our users. It is hard to tell from this who are the admins of our system.

To view if a user is an admin we need to access the details of each user. It
would nice if we could include a simple flag or highlight if the user is an
admin from the index page. This will allow us to at a glance see the admins
within our system.

* Overriding View Templates
* Ruby Objects

### Discussion:

* Open Classes
* Monkeypatching
* `class_eval` and `instance_eval`

## Refining our Additions

The Spree admin experience looks great with the addition that we have made.
Now it is time to refine the experience and extract it into an extension.

* Deface

[ / to integrate ]

The Spree admin page suits most purposes but we have some ideas that we want
to override or replace to the existing experience. First we will examine the
current layout and examine how we can append additional features.

The current admin experience offers us the ability to list the current users
in the system. When we view this page we only have a list of email addresses
of our users. It is hard to tell from this who are the admins of our system.

To view if a user is an admin we need to access the details of each user. It
would nice if we could include a simple flag or highlight if the user is an
admin from the index page. This will allow us to at a glance see the admins
within our system.

### Finding Where To Start

The hardest part about Spree is understanding where to get started.

#### Finding Our Way by Logging

From our earlier explorations we learned that how to use the terminal to find
the controller and the action that we were requesting.

* Visit `http://localhost:3000/admin/users`

This should show our one admin user in the system "spree@example.com".

* View the terminal results

```
Started GET "/admin/users" for 127.0.0.1 at 2013-08-09 12:36:41 -0500
Processing by Spree::Admin::UsersController#index as HTML
```

#### Finding Our Way by `rake routes`

Using the logs is a great way to find our where our requests are going. Some
people may want to get an overral sense of where all the routes are heading
and not constantly be referring to the logs.

Rails provides a [utility](http://guides.rubyonrails.org/routing.html#inspecting-and-testing-routes)
to help assist with laying out all the possible routes within your application.

* Run `rake routes`

The results should be a huge list of all the urls and their associated
controller and action. Within the list we would need to find a route
that matches the format "/admin/users".

```
admin_users GET    /admin/users(.:format)                                                       spree/admin/users#index
```

The right hand column shows the filepath that defines the controller. In this
case we are interested in finding a controller with the path:
`spree/admin/users_controller`. Within that controller we are looking for the
index action.

#### Opening The Appropriate Gem

The request is handled by the index action of the
`Spree::Admin::UsersController`. We can likely find that class within one of the
various spree gems included in our project.

* Run `bundle open spree_backend`.

Spree as a convention keeps almost all of of the admin controllers and views in
the **spree_backend** gem. So if you are viewing an admin page you usually will
want to immediately come to this gem.

However, searching through the source you are not going to find the
`app/controllers/spree/admin/users_controller.rb` in this gem. That is because
user management is handled by the gem **spree_auth_devise**.

* Run `bundle open spree_auth_devise`

For the current project this is not an actual gem. It is a git repository cloned
locally that Bundler allows for us to manage as a gem.

* Open `app/controllers/spree/admin/users_controller.rb`

Notice that the name of the controller is mirrored in the path. This is similar
to the requirement when working with Java libraries. This is a convention
enforced by Rails.

```
def index
  respond_with(@collection) do |format|
    format.html
    format.json { render :json => json_data }
  end
end
```

The index action responds with a `@collection` of user objects. By default the
index action will render a template within the views directory that has a path
composed with the name of the controller and the action.

In this case the **index** action renders the template:
`app/views/spree/admin/users/index.html.erb`.

### Overriding the Current Admin View

Similar to when we were debugging, we could start to edit the controller and
the template within the current gem. However this could lead to serious
problems because the source we are editing is not within our own project.

The first way we can override an existing view is to create a parallel copy of
that template within our own project.

* Within our Spree project create `app/views/spree/admin/users/index.html.erb`
  and add the following html:

```html
<h1>USERS</h1>
```

* View `http://localhost:3000/admin/users`

Our original users index page should completely disappear and be replaced with
our new, feature-less page.

Rails will first look locally for the template file, if it does not find it, it
will use the template file defined within the Spree Engine. This is a pretty
drastic replacement strategy.

### Adding a Stubbed Admin Flag to the View

Though we chose a more drastic approach to replacing the entire view. Sometimes
it is easier to work with the entire view before we know what portion of the
view we want to replace with more surgical tools like [deface](https://github.com/spree/deface).


* Copy the source of the original into `app/views/spree/admin/users/index.html.erb`.

* Add the new table header to display whether the user is an admin

```
<!-- other html data -->
<th><%= sort_link @search,:email, Spree.t(:user), {}, {:title => 'users_email_title'} %></th>
<th>Admin?</th>
<!-- other html data -->
```

* Add the new table row to display if the user is an admin

```
<!-- other html data -->
<td class='user_email'><%=link_to user.email, object_url(user) %></td>
<td>Yes</td>
<!-- other html data -->
```

This should display that every user is an Admin. We did not actually ask each
user if they are an admin, we simply assumed they all were and displayed it.

Displaying stubbed data like this is a useful strategy to take as it is often
easier to focus a single aspect of your implementation. Here we were able to
complete the view representation of that data.

### Replacing the Stubbed Data with Real Data

The stubbed data was great to help us focus on our view implementation. It is
now time to replace that stubbed data with the actual state of the each user.

The hard part about ruby is understanding what methods exist on a given object.
How do we know what methods already exist on the user object?

We are going to explore some ways to determine the state of the user object.

#### Debugging

The most accurately way to determine what the object is and what methods it
has is to ask the object in the midst of execution.

We could employ similar debugging techniques that we employed previously. This
time we will add our debugger statement within our view that we have overridden.

* Open `app/views/spree/admin/users/index.html.erb` and add the following
  source within the view within the loop that iterates over the users:

```html+erb
<!-- other html and erb tags -->
  <tbody>
  <% @users.each do |user|%>
    <% debugger %>
    <!-- other html and erb tags -->
  <% end %>
  </tbody>
<!-- other html and erb tags -->
```

* Within the current debugging session enter the command `irb`

We now an a complete irb session where we can interogate the `user` instance
that was defined in this block. We could have likewise used the `p` or `print`
command. Sometimes when you are doing quite a bit of exploration it is easier
to simply start an irb session.

* Enter the command `user`

```
=> #<Spree::User id: 1, encrypted_password: "5e405f697605774637dfeb1fe083ec0a0d7efc365c0c0f3a509...", password_salt: "wR52GbvL2G7R4sxjU4Gf", email: "spree@example.com", remember_token: nil, persistence_token: nil, reset_password_token: nil, perishable_token: nil, sign_in_count: 2, failed_attempts: 0, last_request_at: nil, current_sign_in_at: "2013-08-09 17:21:28", last_sign_in_at: "2013-08-02 21:06:26", current_sign_in_ip: "127.0.0.1", last_sign_in_ip: "127.0.0.1", login: "spree@example.com", ship_address_id: nil, bill_address_id: nil, authentication_token: nil, unlock_token: nil, locked_at: nil, reset_password_sent_at: nil, created_at: "2013-08-02 21:05:36", updated_at: "2013-08-09 17:21:28", spree_api_key: "6daeb8cd93dafbd6a40295d5e9169f16ca9a89a240e41cd9", remember_created_at: nil>
```

We see that the user is in fact a `Spree::User` and from the output we are
able to inspect some of the colums that the user maintains. However we need to
know if it has particular methods.

* Enter the command `user.methods`

This will display an array of the available methods, represeted as symbols, on
the user object. Because it is an array of symbols we may wish to sort them to
make our lives easier for browsing.

* Enter the command `user.methods.sort`

The list is in alphabetical order and now will allow us to browse all the
methods in a saner fashion. However, there are still more than a terminal
screen worth of methods. So it might be easier to search for a particular
method.

* Enter the command `user.methods.grep(/admin/)`

Ruby allows you to search through array with the
[grep](http://rubydoc.info/stdlib/core/Enumerable#grep-instance_method) which
takes a regular expression as a parameter. In our case we are looking for any
method that has the word admin anywhere within it.

The results should contain one method: `admin?`

If we knew the name of the method we would have simply asked the object if
it would respond to the particular method with the name.

* Enter the command `user.respond_to?(:admin?)`

The result of this should be true, knowing now that the user object does in
fact have the method `admin?`.

* Enter the commadn `exit`

* Enter the command `continue`

* Remove the `debugger` line from the view template

#### Reviewing Source Code

A not as accurate method to determine the state of an object is to review the
source code.

If we review the source code in the controller action all we saw was an
instance variable named `@collection` that we assumed had an array of
`Spree::User` objects. So we are making an assumption.

Rails controller, as a convention, will usually manage a collection of models
which share a similar name. In this case, the `UsersController` manages
`User` objects.

However this convention that is not enforced by Rails like the file naming
conventions of controllers.

From the previous exercise we know that the object is a `Spree::User` so let's
review that source:

* Open, within the **spree_auth_device** gem, open `app/spree/models/user.rb`.

The `Spree::User` includes an external module, defines multiple different
attributes and several association relationships.

Scrolling past those we find the `admin?` method defined which is helper method
that simply asks if the user has the the spree role of 'admin'.

#### Reviewing Tests

Probably the most responsible way to determine the state of an object is to
reivew the tests or specifications associated with that object.

* Open, within the **spree_auth_device** gem, open `spec/models/user_spec.rb`.

One of the first specs defined for the `Spree::User` is the `admin?` method.

#### Using our real data

We now know that a user object has a helper method to determine if it is an
admin. We can use that within our view template to represent the actual state
of the users.

* Open `app/views/spree/admin/users/index.html.erb` and update the stubbed
  data to call the `admin?` method on the user object.

```
<td><%= user.admin? %></td>
```

### Understanding how `@collections` is set

While reviewing the `Spree::Admin::UsersController` source we skipped over how
the `@collection` variable was set within the index action. It seems to have
happened as if by magic. Lets take some time to understand what is happening.

On first examination it looks as though the `@collection` should be nil as it
is used without it ever being set. There is no code within the `index` action
that sets that value so we need to examine the various **before_filters** and
see if they apply.

[Before Filters](http://guides.rubyonrails.org/v3.2.13/action_controller_overview.html#filters) are methods that take place prior to
the execution of the action. By default, when a before filter is defined it
will affect all actions within the controller and any sub-classes of that
controller. They can be scoped to only particular actions.

Within the `UsersController` there are two before filters defined.

* Open `app/controllers/spree/admin/users_controller.rb`:

```ruby
before_filter :check_json_authenticity, :only => :index
before_filter :load_roles, :only => [:edit, :new, :update, :create, :generate_api_key, :clear_api_key]
```

The first filter is `:check_json_authenticity` which applies only to the
**action**. Since we are calling the index action, this filter definitely acts
before our action is called. So this filter may be setting up the `@collections`
value. Though it does not seem likely based on the name.

The second filter `:load_roles` applies in several other circumstances except
for the **index** action so it does apply.

So our only solid lead is the `:check_json_authenticity` filter. When we search
through the remainder of the controller we are unable to find any mention of
a method defined with this name. So where is this before filter defined?

Ruby often times favors composition over inheritance, hence why you might often
see an `include MODULENAME` or `extend MODULENAME` within a class, Rails
controllers still often use inheritance to share functionality between
controllers.

Our `UsersController` is a subclass of the `ResourcesController` so any filters
or methods defined within that controller are also present within the current
controller. So it is time to find that controller.

* Run `bundle open spree_backend`

* Open the file `app/controllers/spree/admin/resource_controller.rb`

Here again we are unable to find any methods defined with the name
`check_json_authenticity`. However, we did find a new before filter defined.

```ruby
before_filter :load_resource, :except => [:update_positions]
```

The method `load_resource` has a much more promising name. So lets forget our
search for `check_json_authenticity` and instead focus on this method. Looking
through the `ResourceController` we find a method named `load_resource` which
defines several promising leads within it:

```ruby
def load_resource
  if member_action?
    @object ||= load_resource_instance

    # call authorize! a third time (called twice already in Admin::BaseController)
    # this time we pass the actual instance so fine-grained abilities can control
    # access to individual records, not just entire models.
    authorize! action, @object

    instance_variable_set("@#{object_name}", @object)
  else
    @collection ||= collection

    # note: we don't call authorize here as the collection method should use
    # CanCan's accessible_by method to restrict the actual records returned

    instance_variable_set("@#{controller_name}", @collection)
  end
end
```

The initial logic to check for a `member_action?` does not make a lot of sense
to me but the fallback where the collection instance variable is assigned to
the results of the collection method does make sense.

```
@collection ||= collection
```

Lets return to our original `UsersController` class and see if we can find
a method with the name `collection`.

* Open, within **spree_auth_devise** gem, the file
  `app/controllers/spree/admin/users_controller.rb`


Returning to our original `UsersController` there is a protected method defined
with the name `collection`. Within it we can see `@collection` variable set
in various instances based on the details of the request.

So this solves the mystery of how the @collection is set. But within the view
itself we used the variable `@users`. So that leaves us one more mystery.

* Return to the file `app/controllers/spree/admin/resource_controller.rb`

Later after the collection method has been called an instance variable is
set which is based on the name of the current controller.

```
instance_variable_set("@#{controller_name}", @collection)
```

Essentially a Spree `ResourceController` is a controller which manages a
collection of objects. Those objects can be referenced by `@collection` or
by an instance variable based on the controller's name. In the case of our
`UsersController`, the controller name is **users**, and thus the instance
variable has been set.

### Conclusion

We were able to add a new field to our users' index page to allow us to see
if a user is an admin. This at its heart was not a large feature but we
were able to learn a lot about how the Spree source is structured and allowed
to explore several of the controllers and views core to the Spree framework.
