# Authorization with CanCan

Authorization is an important aspect to most any application. As a system, it is put in place to determine whether the current user has the permission to perform the requested action. Based on this, it typically happens after a user is authenticated, but before a request is processed, during regular application flow. The important question to ask is, is the user allowed to do what they're trying to do?

## Getting Started

When considering implementing an authorization system in Rails, there are two libraries that have really taken the stage. The first, [Declarative Authorization](https://github.com/stffn/declarative_authorization) has been around since 2008. [CanCan](https://github.com/ryanb/cancan), the second, was inspired by `decl_auth` and created by Ryan Bates of Railscasts. It provides an intuitive interface to define your authorization rules and integrates into Rails seamlessly. As it has become the most popular authorization library, the following tutorial pertains to its implementation.

### Setup

To get started, let's add `cancan` to the `Gemfile`.

```ruby
# CURRENT FILE :: Gemfile

gem "cancan"
```

Now, to install the gem, run `bundle install` from the command line.

### The Current User

It is convention in a Rails application to implement a definition of `current_user` in your controllers. This should simply return an instance of the `User` model that is currently active in the session. `CanCan` is expecting `current_user` to be available for its controller includes to work, which are setup automatically in descendants of `ActionController::Base` once the `CanCan` gem is required.

## Creating Abilities

To define an application's authorization rules, we'll think in terms of abilities. For example, is the `current_user` able to update their own information? Typically abilities are defined on a per model basis and can get as specific as you need.

### Generate the Ability File

As of version 1.5, `CanCan` includes a generator to create our `Ability` file for Rails 3 applications. It is placed in the `app/models` director and is where all of your ability definitions will live. To execute the generator, run the following from the command line: `rails generate cancan:ability`.

### Defining Abilities

`CanCan` provides a succint DSL for defining abilities. Let's dive in and look at a simple example:

```ruby
# CURRENT FILE :: app/models/ability.rb

# Our Ability class is just a plain old ruby object
class Ability

  # Add in CanCan's ability definition DSL
  include CanCan::Ability

  def initialize( user )

    # Handle the case where we don't have a current_user i.e. the user is a guest
    user ||= User.new

    # Define a few sample abilities
    can    :manage , Foo
    cannot :manage , Bar
    can    :read   , Baz , released: true

  end

end
```

The `CanCan` generator will provide the structure for your Ability class. At a basic level then, all you need to do is implement the constructor. Here we can see a few things...

* As is recommended in the `CanCan` documentation, the case where a `current_user` is `nil` is handled.
* A user can perform all actions on the `Foo` model. This is function of the `:manage` incantation.
* Users cannot perform any action on the `Bar` model.
* Users can read instances of the `Baz` model where `baz.released` is `true`

### Building Roles

By default, `CanCan` does not make any assumptions about whether you will need roles in your application and what they might be. In most cases though, they will probably be necessary. For example, and at their most basic, roles might encompass whether a user is an administrator or not.

To begin implementing roles, let's consider a simple `User` model.

```ruby
# CURRENT FILE :: app/models/user.rb

class User < ActiveRecord::Base

  # User::Roles
  # The available roles
  Roles = [ :admin , :default ]

  # A simple helper to query the user's role
  #
  # Example:
  #   user.is? :admin
  #
  def is?( requested_role )
    self.role == requested_role.to_s
  end

end
```

As you can see, the `User::Roles` array lists the different roles that a `User` might be. Since we want to persist a user's role, we'll add a `String` field called `role` to the `User` model via a database migration.

The job of managing users will typically belong to an admin. Based on our previous example, an adminstrative interface in our application could provide the facility for a change to the value in a user's `role` field.

<div class="opinion">
  Since user roles will be managed typically only by an administrator, the `role` field on the `User` model is a good example of a field to leave out of the class' `attr_accessible` declaration. Instead, that field would be changed on a user in the appropriate controllers only if the `current_user` was authorized and if the parameter was presesnt. Alternately, in Rails 3.1, the `attr_accessible` definitions in your models can now be grouped by `role`. For example...

```ruby
# CURRENT FILE :: app/models/user.rb

class User

  # The attributes accessible by any user
  attr_accessible :name , :email

  # The attributes accessible by admins
  attr_accessible :name , :email , :role , :as => :admin

end
```

For more information, see the [official Rails guide](http://edgeguides.rubyonrails.org/security.html#countermeasures).
</div>

Now, to define the abilities of an `:admin`, we should revisit the previously created `Ability` class.

```ruby
# CURRENT FILE :: app/models/ability.rb

# Our Ability class is just a plain old ruby object
class Ability

  # Add in CanCan's ability definition DSL
  include CanCan::Ability

  def initialize( user )

    # Handle the case where we don't have a current_user i.e. the user is a guest
    user ||= User.new

    # Define User abilities
    if user.is? :admin
      can :manage , User
    else
      can :read , User
    end

  end

end
```

If a user is an `:admin`, they'are allowed to manage any user. Otherwise, users can only read other users. By using the simple `User#is?` method, we can expressively determine the role of a user.

See the `CanCan` wiki for more information on [Defining Abilities](https://github.com/ryanb/cancan/wiki/Defining-Abilities) and [Role Based Authorization](https://github.com/ryanb/cancan/wiki/Role-Based-Authorization).

## Checking Abilities

Once your application's abilities are defined, they can be checked throughout the app. This is useful in controllers for checking and acting on abilities. Also, in your application views, ability checks can be used to control the UI.

### Can?

The `can?` check uses your ability definitions to determine whether a user action is allowed.

```rhtml
<%= link_to "New User" , new_user_path if can? :create , User %>
```

#### Cannot?

Alternatively, the `cannot?` helper is available and checks whether a user action is NOT allowed.

```rhtml
<% if cannot? :destroy , @user %>
  <span class="permission-message">You aren't allowed to delete this user.</span>
<% end %>
```

### Load and Authorize Resource

`CanCan` provides numerous helpers for use at the controller level. One that is particularly useful is `load_and_authorize_resource`. Calling this at a class level in a controller will automatically load the model and authorize the requested action.

```ruby
# CURRENT FILE :: app/controllers/users_controller.rb

class UsersController < ApplicationController
  load_and_authorize_resource
end
```

### Handling Authorization Failure

When using `load_and_authorize_resource`, or even calling `authorize!` manually, an authorization failure will raise a exception. The way to handle these exceptions is by writing a `rescue_from` block in your base controller.

```ruby
# CURRENT FILE :: app/controllers/application_controller.rb

class ApplicationController < ActionController::Base

  # Catch all CanCan errors and alert the user of the exception
  rescue_from CanCan::AccessDenied do | exception |
    redirect_to root_url , :alert => exception.message
  end

end
```

The exception passed in to the `rescue_from` block should contain the data necessary to inform the user of the error.

## Usage Patterns

### Dealing with Complexity

As your application grows beyond a few models, ability definitions can
quickly become complex. At first, a solution such as the one described
in the last section of the `CanCan` [Role Based
Authorization](https://github.com/ryanb/cancan/wiki/Role-Based-Authorization)
wiki page can be useful. Even then, the `ability.rb` file can grow
unruly at fast pace.

At a certain point, there are few options to keep ability definitions
under control:

* Roll your own solution to split ability definitions in to multiple files by role or model.
* Use a `CanCan` extension gem such as [cantango](https://github.com/kristianmandrup/cantango) or [role_up](https://github.com/quickleft/role_up)
* Check out [declarative_authorization](https://github.com/stffn/declarative_authorization)

### Testing Abilities

Writing tests against your ability definitions at the unit level, as
opposed to through functional or integration tests, can be a huge
benefit for your codebase. There are wonderful matchers available for
`RSpec` in `CanCan`. Check out the [testing wiki
page](https://github.com/ryanb/cancan/wiki/Testing-Abilities) for code
examples.

## References

* [CanCan Wiki](https://github.com/ryanb/cancan/wiki)
* [Declarative Authorization](https://github.com/stffn/declarative_authorization)
* [Security Countermeasures Rails Guide](http://edgeguides.rubyonrails.org/security.html#countermeasures)

