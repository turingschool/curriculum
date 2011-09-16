# Local Authentication with Devise

( Devise is used to build authentication into the app locally, as opposed to OmniAuth which uses an external service )

It uses modular approach to cherry pick functionality, so you can have a simple authentication tool that just checks the users credentials and lets them into the site or not.  Or you can pick and choose additional authentication features, such as:

* password reset
* locking users out after a # of failed attempts
* email activation being required before a new account is allowed to sign in
* timing users out after a period of inactivity

In this section we will learn how to use Devise to authenticate the user against a local database.  It is possible to use Devise to authenticate against an external service, but we'll get to that in another section.  The local version will utilize a table to store the user's information and to authentiate against.

## Setup

To setup Devise, add `gem "devise"` to the `Gemfile` and run `bundle`.

### Create the Initializer

Devise comes with a few generators, one of which is an installer which will create an initializer, locales file, and output some additional instructions:

```text
$> rails g devise:install
  create  config/initializers/devise.rb
  create  config/locales/devise.en.yml
```

`config/initializers/devise.rb` is well documented with the various configuration options Devise offers.

### Create Users

The next step is to create a model and table for local authentication (the model is typically called `User`):

```text
$> rails g devise User
  invoke  active_record
  create    db/migrate/20110915050159_devise_create_users.rb
  create    app/models/user.rb
  invoke    rspec
  create      spec/models/user_spec.rb
  insert    app/models/user.rb
  route  devise_for :users
```

The `devise` generator creates a migration, user model, user spec, and adds `devise_for :users` to `config/routes.rb`.  If certain features like the ones listed at the beginning are desired there may be some changes to make in the model and the migration.  The available options are commented out in the generated files, so it's fairly easy to guess which ones to add in for a desired feature.

For instance, if the `confirmable` module is desired so that when the user signs up for a new account an email will be sent containing a link that the user must click before they will be able to sign in, then the following steps should be followed:

1. add `:confirmable` to the list of options following `devise` in `app/models/user.rb`
2. uncomment the `t.confirmable` line in the migration
3. uncomment the `t.add_index :users, :confirmation_token, :unique => true` line in the migration

After the desired configuration changes have been made it's time to `rake db:migrate` the database so the new `users` table is created.

### Routes

As mentioned earlier, when the `devise` generator was run `devise_for :users` was added to the top of the routes file.  This single line adds a whole slew of devise routes (check out `rake routes | grep devise` on the command line).

The instructions after the `devise:install` generator was run included a step to specify a `root` route to some action in the application.  This is necessary, because after Devise successfully authenticates a user it redirects them to the `root` path.  If we want users to go to `/articles` after signing in then we'd add the following route:

```ruby
root :to => 'articles#index'
```

## Using Authentication

The next step will be to turn on authentication at the controller level so users that haven't signed in yet are forced to do so before having access to the site.

### Using Before Filters

Preventing unauthenticated users from seeing pages they shouldn't be able to is done with a `before_filter`.  Devise provides the `:authenticate_user!` filter to force them to the `new_user_session_path` route if the user isn't signed in.

If the site requires a user to be signed in for every page this filter can be added to `ApplicationController` since all controllers inherit from it.  If only a few controllers are being protected from unrestricted access then the filter can be added in the necessary controllers.

### Example: `ArticlesController`

We'll add this to the top of `ArticlesController` to force a user to sign in before viewing the articles:

```ruby
 # app/controllers/articles_controller.rb
class ArticlesController < ApplicationController
  before_filter :authenticate_user!
  ...
end
```

Now restart the server and reload the site.  You will now be redirected to `/users/sign_in`.  Clicking the `Sign up` link will let you register a new account, and after logging in you will now be able to see the `/articles` pages again.

However, we may want to allow users outside of the system to view articles without registering for an account, so let's allow public access to the articles index and viewing an individual article.  Make the following change to `articles_controller.rb`:

```ruby
  before_filter :authenticate_user!, :except => [:show, :index]
```

Here we tell devise to only authenticate against actions other than `show` and `index`.  Now users that haven't signed in can still read the articles.

### Checking User Status

Users can now sign into the site but they don't have a link to sign out.  Applications typically have some sort of header to give users that have signed in various actions.  Devise provides two convenience methods for checking the status of the user:

* `user_signed_in?` - returns true if a user is currently signed in
* `current_user` - returns the `User` model of the currently signed in user or nil if they are not authenticated

Using `if current_user` tends to be the more common thing to see rather than `if user_signed_in?`.  In our layout let's add a header for users to sign out if they are logged in, otherwise show a sign in link:

```ruby
<% if current_user %>
  <%= link_to "Sign out", destroy_user_session_path, :method => :delete %>
<% else %>
  <%= link_to "Sign in", new_user_session_path %>
<% end %>
```

Note that by default the method on the sign out link must be `:delete`.  If you wish a normal get request to be allowed to the sign out link then change the `sign_out_via` configuration option in `config/initializers/devise.rb` to allow a sign out via `GET`:

```ruby
  config.sign_out_via = :get
```

If this change is made then after restarting the server the `:method => :delete` option can be removed from the sign out link.

### Configuring Email

Most of the useful features of devise involve sending the user an email (password reset, confirmation, etc), so if any of these are desired you'll need to set options for action_mailer.  These settings are likely different between various environments, so the settings should be made in the appropriate environment file under `config/environments/`.

The key change (which is mentioned in the output after running `rails g devise:install`) is setting the `default_url_options` so links contained in emails sent from devise include full, valid paths to your application.

```ruby
 # config/environments/development.rb
...
config.action_mailer.default_url_options = { :host => 'localhost:3000' }
...
```

In the development environment, when an email is sent its contents will be output in the log file.  An example email that devise sent due to the `:confirmable` feature after signing up as a new user looks like:

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

Your production mail settings will likely require additional configuration since it may integrate with a 3rd party service to send the mail, or use postfix on the host running the application.

## Customizing Views

Running the application you'll see that we were able to use devise's default sign in page at `/users/sign_in` even though there is no `app/views/users/` folder.  Where are these views coming from?  Devise includes the requisite controllers and views built into the gem.

If you wish to simply change the text in the views or messages, some of this can be done by changing the locales file that was generated at `config/locales/devise.en.yml`.  If further customization of the views is required you can change the views to suit your needs.

### Generating Views

One of the generators devise provides is `devise:views` which will copy the view files so they may be overridden. (*HINT:* Pass the `-h` flag to any generator command to see the usage and available options).

```text
$> rails g devise:views
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
```

Devise lists all of the view files that were generated and it now uses these views instead of the ones built in with the gem.  If you wanted to alter the structure of the sign in page then changing `app/views/devise/sessions/new.html.erb` is now all that's necessary.

### Customizations

The Devise project is well documented, so take some time to explore the project [README](https://github.com/plataformatec/devise#readme) as well as the [wiki pages](https://github.com/plataformatec/devise/wiki/_pages).  The wiki pages and [Extensions](https://github.com/plataformatec/devise/wiki/Extensions) will provide good examples of some customizations that are possible.

Here are just a few examples of possible ways to customize devise:

* changing names of the devise urls
* having multiple roles (admins, users, etc)
* changing the password requirements
* authenticating with a username instead of an email

### Alter Registration Process to Generate a Password

[TODO: Walk through customizing devise to register without user specifying password]
(Use http://blog.devinterface.com/2011/05/two-step-signup-with-devise)

( NOTE: Client had a specific question: is it possible to have devise email an auto-generated password, similar to what Google Apps does? So you'd register an email address, then go to the email to get your password or a one time token. I think the email_verifiable module might do this...? )

## References

* https://github.com/plataformatec/devise
* https://github.com/plataformatec/devise/wiki/_pages
* http://blog.devinterface.com/2011/05/two-step-signup-with-devise
