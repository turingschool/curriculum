---
layout: page
title: Authorization with CanCan
section: Authentication & Authorization
---

Authorization is an important aspect to most any application. As a system, it is put in place to determine whether the current user has the permission to perform the requested action. Based on this, it typically happens after a user is authenticated, but before a request is processed. 

The important question to ask is, *is the user allowed to do what they're trying to do*?

## Getting Started

When considering implementing an authorization system in Rails, there are two popular libraries. 

The first, [Declarative Authorization](https://github.com/stffn/declarative_authorization) has been around since 2008. It introduced the idea of a centralized permissions file and a clean DSL for referring to those permissions.

Later, [CanCan](https://github.com/ryanb/cancan), was inspired by DeclarativeAuthorization and created by Ryan Bates of Railscasts. It provides an intuitive interface to define your authorization rules and integrates into Rails seamlessly. 

They're both great choices, but let's look at implementing CanCan.

### Setup

To get started, add `cancan` to the `Gemfile`.

```ruby
gem "cancan"
```

Then run `bundle` from the command line.

### The Current User

It is conventional to implement a helper method named `current_user` in your controllers. It should return an instance of the `User` model that is currently active in the session. 

`CanCan` is expecting `current_user` to be available for its controller includes to work, which are setup automatically in descendants of `ActionController::Base` once the `CanCan` gem is required.

## Creating Abilities

To define an application's authorization rules, we'll think in terms of abilities. For example, is the `current_user` able to update their own information? 

### Generate the Ability File

As of version 1.5, `CanCan` includes a generator to create our `Ability` file for Rails 3 applications. It is placed in the `app/models` directory and is where all of your ability definitions will live. To execute the generator, run the following from the command line: 

{% terminal %}
$ rails generate cancan:ability
{% endterminal %}

### Defining Abilities

`CanCan` provides a succinct DSL for defining abilities. Let's dive in and look at a simple example:

```ruby
# app/models/ability.rb
class Ability

  # Add in CanCan's ability definition DSL
  include CanCan::Ability

  def initialize( user )

    # Handle the case where we don't have a current_user i.e. the user is a guest
    user ||= User.new

    # Define a few sample abilities
    can    :manage , Article
    cannot :manage , Comment
    can    :read   , Tag , released: true
  end
end
```

The `CanCan` generator will provide the structure for your Ability class. At a basic level then, all you need to do is implement the constructor. Here we can see a few things...

* As is recommended in the `CanCan` documentation, the case where a `current_user` is `nil` is handled.
* A user can perform all actions (`:manage`) the `Article` model
* Users cannot perform any actions on the `Comment` model.
* Users can read instances of the `Tag` model where `baz.released` is `true`

### Building Roles

By default, `CanCan` does not make any assumptions about whether you will need roles in your application and what they might be. At their most basic, we could implement administrators and non-administrators.

To begin implementing roles, let's consider a simple `User` model.

```ruby
# app/models/user.rb

class User < ActiveRecord::Base
  attr_accessible :name , :email

  # User::Roles
  # The available roles
  Roles = [ :admin , :default ]

  def is?( requested_role )
    self.role == requested_role.to_s
  end
end
```

As you can see, the `User::Roles` array lists the different roles that a `User` might be. Since we want to persist a user's role, we would add a `String` field called `role` to the `User` model via a database migration.

### Admin Abilities

Now, to define the abilities of an `:admin`, we should revisit the previously created `Ability` class.

```ruby
# app/models/ability.rb
class Ability
  include CanCan::Ability

  def initialize( user )
    user ||= User.new

    # Define User abilities
    if user.is? :admin
      can :manage, Article
    else
      can :read, Article
    end
  end

end
```

If a user is an `:admin`, they're allowed to manage any `Article`. Otherwise, users can only read articles. By using the simple `User#is?` method, we can expressively determine the role of a user.

See the `CanCan` wiki for more information on [Defining Abilities](https://github.com/ryanb/cancan/wiki/Defining-Abilities) and [Role Based Authorization](https://github.com/ryanb/cancan/wiki/Role-Based-Authorization).

## Checking Abilities

Once your application's abilities are defined, they can be checked throughout the app. 

### Can?

The `can?` check uses your ability definitions to determine whether a user action is allowed.

```erb
<%= link_to "New User" , new_user_path if can? :create, User %>
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
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  load_and_authorize_resource
end
```

### Handling Authorization Failure

When using `load_and_authorize_resource` manually, an authorization failure will raise a exception. The way to handle these exceptions is by writing a `rescue_from` block in your base controller.

```ruby
# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base

  # Catch all CanCan errors and alert the user of the exception
  rescue_from CanCan::AccessDenied do | exception |
    redirect_to root_url, alert: exception.message
  end

end
```

The exception passed in to the `rescue_from` block will contain the data necessary to inform the user of the error.

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

### Testing Abilities

Writing tests against your ability definitions at the unit level, as
opposed to through functional or integration tests, can be a huge
benefit for your codebase. There are wonderful matchers available for
`RSpec` in `CanCan`. Check out the [testing wiki
page](https://github.com/ryanb/cancan/wiki/Testing-Abilities) for code
examples.

## Exercises

{% include custom/sample_project.html %}

1. Follow the instructions above to install CanCan and generate the abilities file.
2. Follow the previous Local Authentication tutorial to build authentication using Devise.
3. Define a `role` attribute in your users table. Create one admin and one non-admin user.
4. Define abilities such that the admin can manage an `Article` and a normal user can only read them (using `index` and `show`).
5. Add checks in the view templates to hide links when the user is not permitted to execute the associated action.
6. Use `load_and_authorize_resource` in the `ArticlesController` and remove any unnecessary code in the actions.

## References

* [CanCan Wiki](https://github.com/ryanb/cancan/wiki)
* [Declarative Authorization](https://github.com/stffn/declarative_authorization)
* [Security Countermeasures Rails Guide](http://edgeguides.rubyonrails.org/security.html#countermeasures)

