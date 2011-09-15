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

As mentioned earlier, when the `devise` generator was run `devise_for :users` was added to the top of the routes file.  This single line adds a whole slew of devise routes (check out `rake routes | devise`).

The instructions after the `devise:install` generator was run included a step to specify a `root` route to some action in the application.  This is necessary, because after Devise successfully authenticates a user it redirects them to the `root` path.  If we want users to go to `/articles` after signing in then we'd add the following route:

```ruby
root :to => 'articles#index'
```

## Using Authentication

( you want to trigger authentication at the controller )

### Using Before Filters

( devise provides `:authenticate_user!` )
( if just protecting a few controllers, put it in the controller itself )

### Example: `ArticlesController`

( use the ArticlesController from JSBlogger )
( add a before filter to trigger auth )
( but this will cover all methods, oh no! )
( add an `:except => [:show, :index]` so those are public accessible)

### Checking User Status

( you can use `user_signed_in?` to see if there is a user currently signed in )
( you can use `current_user` to fetch the actual user object )
( saying `if current_user` is probably more common than using `user_signed_in` )

### Configuring Email

( if you want devise to send email, you need to setup options for action_mailer )
( and they're probably different per environment )
( show a typical setup for development.rb and production.rb )

( NOTE: Client had a specific question: is it possible to have devise email an auto-generated password, similar to what Google Apps does? So you'd register an email address, then go to the email to get your password or a one time token. I think the email_verifiable module might do this...? )

## Customizing Views

( devise uses views built into the gem by default )
( you can override them )

### Generating Views

( `rails generate devise:views` )
( explain the output )

### Customizations

( Give some ideas for things they might customize )

## References

* https://github.com/plataformatec/devise
