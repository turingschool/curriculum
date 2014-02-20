---
layout: page
title: Remote Authentication with OmniAuth
section: Authentication & Authorization
---

There have been about a dozen popular methods for authenticating Rails applications over the past five years. 

As we learn more about constructing web applications there is a greater emphasis on decoupling components. It makes a lot of sense to depend on an external service for our authentication, then that service can serve this application along with many others.

{% include custom/sample_project_follow_along.html %}

## Why OmniAuth?

The best application of this concept is the [OmniAuth](https://github.com/intridea/omniauth). 

It's popular because it allows you to use multiple third-party services to authenticate, but it is really a pattern for component-based authentication. You could let your users login with their Twitter account, but you could also build your own centralized OmniAuth provider that authenticates all your company's apps. Maybe you can use the existing LDAP provider to hook into ActiveDirectory or OpenLDAP, or make use of the Google Apps interface.

Better yet, OmniAuth can handle multiple concurrent strategies, so you can offer users multiple ways to authenticate. Your app is just built against the OmniAuth interface, those external components can come and go.

## Getting Started with OmniAuth

The first step is to add the dependency to your `Gemfile`:

```ruby
  gem "omniauth", "~> 0.3.0"
```

Then run `bundle` from your terminal.

### Rack Middleware

OmniAuth runs as a "Rack Middleware" which means it's not really a part of our app, it's a thin layer between our app and the client. 

#### Create the Initializer

To instantiate and control the middleware, we need an initializer. You'd  create `/config/initializers/omniauth.rb` and add the following:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, "EZYxQSqP0j35QWqoV0kUg", "IToKT8jdWZEhEH60wFL94HGf4uoGE1SqFUrZUR34M4"
end
```

What is all that?  Twitter, like many API-providing services, wants to track who's using it. They accomplish this by distributing API accounts. 

Specifically, they use the OAuth protocol which requires a *consumer key* and a *consumer secret.*  If you want to build an application using the Twitter API you'll need to [register and get your own credentials](https://dev.twitter.com/apps)

### Accessing the Remote Service

You need to restart your server so the initializer is run and the middleware loaded. The default URL pattern is:

```
http://your.com/auth/provider
```

Where `provider` could be `twitter`, `facebook`, or any other registered OmniAuth provider. We'll experiment using Twitter.

In your browser go to http://127.0.0.1:8080/auth/twitter and, after a few seconds, you should see a Twitter login page. 

Login to Twitter using any account, then you should see a Routing Error from your application. If you’ve got that, then things are on the right track.

<div class='note'>
If you get to this point and encounter a 401 Unauthorized message there is more work to do. You’re probably using your own API key and secret. You need to go into the settings on Twitter for your application, and add http://127.0.0.1 as a registered callback domain. Also add http://0.0.0.0 and http://localhost while you're in there. 

Now give it a try and you should get the Routing Error.
</div>

### Handling the Callback

The authentication pattern starts with your app redirecting to the third party authenticator, the third party processes the authentication, then it sends the user back to your application at a *callback URL*. OmniAuth defaults to listening at `/auth/twitter/callback`. 

You'd handle that callback by adding a route in `/config/routes.rb`:

```ruby
get '/auth/:provider/callback', to: 'sessions#create'
``` 

Your router will attempt to call the `create` action of the `SessionsController` when the callback is triggered.

### Creating a Sessions Controller

You can generate a controller at the command line and add a create method like this:

```ruby
class SessionsController < ApplicationController
  def create
    render text: debug request.env["omniauth.auth"]
  end
end
```

Calling `render :text` is a good debugging technique to display plain text as the response. Here you'd see the response body data stored under the `omniauth.auth` key.

### Creating a User Model

Even though we're using an external service for authentication, we'll still need to keep track of user objects within our system. Let's create a model that will be responsible for that data. 

As you saw, Twitter gives us a ton of data about the user. What should we store in our database?  The minimum expectations for an OmniAuth provider are three things:

* `provider` - A string name uniquely identifying the provider service
* `uid` - An identifying string uniquely identifying the user within that provider
* `name` - Some kind of human-meaningful name for the user

Let's start with just those three in our model. From your terminal:

{% terminal %}
$ rails generate model User provider:string uid:string name:string
{% endterminal %}

Then update the database with `rake db:migrate`.

### Creating Actual Users

How you create users might vary depending on the application. For our demonstration, we'll allow anyone to create an account automatically just by logging in with the third party service.

Hop back to the `SessionsController`. The controller should have as little domain logic as possible, so we'll proxy the User lookup/creation from the controller down to the model like this:

```ruby
  def create
    @user = User.find_or_create_by_auth(request.env["omniauth.auth"])
  end
```
 
Now the `User` model is responsible for figuring out what to do with that big hash of data from Twitter. Open the model file and add this method:

```ruby
  def self.find_or_create_by_auth(auth_data)
    user = self.find_or_create_by_provider_and_uid(auth_data["provider"], auth_data["uid"])
    if user.name != auth_data["user_info"]["name"]
      user.name = auth_data["user_info"]["name"]
      user.save
    end    
    return user
  end
```

To walk through that step by step...

* Look in the users table for a record with this `provider` and `uid` combination. If it's found, you'll get it back. If it's not found, a new record will be created and returned
* Compare the user's `name` and the `name` in the auth data. If they're different, either this is a new user and we want to store the name or they've changed their name on the external service and it should be updated here. Then save it.
* Either way, return the `user`

Now, back to `SessionsController`, we need to save the logged in user's id in the session. And let's add a redirect action to send them to the `articles_path` after login:

```ruby
  def create
    @user = User.find_or_create_by_auth(request.env["omniauth.auth"])
    session[:user_id] = @user.id
    redirect_to articles_path, notice: "Logged in as #{@user.name}"
  end
```

Now visit `/auth/twitter` and you should eventually be redirected to the Articles listing.

### UI for Login/Logout

That's exciting, but now we need links for login/logout that don't require manually manipulating URLs. Anything like login/logout that you want visible on every page goes in the layout.

Open `/app/views/layouts/application.html.erb` and you'll see the framing for all our view templates. Let's add in the following:

```erb
  <div id="account">
    <% if current_user %>
      <span>Welcome, <%= current_user.name %></span>
      <%= link_to "logout", logout_path, id: "logout" %>
    <% else %>
      <%= link_to "login", login_path, id: "login" %>
    <% end %>
  </div>
```

If you refresh your browser that will crash for several reasons.

### Accessing the Current User

It's a convention that Rails authentication systems provide a `current_user` method to access the user. 

Let's create that in our `ApplicationController` with these steps:

* Underneath the `protect_from_forgery` line, add this: 

    ```ruby
    helper_method :current_user
    ```

* Just before the closing `end` of the class, add this:

    ```ruby
      private
        def current_user
          @current_user ||= User.find(session[:user_id]) if session[:user_id]
        end  
    ```

By defining the `current_user` method as private in `ApplicationController`, that method will be available to all our controllers because they inherit from `ApplicationController`. 

In addition, the `helper_method` line makes the method available to all our views. Now we can access `current_user` from any controller and any view!

#### Progress Check

Refresh the page in your browser and you'll move on to the next error:

```
undefined local variable or method `login_path'.
```

### Convenience Routes

Just because we're following the REST convention doesn't mean we can't also create our own named routes. The view snippet we wrote is attempting to link to `login_path` and `logout_path`, but our application doesn't yet know about those routes.

Open `/config/routes.rb` and add two custom routes:

```ruby
  get "/login" => redirect("/auth/twitter"), as: :login
  get "/logout" => "sessions#destroy", as: :logout  
```

The first line creates a path named `login` which redirects to the static address `/auth/twitter` which will be intercepted by the OmniAuth middleware. The second line creates a `logout` path which will call the `destroy` action of our `SessionsController`.

With those in place, refresh your browser and it should load without error.

### Implementing Logout

Our login works great, but we can't logout!  When you click the logout link it's attempting to call the `destroy` action of `SessionsController`. Let's implement that.

* Open `SessionsController`
* Add a `destroy` method
* In the method, erase the session with:

    ```ruby
    session[:user_id] = nil
    ```
    
* Redirect to the `root_path` with the notice `"Goodbye!"`
* Define a `root_path` in your router like this: 

    ```ruby
    root to: "article#index"
    ```

### Wrapup

At that point, your login/logout system should be working!

That's just the beginning with OmniAuth. Now, you could choose to add other providers by adding API keys to the initializer and properly handling the different routes.

You might try out some of these:

* A Devise and OmniAuth powered Single-Sign-On implementation: https://github.com/joshsoftware/sso-devise-omniauth-provider
* RailsCast on combining Devise and OmniAuth: http://asciicasts.com/episodes/236-omniauth-part-2

## References

* OmniAuth core API documentation: https://github.com/intridea/omniauth
* OmniAuth wiki: https://github.com/intridea/omniauth/wiki
