---
layout: page
title: Local Authentication with Devise
section: Authentication & Authorization
---

Devise uses a modular approach to cherry pick common authentication functionality.  You can have a simple authentication tool that checks the users credentials and lets them into the site or not, or you can pick and choose additional authentication features such as:

* password reset via email
* locking users out after a number of failed attempts
* email activation being required before a new account is allowed to sign in
* timing users out after a period of inactivity

In this section we will learn how to use Devise to authenticate the user against a local database.

{% include custom/sample_project_follow_along.html %}

## Setup

To setup Devise, add `gem "devise"` to the `Gemfile` and run `bundle`.

### Create the Initializer

Devise comes with a number of important generators. To start off, we need to use the devise installer which will create an initializer, locales file, and output some additional instructions:

{% terminal %}
$ rails g devise:install
create  config/initializers/devise.rb
create  config/locales/devise.en.yml
{% endterminal %}

`config/initializers/devise.rb` is well documented with the various configuration options Devise offers.

### Create Users

Next, we need to create a model and table for local authentication, typically `User`:

{% terminal %}
$ rails g devise User
invoke  active_record
create    db/migrate/20110915050159_devise_create_users.rb
create    app/models/user.rb
invoke    rspec
create      spec/models/user_spec.rb
insert    app/models/user.rb
route  devise_for :users
{% endterminal %}

The `devise` generator creates a migration, user model, user spec, and adds `devise_for :users` to `config/routes.rb`.  

Open the migration and model files, and you'll find the optional components are commented out.

The `confirmable` feature requires that the user confirms their email address, by clicking a link included in an email sent to the address provided, before they are allowed to sign in.

To enable the `confirmable` feature:

1. add `:confirmable` to the list of options following `devise` in `app/models/user.rb`
2. uncomment the `t.confirmable` line in the migration
3. uncomment the `t.add_index :users, :confirmation_token, unique: true` line in the migration

After the desired configuration changes have been made it's time to `rake db:migrate` the database and create the new `users` table.

### Routes

As mentioned earlier, when the `devise` generator was run, `devise_for :users` was added to the top of the routes file. This single line adds many routes which you can display by running `rake routes | grep devise` on the command line.

#### Root Route

The instructions displayed with the `devise:install` generator mentioned specifying a `root` route to some action in the application.  This is necessary, because after Devise successfully authenticates a user it redirects them to the `root` path.  

If we want users to go to `/articles` after signing in then we'd add the following route:

```ruby
root to: 'articles#index'
```

## Using Authentication

The next step will be to turn on authentication at the controller level so that users that have not signed in yet are forced to do so before having access to the site.

### Using Before Filters

Blocking unauthenticated users from restricted pages is best done with a `before_filter`.  Devise provides the `:authenticate_user!` filter to force them to the `new_user_session_path` route if the user isn't signed in.

If the site requires a user to be signed in for every page, this filter can be added to `ApplicationController`, since all controllers inherit from it.  If only a few controllers are being protected from unrestricted access then the filter can be added in the necessary controllers.

### Example: `ArticlesController`

We'll add this to the top of `ArticlesController` in order to force a user to sign in before viewing the articles:

```ruby
 # app/controllers/articles_controller.rb
class ArticlesController < ApplicationController
  before_filter :authenticate_user!
  ...
end
```

#### Try It Out

Now restart the server and reload the root page.  

You will be redirected to `/users/sign_in`. Clicking the `Sign up` link will let you register a new account, and after logging in, you will be able to see the `/articles` pages again.

#### Scoping Authentication

It's more likely that we only want to force authentication for a few actions in `ArticlesController`. 

We can allow unauthenticated access to the index and show actions, while still restricting the rest, by making the following change to `articles_controller.rb`:

```ruby
before_filter :authenticate_user!, except: [:show, :index]
```

Here we tell devise to only authenticate against actions other than `show` and `index`.  Now, users that haven't signed in can still read the articles.

### Checking User Status

Users can now sign into the site but they don't have a link to sign out.  Applications typically have some sort of header to give users that are signed in various options.  Devise provides two convenient methods for checking the status of the user:

* `user_signed_in?` - returns true if a user is currently signed in
* `current_user` - returns the `User` model of the currently signed in user or nil if they are not authenticated

Though `if user_signed_in?` is available, it's more common to use `if current_user` to check for a currently logged in user.

#### Creating a Sign Out Link

In our layout, let's add a header for users to sign out if they are signed in, or to show a sign in link if they are not:

```erb
<div id="account">
  <% if current_user %>
    <span>Welcome, <%= current_user.email %></span>
    <%= link_to "Sign out", destroy_user_session_path, method: :delete %>
  <% else %>
    <%= link_to "Sign in", new_user_session_path %>
  <% end %>
</div>
```

### Configuring Email

Many useful features of devise involve sending the user an email, like password reset and confirmation. If using any of these features is desired, you will need to set the options for `action_mailer`.  These settings may vary between development and production, so they should be set in the appropriate file under `config/environments/`.

The most important setting is `default_url_options` so that links contained in emails sent from devise include full, valid paths to your application.

```ruby
# config/environments/development.rb
#...
config.action_mailer.default_url_options = { host: 'localhost:3000' }
#...
```

In the development environment, when an email, is sent its contents will be output in the log file.  

Here is an example email that devise sent because `:confirmable` is turned on:

```text
Sent mail to test@email.com (9ms)
Date: Thu, 15 Sep 2011 14:33:47 -0400
From: sample@example.com
Reply-To: sample@example.com
To: test@email.com
Message-ID: <4e72450b6e06c_8239827d5d5c26152@hostname.local.mail>
Subject: Confirmation instructions
Mime-Version: 1.0
Content-Type: text/html;
 charset=UTF-8
Content-Transfer-Encoding: 7bit

<p>Welcome test@email.com!</p>

<p>You can confirm your account through the link below:</p>

<p><a href="http://localhost:3000/users/confirmation?confirmation_token=zbwhuGwdtjgDqF5Md9iz">Confirm my account</a></p>
```

For more information about configuring `ActionMailer`, check out the "ActionMailer Basics" Rails Guide at http://guides.rubyonrails.org/action_mailer_basics.html

## Customizing Views

You're able to use devise's default sign in page at `/users/sign_in`, even though there is no `app/views/users/` folder.  Where are these views coming from?  Devise includes the requisite controllers and views in the gem.

If you wish to change the text in the views or messages, some of this can be done by changing the locales file that was generated at `config/locales/devise.en.yml`. But if further customization is necessary, you can generate real view templates.

### Generating Views

One of the generators devise provides is `devise:views` which will copy the view files so they may be overridden. 

{% terminal %}
$ rails g devise:views
invoke  Devise::Generators::SharedViewsGenerator
create    app/views/devise/mailer
create    app/views/devise/mailer/confirmation_instructions.html.erb
create    app/views/devise/mailer/reset_password_instructions.html.erb
create    app/views/devise/mailer/unlock_instructions.html.erb
create    app/views/devise/shared
create    app/views/devise/shared/_links.erb
invoke  form_for
create    app/views/devise/confirmations
create    app/views/devise/confirmations/new.html.erb
create    app/views/devise/passwords
create    app/views/devise/passwords/edit.html.erb
create    app/views/devise/passwords/new.html.erb
create    app/views/devise/registrations
create    app/views/devise/registrations/edit.html.erb
create    app/views/devise/registrations/new.html.erb
create    app/views/devise/sessions
create    app/views/devise/sessions/new.html.erb
create    app/views/devise/unlocks
create    app/views/devise/unlocks/new.html.erb
{% endterminal %}

Devise lists all of the view files that were generated and it now uses these views instead of the ones built in with the gem.  

### Customizations

The Devise project is well documented, so take some time to explore the project's [README](https://github.com/plataformatec/devise#readme) as well as the project's [wiki pages](https://github.com/plataformatec/devise/wiki/_pages).  The wiki pages and [Extensions](https://github.com/plataformatec/devise/wiki/Extensions) will provide good examples of some customizations that are possible.

Here are just a few examples of possible ways to customize devise:

* changing the names of the devise urls
* having multiple roles (admins, users, etc)
* changing the password requirements
* authenticating with a username instead of an email

### Alter Registration Process to Set Password When Confirming Account

Let's walk through the steps for customizing the registration process:

* Do not make the user specify a password when registering (only provides an email address)
* User will be sent a confirmation email with a link
* User will set the password on the confirmation page

*NOTE* This exercise is based a [Two Step Signup with Devise](http://blog.devinterface.com/2011/05/two-step-signup-with-devise).

#### Remove Password Fields from Registration Form

Having already generated the views, let's begin by removing the password fields from the registration form `app/views/devise/registrations/new.html.erb`, which are the following lines:

```erb
<div><%= f.label :password %><br />
<%= f.password_field :password %></div>

<div><%= f.label :password_confirmation %><br />
<%= f.password_field :password_confirmation %></div>
```

#### Allow New User Without a Password

Next we'll modify the validation rules to allow no password to be specified when a user is created.  This can be done by an initializer: 

```ruby
# config/initializers/devise_registration_without_password.rb
module Devise
  module Models
    module Validatable
      def password_required?
        false
      end
    end
  end
end
```

This will allow a new user to be created without specifying a password, so the form we altered in the previous step should now work.

#### Add Route for Special Confirmation

Next, alter the devise route in `config/routes.rb` to override the controller that is used for confirming a user's account:

```ruby
devise_for :users, controllers: { confirmations: "confirmations" } do
  put "confirm_user", to: "confirmations#confirm_user"
  get "confirmation", to: "confirmations#show"
end
```

1. Adding the `:controllers` option allows us to override what controller devise will use for certain modules.  In this case we're specifying that the `:confirmations` controller should use our customized `confirmations_controller.rb` instead of the default.
2. The `confirm_user` path is added for a special action that we'll use to confirm a new user.

#### Add `Show` Action for `ConfirmationsController`

Then we set up the controller action for the page the user will come to after clicking the confirmation link in their email.  This goes in `app/controllers/confirmations_controller.rb`:

```ruby
class ConfirmationsController < Devise::ConfirmationsController
  def show
    @user = User.find_by_confirmation_token(params[:confirmation_token])
  end
end
```

#### Create New Confirmation Page

Now we need a view for `"confirmations#show"`.  Here's `app/views/confirmations/show.html.erb`:

```erb
<h2>Set Password for <%= @user.email %></h2>

<%= form_for(@user, as: resource_name, url: confirm_user_path) do |f| %>
  <%= devise_error_messages! %>

  <%= f.hidden_field :confirmation_token %>

  <div><%= f.label :password %><br />
  <%= f.password_field :password %></div>

  <div><%= f.label :password_confirmation %><br />
  <%= f.password_field :password_confirmation %></div>

  <div><%= f.submit "Confirm user" %></div>
<% end %>

<%= render "devise/shared/links" %>
```

This view will be nearly identical to the original registration page, but with the following changes:

1. The form posts to our `confirm_user` route
2. Added the `:confirmation_token` hidden field
3. Removed the email field and added it to be displayed in the header
4. Changed submit button text

#### Setup `confirm_user` Custom Action

Now back in `app/controllers/confirmations_controller.rb` let's add the `confirm_user` action:

```ruby
class ConfirmationsController < Devise::ConfirmationsController
  #...

  def confirm_user
    @user = User.find_by_confirmation_token(params[:user][:confirmation_token])
    if @user.update_attributes(params[:user]) and @user.password_match?
      @user = User.confirm_by_token(@user.confirmation_token)
      set_flash_message :notice, :confirmed
      sign_in_and_redirect("user", @user)
    else
      render :show
    end
  end
end
```

Again, we look up the user by the `confirmation_token` that was passed via the hidden field in our form.  Next, we try to save the new password by calling `update_attributes` and checking if the password matches (we'll add this method to the `User` model next).  

If the password matches then we'll proceed with the typical devise confirmation process, otherwise we'll render `show` so that the user sees the validation errors.

#### Add `password_match?` to User Model

The `password_match?` method will ensure the password has been provided and matches, otherwise it will add the appropriate validation errors:

```ruby
class User < ActiveRecord::Base
  #...
  def password_match?
    self.errors[:password] << 'must be provided' if password.blank?
    self.errors[:password] << 'and confirmation do not match' if password != password_confirmation
    password == password_confirmation and !password.blank?
  end
end
```

#### Test It Out

After restarting the Rails server you should now be able to sign up as a new user, click the confirmation link that shows up in the log, and set the password at the confirmation step.

## References

* https://github.com/plataformatec/devise
* https://github.com/plataformatec/devise/wiki/_pages
* Two Step Signup with Devise: http://blog.devinterface.com/2011/05/two-step-signup-with-devise
* ActionMailer Basics Rails Guide: http://guides.rubyonrails.org/action_mailer_basics.html
