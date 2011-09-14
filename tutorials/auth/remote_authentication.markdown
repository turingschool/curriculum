# Remote Authentication with OmniAuth

There have been about a dozen popular methods for authenticating Rails applications over the past five years. 

As we learn more about constructing web applications there is a greater emphasis on decoupling components. It makes a lot of sense to depend on an external service for our authentication, then that service can serve this application along with many others.

## Why OmniAuth?

The best application of this concept is the [OmniAuth](https://github.com/intridea/omniauth). It's popular because it allows you to use multiple third-party services to authenticate, but it is really a pattern for component-based authentication. You could let your users login with their Twitter account, but you could also build your own OmniAuth provider that authenticates all your company's apps. Maybe you can use the existing LDAP provider to hook into ActiveDirectory or OpenLDAP, or make use of the Google Apps interface?

Better yet, OmniAuth can handle multiple concurrent strategies, so you can offer users multiple ways to authenticate. Your app is just built against the OmniAuth interface, those external components can come and go.

## Getting Started with OmniAuth

The first step is to add the dependency to your `Gemfile`:

```ruby
  gem "omniauth"
```

Then run `bundle` from your terminal.

OmniAuth runs as a "Rack Middleware" which means it's not really a part of our app, it's a thin layer between our app and the client. To instantiate and control the middleware, we need an initializer. You'd typically create a file `/config/initializers/omniauth.rb` and add the following:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, "EZYxQSqP0j35QWqoV0kUg", "IToKT8jdWZEhEH60wFL94HGf4uoGE1SqFUrZUR34M4"
end
```

What is all that?  Twitter, like many API-providing services, wants to track who's using it. They accomplish this by distributing API accounts. Specifically, they use the OAuth protocol which requires a *consumer key* and a *consumer secret.*  If you want to build an application using the Twitter API you'll need to [register and get your own credentials](https://dev.twitter.com/apps)

### Handling the Callback

The authentication pattern works starts with your app redirecting to the third party authenticator, the third party processes the authentication, then it sends the user back to your application at a *callback URL*. OmniAuth defaults to listening at `/auth/twitter/callback`. 

You'd handle that callback by adding a route in `/app/config/routes.rb`:

```ruby
match '/auth/:provider/callback', :to => 'sessions#create'
``` 

Your router will attempt to call the `create` action of the `SessionsController` when the callback is triggered.

### Creating a Sessions Controller

You can generate a controller at the command line and add a create method like this:

```ruby
class SessionsController < ApplicationController
  def create
    render :text => debug request.env["omniauth.auth"]
  end
end
```

Calling `render :text` is a good debugging technique to display plain text as the response. Here you'd see the response body data stored under the `omniauth.auth` key.

h3. Creating a User Model

Even though we're using an external service for authentication, we'll still need to keep track of user objects within our system. Let's create a model that will be responsible for that data. 

As you saw, Twitter gives us a ton of data about the user. What should we store in our database?  The minimum expectations for an OmniAuth provider are three things:

* *provider* - A string name uniquely identifying the provider service
* *uid* - An identifying string uniquely identifying the user within that provider
* *name* - Some kind of human-meaningful name for the user

Let's start with just those three in our model. From your terminal:

<pre class="console">
  rails generate model User provider:string uid:string name:string
```

Then update the database with @rake db:migrate@.

h3. Creating Actual Users

How you create users might vary depending on the application. For the purposes of our contact manager, we'll allow anyone to create an account automatically just by logging in with the third party service.

Hop back to the @SessionsController@. I believe strongly that the controller should have as little code as possible, so we'll proxy the User lookup/creation from the controller down to the model like this:

```ruby
  def create
    @user = User.find_or_create_by_auth(request.env["omniauth.auth"])
  end
```
 
Now the @User@ model is responsible for figuring out what to do with that big hash of data from Twitter. Open that model file and add this method:

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
* Look in the users table for a record with this provider and uid combination. If it's found, you'll get it back. If it's not found, a new record will be created and returned
* Compare the user's name and the name in the auth data. If they're different, either this is a new user and we want to store the name or they've changed their name on the external service and it should be updated here. Then save it.
* Either way, return the user

Now, back to @SessionsController@, let's add a redirect action to send them to the @companies_path@ after login:

```ruby
  def create
    @user = User.find_or_create_by_auth(request.env["omniauth.auth"])
    redirect_to companies_path, :notice => "Logged in as #{@user.name}"
  end
```

Now visit @/auth/twitter@ and you should eventually be redirected to your Companies listing and the flash message at the top will show a message saying that you're logged in.

h3. UI for Login/Logout

That's exciting, but now we need links for login/logout that don't require manually manipulating URLs. Anything like login/logout that you want visible on every page goes in the layout.

Open @/app/views/layouts/application.html.erb@ and you'll see the framing for all our view templates. Let's add in the following *just below the flash messages*:

```ruby
  <div id="account">
    <% if current_user %>
      <span>Welcome, <%= current_user.name %></span>
      <%= link_to "logout", logout_path, :id => "login" %>
    <% else %>
      <%= link_to "login", login_path, :id => "logout" %>
    <% end %>
  </div>
```

If you refresh your browser that will all crash for several reasons.

h3. Accessing the Current User

It's a convention that Rails authentication systems provide a @current_user@ method to access the user. Let's create that in our @ApplicationController@ with these steps:

* Underneath the @protect_from_forgery@ line, add this: @helper_method :current_user@
* Just before the closing @end@ of the class, add this:

```ruby
  private
    def current_user
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    end  
```

By defining the @current_user@ method as private in @ApplicationController@, that method will be available to all our controllers because they inherit from @ApplicationController@. In addition, the @helper_method@ line makes the method available to all our views. Now we can access @current_user@ from any controller and any view!

Refresh your page and you'll move on to the next error, @undefined local variable or method `login_path'@.

h3. Convenience Routes

Just because we're following the REST convention doesn't mean we can't also create our own named routes. The view snipped we wrote is attempting to link to @login_path@ and @logout_path@, but our application doesn't yet know about those routes.

Open @/config/routes.rb@ and add two custom routes:

```ruby
  match "/login" => redirect("/auth/twitter"), :as => :login
  match "/logout" => "sessions#destroy", :as => :logout  
```

The first line creates a path named @login@ which just redirects to the static address @/auth/twitter@ which will be intercepted by the OmniAuth middleware. The second line creates a @logout@ path which will call the destroy action of our @SessionsController@.

With those in place, refresh your browser and it should load without error.

h3. Implementing Logout

Our login works great, but we can't logout!  When you click the logout link it's attempting to call the @destroy@ action of @SessionsController@. Let's implement that.

* Open @SessionsController@
* Add a @destroy@ method
* In the method, erase the session by setting @session[:user_id] = nil@
* Redirect them to the @root_path@ with the notice @"Goodbye!"@
* Define a @root_path@ in your router like this: @root :to => "companies#index"@

Now try logging out and you'll probably end up looking at the Rails "Welcome Aboard" page. Why isn't your @root_path@ taking affect?

If you have a file in @/public@ that matches the requested URL, that will get served without ever triggering your router. Since Rails generated a @/public/index.html@ file, that's getting served instead of our @root_path@ route. Delete the @index.html@ file from @public@, and refresh your browser.

*NOTE*: At this point I observed some strange errors from Twitter. Stopping and restarting my server, which clears the cached data, got it going again.

h3. Testing...?

We haven't written tests for login/logout. Here are some excuses:

* OmniAuth is tested already, so we don't need to test its functionality
* The code added to our app is relatively simple
* Handling the external service integration in our test suite is challenging

Let's make a mental note that we want to try writing tests for the authentication parts of our app later and move on. We'll get some pieces of it going in the next iteration.

h3. Ship It

Hop over to a terminal and @add@ your files, @commit@ your changes, @merge@ the branch, and @push@ it to Heroku.
