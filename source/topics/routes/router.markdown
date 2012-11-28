---
layout: page
title: The Rails Router
section: Routes
---

The router has, essentially, a simple job. Many Rails programmers, though, consider it a scary place. There's no reason it should be complicated.

The router is controlled through the `config/routes.rb` file. This is one of the first files to open when evaluating someone else's project. Ask questions like these:

* Is it organized, or is it just a junk drawer? Organized is good, messy is bad.
* Are they using a REST style or an old-school RPC style? REST is good, RPC is bad.
* If REST...
  * Are they using many custom actions? A couple custom actions are ok, but if there are many they probably don't understand REST.
  * Are they using nested resources?
* Do they map convenience routes (like `/login` and `/logout`)? If yes, then they've put some energy into the routes, a good sign.

### REST

REpresentational State Transfer, or REST, is a pattern described by Roy Fielding in 2000. It describes a simple model of interacting with "resources" on the web. More information can be found on Wikipedia: http://en.wikipedia.org/wiki/Representational_State_Transfer

#### REST in Rails

Rails 2 was the first framework to bring REST into the mainstream. Now with Rails 3 REST is the de facto standard, using the old RPC approach is passé.

The Rails implementation of the REST pattern defines five essential actions:

* _Listing_ resources accomplished with `index`
* _Displaying_ a single resource accomplished with `show`
* _Deleting_ a single resource accomplished with `destroy`
* _Creating_ a new resource accomplished with `new` and `create`
* _Changing_ a single resource accomplished with `edit` and `update`

Each action is triggered by a unique combination of the *request verb* and the *path*.

#### Request Verb

The HTTP protocol defines the verbs `GET`, `PUT`, `POST`, and `DELETE`. The concept of the protocol is that all resources on the web can be manipulated with these verbs.

The trouble is that browsers don't actually implement all four verbs. Also, until recently, HTML forms only supported `GET` and `POST`. This leads to some complication.

Rails circumvents these limitations by faking the request verbs using a `_method` parameter. If a `POST` request comes in with no `_method`, the router will consider it a `POST`. If a `POST` comes in with the parameter `_method` set to `"delete"`, however, the router will consider it a `DELETE`.

When we look at the routing table we pretend that our server will be handling all four verbs, while in the back of our mind knowing that there's some magic going on.

#### Request Path

The second component the router needs to select the correct action is the request path. Typically these are in one of these forms:

* `/resources/` when referring to the collection
* `/resources/id` when referring to a single element
* `/resources/id/edit` to trigger the edit action, not really a part of REST

RESTful routes combine these paths and verbs in the routing table.

### Controlling the Router

As mentioned above, we control the router through the `config/routes.rb` file. The syntax of this file has changed several times with different versions of Rails which is one reason developers get tripped up -- there is a lot of old documentation out there.

Let's look at the essential techniques.

#### The Routing Table

To understand the router's configuration, the best tool is the routing table. From within a project root, you can display the routing table by running `rake routes` like this:

{% terminal %}
$ rake routes
{% endterminal %}

The table is blank! Obviously this means no routes have yet been defined.

#### Standard REST

Standard RESTful routes are added to `config/routes.rb` like this:

```ruby
MyApp::Application.routes.draw do
  resources :articles
end
```

Now, with that one line added, when I run `rake routes` I see this:

{% terminal %}
$ rake routes
    articles GET    /articles(.:format)          {action:"index",   controller:"articles"}
             POST   /articles(.:format)          {action:"create",  controller:"articles"}
 new_article GET    /articles/new(.:format)      {action:"new",     controller:"articles"}
edit_article GET    /articles/:id/edit(.:format) {action:"edit",    controller:"articles"}
     article GET    /articles/:id(.:format)      {action:"show",    controller:"articles"}
             PUT    /articles/:id(.:format)      {action:"update",  controller:"articles"}
             DELETE /articles/:id(.:format)      {action:"destroy", controller:"articles"}
{% endterminal %}

Declaring that I have resources called _articles_ and following Rails' RESTful pattern adds seven entries to the routing table.

#### Routing Table Entries

An entry in the routes table looks like this:

```bash
articles GET    /articles(.:format)          {action:"index", controller:"articles"}
```

What do those components pieces mean?

* Column 1, here `articles`: This is the "name" of the route. In our application we can use it to generate URLs. There are helpers for `(name)_url` and `(name)_path`. The former generates a full (_absolute_) URL including the protocol and server (like `http://localhost:3000/articles/`). The latter creates a URL relative to the site root (like `/articles/`). The `(name)_path` method (e.g. `articles_path`) is preferred.
* Column 2, here `GET`: The request verb that must be matched to trigger this route
* Column 3, here `/articles(.:format)`: The request path that must be matched to trigger this route. We'll deal with parameters like `:format` in greater detail later.
* Column 4, here `{action:"index", controller:"articles"}`: Which controller and action (or _method_ in the given controller class) will be triggered when the route is matched

If that make sense, you might be confused by the following line in the routes table:

```bash
         POST   /articles(.:format)          {action:"create", controller:"articles"}
```

Where's the name in column 1? The way the table is formatted is for the names to "inherit down". Since this line has no listed name, it inherits the name from the line above it, here `articles`, or for practical purposes `articles_path`. Since the _name_ and _path_ are identical for multiple routes, Rails uses the request verb to distinguish between them.

#### Handling Parameters and Formats

The only other complex part about a table entry is the path. Here are the unique path patterns from the above table:

```bash
/articles(.:format)
/articles/new(.:format)
/articles/:id/edit(.:format)
/articles/:id(.:format)
```

You can think of these patterns as very simplistic regular expressions. When you see a colon then a string of letters, such as `:id` or `:format`, this is a marker which names the data in that position.

Looking at the last pattern in that list (`/articles/:id(.:format)`), it would match a request for `/articles/16` and store `16` into the parameter named `:id`. Within our controller we would access this particular parameter with `params[:id]`.

That last pattern would also match a request for `/articles/16.xml`, storing `16` into the `:id` (_i.e._ `params[:id]`) and `xml` into the parameter `:format` (_i.e._ `params[:format]`). In the pattern, the parentheses around `.:format` tell the router that this part is *optional*.

In `.:format`, the `.` is a literal period character. So `/articles/16.xml` will match, but `/articles/16xml` will not work properly.

_Note_: Though the `:id` is normally a numeric ID corresponding to the unique key in the database, it doesn't have to be. You can build your app to handle other _slugs_ to lookup resources. The router will just blindly put whatever part of the url is in the `:id` spot into the `params[:id]`, then it's up to you (and your controller) to use it correctly.

#### Custom Member Actions

The REST pattern is very constraining, and that's a good thing. When developers first start with REST they want to add custom actions for just about everything. _Resist this temptation!_

The O'Reilly book [RESTful Web Services](https://www.amazon.com/dp/0596529260/ref=as_li_ss_til?tag=jumplab-20&camp=213381&creative=390973&linkCode=as4&creativeASIN=0596529260&adid=0CZ82H545FP6ERNMQJDV&) does an _excellent_ job of explaining how to design resources to follow the REST pattern. If you're struggling with RESTful design, read this book!

<div class="opinion">
<p>It is my opinion that anything we add in a custom action should be available using a standard REST action. For instance, a typical example for a content management system would be the act of publishing. Assume that we have resources <code>articles</code> and at the data layer we're storing a boolean value named <code>published</code>.</p>

<p>This data value should be accessible in the form used for both the <code>create</code> and <code>edit</code> actions. But, for convenience, we want to add a "PUBLISH!" button to our <code>index</code> page. That way our administrators could easily publish articles from the <code>index</code> without going into the <code>edit</code> form.</p>

<p>This kind of augmentation is a great use of a custom route. It's not replacing <code>edit</code> or doing something that should be handled in another resource, it's adding an easy way to access something that's already there.</p>
</div>

A _member action_ will work on just a single resource, a single article, as opposed to the collection of all articles. We'd modify our `routes.rb` like this:

```ruby
MyApp::Application.routes.draw do
  resources :articles do
    member do
      put 'publish'
    end
  end
end
```

We're passing a block into the `resources` method. That block calls the `member` method and pass it another block. That block calls the `put` method with the string `publish`. The effect is that we build a route to recognize a `PUT` verb to a member path.

Why use the `PUT` verb? If you're going to change data you should use a `PUT` or a `POST`. Since this `publish` action is creating a simplification of the `edit`/`update`, it makes sense to use the same verb that would have been used by `update` -- `PUT`.

Run `rake routes` to see the details and you'd get this entry:

```bash
publish_article PUT    /articles/:id/publish(.:format) {action:"publish", controller:"articles"}
```

This looks just like the path for the `update` action except for the `/publish` on the end of the pattern. When this entry is matched the router will trigger the `publish` action in `ArticlesController`. To reference this path, we'd use the helper `publish_article_path` which needs the ID number as a parameter (_e.g._ `publish_article_path(16)`).

#### Custom Collection Routes

Even more rare are custom actions on a collection of resources. Let's say, for the sake of example, that we decided to create a `publish_all` action.

We'd start by modifying the `routes.rb` like so:

```ruby
MyApp::Application.routes.draw do
  resources :articles do
    member do
      put 'publish'
    end

    collection do
      put 'publish_all'
    end
  end
end
```

We call the `collection` method which takes a block, and in that block again call the `put` method and give it the string `publish_all`. Run `rake routes` and we'd see a new route like this:

```bash
publish_all_articles PUT    /articles/publish_all(.:format) {action:"publish_all", controller:"articles"}
```

It can be used by calling the `publish_all_articles_path` helper with no parameter and would trigger the `publish_all` action in `ArticlesController`.

#### Nested Resources

Nested resources sound like a great idea because they can build up beautiful URLs. For instance, let's say our articles are going to have comments. For an article with ID `16` we might want to list the comments with this URL:

```text
http://localhost:3000/articles/16/comments
```

To create this, we _nest_ the `comments` resource inside the `articles` like below:

```ruby
MyApp::Application.routes.draw do
  resources :articles do
    member do
      put 'publish'
    end

    collection do
      put 'publish_all'
    end

    resources :comments
  end
end
```

Then run `rake routes` and you'll see seven new routes show up:

{% terminal %}
    article_comments GET    /articles/:article_id/comments(.:format)          {action:"index", controller:"comments"}
                     POST   /articles/:article_id/comments(.:format)          {action:"create", controller:"comments"}
 new_article_comment GET    /articles/:article_id/comments/new(.:format)      {action:"new", controller:"comments"}
edit_article_comment GET    /articles/:article_id/comments/:id/edit(.:format) {action:"edit", controller:"comments"}
     article_comment GET    /articles/:article_id/comments/:id(.:format)      {action:"show", controller:"comments"}
                     PUT    /articles/:article_id/comments/:id(.:format)      {action:"update", controller:"comments"}
                     DELETE /articles/:article_id/comments/:id(.:format)      {action:"destroy", controller:"comments"}
{% endterminal %}

Going back to our example, we could now call `article_comments_path(16)` to generate the URL `/articles/16/comments`. It works!

<div class="opinion">
<p>That being said, every time I use nested resources I regret it. I almost always end up ripping them out later.</p>

<p>Imagine we record the user who posts the comment. Then you want to browse all comments by a certain user with ID <code>15</code> across articles. What URL would you go to? You'll end up building <code>/comments?user=15</code>, a normal un-nested resource. Now you've got both the nested version and the un-nested version, sets of helpers for <code>article_comments_path</code> and <code>comments_path</code>, and things get confusing quickly.</p>

<p>Instead, knowing that one day I'll want <code>/comments?user=15</code>, I prefer to handle both listings at the non-nested route. Instead of <code>/articles/16/comments</code>, I'll use <code>/comments?article=16</code>. It's not as pretty, but it's simple, follows REST, and has a lot of flexibility.</p>
</div>

### Non-RESTful Routes

Using a non-RESTful approach is not recommended, but you can do it if the need arises.

In `routes.rb` you'd call the `match` method and define a pattern like this:

```ruby
MyApp::Application.routes.draw do
  match 'articles/:id' => 'articles#show'
end
```

That would work for triggering just the `show` action for the given ID. Or, to go all in, you can use the this pattern:

```ruby
match ':controller(/:action(/:id(.:format)))'
```

That will take the controller, action, and ID from the URL. This is a really bad plan. First, it gives you no structure and allows you to write actions with whatever naming conventions you come up with. It also makes all controller actions trigger-able with a GET request.

#### The Dangers of `GET`

Imagine you write a Wiki using this non-RESTful route. Pages have delete links, but they have a JavaScript pop-up that says "Are you sure you want to delete?" and you trust your users. So it seems ok for now, right?

Then a Google spider comes along, it ignores JavaScript, and clicks every link on your page. Including your delete links. Goodbye all content! This has happened before. Don't let it happen to you!

### Route Priority

Rails' router will use the first route it matches, ignoring all of the others.  If you have multiple route definitions that could match a given request, put the more general route below the more specific.

### Special Routes

Often a few _special_ routes are helpful when developing a customer-facing application.

#### Type-able URLs

When an app supports authentication, you might add routes like this:

```ruby
MyApp::Application.routes.draw do
  resources :sessions
  match '/login' => 'sessions#new', as: 'login'
  match '/logout' => 'sessions#destroy', as: 'logout'
end
```

There are still the normal RESTful routes for sessions, but now there are the additional convenience routes `/login` and `/logout`. In addition, the `:as` parameter gives them a name to use with the helper. In your app you can now refer to `login_path` and `logout_path` in addition to `new_session_path`. Run `rake routes` and it'd show these:

{% terminal %}
 login  /login(.:format)        {controller:"sessions", action:"new"}
logout  /logout(.:format)       {controller:"sessions", action:"destroy"}
{% endterminal %}

#### Root Route

What should the user see when they go to the root of your site? This trips up many newcomers.

The critical step 1 is to delete the `public/index.html` file. If a file in `/public/` matches the request coming in to your app that request will never actually hit the router. As long as that Rails' boilerplate "Welcome Aboard!" page exists, you cannot map the site root to any controller.

Once that file is removed, define the special `root` route like this:

```ruby
MyApp::Application.routes.draw do
  root to: "articles#index"
end
```

The right side uses a new syntax in Rails 3: `"controller_name#action_name"`. Then run `rake routes` and you'd see this:

{% terminal %}
 root  /(.:format)             {controller:"articles", action:"index"}
{% endterminal %}

In the app you can now utilize the `root_path` helper and it'll work!

#### Redirection

One last technique that many developers miss out on: If you're working on a public app it's common that, while the app grows, the URL structure changes. But you don't want to break any old URLs out there on the web nor squander whatever Google Rank those pages have built up.

The solution is to write redirection routes. Imagine that our articles used to be at `/posts/` but now they're at `/articles/`. When a user requests `/posts/16` we know they really want `/articles/16`. Our first instinct might be to write this:

```ruby
MyApp::Application.routes.draw do
  resources :articles
  match 'posts/:id' => 'articles#show'
end
```

And that would work just fine. But when the user visit `/posts/16` the URL will say `posts` but the content comes from `/articles/16`. The link is not broken, but it's dividing your Google Rank between the two URLs. Instead, you want `/posts/16` to give back an HTTP 302 Redirect message. Write the route like this:

```ruby
MyApp::Application.routes.draw do
  resources :articles
  match "/posts/:id" => redirect("/articles/%{id}")
end
```

Unfortunately you can't use the `articles_path` helper within the router itself, so we have to manually create that redirection string. But now when a user or bot visits the old URL they'll be redirected to the new one.

### Exercises

Let's try out a few exercises to practice the router techniques.

#### Setup

You really don't need much of an app to test routes. Let's create a simple app and single controller from the terminal:
You should have rails installed, but if not, type: `gem install rails -v '~>3.0.0'` to get the latest 3.0.x version.

{% terminal %}
$ rails new router_tester
$ cd router_tester
$ bundle
$ rails console
{% endterminal %}

You can test a route like `articles_path` within the console by executing `app.articles_path`. Note that after you make changes to `routes.rb`, you need to call `reload!` in your console to refresh the route definitions.

Open a second terminal window and change to your project directory. Here you can run `rake routes` as you make changes to view the routing table.

#### The Basics

Hop into the `routes.rb` and implement each of the route techniques below.

* Add a `resources` declaration for a resource named `companies`. Observe that seven routes are added following the RESTful convention
* Add a second set of resources named `managers` and observe the routes increase to 14
  * Extra: Condense the two `resources` lines into one that still generates all 14 routes. *Note*: You'll need to undo this for some of the later exercises
* Add nested `evaluations` resources underneath `employees`. Make sure that you have routes generated like `employee_evaluations_path`
  * Extra: Experiment in the console with evaluating these nested routes. What parameters do they require?
* Add nested `scores` resources underneath `evaluations`. Observe how the route names get insane, and reflect on how these nested resources are just not worth it.

#### Customizing REST

Now let's go beyond the standard REST setup:

* Add a custom route that will trigger the `promote` action of `EmployeesController` when a `PUT` is submitted to `promote_employee_path`
* Add a custom route that will trigger the `generate_statistics` action of 'ManagersController' when a `GET` is submitted to `generate_statistics_managers_path`
* In the console, try calling `app.employees_path(maximum_age: 30)` and look at the generate URL. What does this tell you about extra parameters in calls to route helpers?
  * Extra: Experiment with some parameters of your own creation, and try more than one at a time.

#### Non-RESTful Routes

Then a few simple ones:

* Add a route that will redirect requests for `/bosses/` to `/managers/`
* Add another that redirects `show` requests like `/bosses/16` to `/managers/16`
* Add a route named `directory` that points to the `index` action of `EmployeesController`
* Add a route named `search` that points to the `new` action of the `SearchesController`
  * Extra: Modify this route so `/search/managers/fred` would trigger the same action/controller, but set `managers` into a parameter named `group` and `fred` into a parameter named `name`
* Define the `root` route to display the `index` action of `ManagersController`

#### Solutions

For a complete solution to all of the above, visit this Gist: <https://gist.github.com/1044122>

### Further Study

The most comprehensive and up-to-date source on all things Routing is the Rails Guide: <http://guides.rubyonrails.org/routing.html>
