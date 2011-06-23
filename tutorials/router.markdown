## The Router

The router has, essentially, a simple job. Many Rails programmers, though, consider it a scary place. I've heard of people spending two days tracking down bugs with their route handling. There's no reason it should be that complicated.

The router is controlled through the `config/routes.rb` file. This is one of the first files I'll open when evaluating someone else's project. I go in with questions like these:

* Is it organized, or is it just a junk drawer? Organized is good, messy is bad.
* Are they using a REST style or an old-school RPC style? REST is good, RPC is bad.
* If REST...
  * Are they using many custom actions? A couple custom actions are ok, but if there are many they probably don't understand REST.
  * Are they using nested resources? I don't like them, more later.
* Do they map convenience routes (like `/login` and `/logout`)? If yes, then they've put some energy into the routes, a good sign.

### REST

REpresentational State Transfer, or REST, is a pattern described by Roy Fielding in 2000. It describes a simple model of interacting with "resources" on the web. More information can be found on Wikipedia: http://en.wikipedia.org/wiki/Representational_State_Transfer

#### REST in Rails

Rails 2 was the first framework to bring REST into the mainstream. Now with Rails 3 REST is the de facto standard, using the old RPC approach is passe.

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

We control the router through the `config/routes.rb` file. The syntax of this file has changed several times which is one reason developers get tripped up -- there is a lot of old documentation out there. Let's look at the essential techniques.

#### The Routing Table

To understand the router's configuration, the best tool is the routing table. From within a project root, you can display the routing table by running `rake routes` like this:

```bash
$ rake routes
$
```

The table is blank! Obviously this means no routes have yet been defined.

#### Standard REST

Standard RESTful routes are added to `config/routes.rb` like this:

```ruby
MyApp::Application.routes.draw do
  resources :articles  
end
```

Now, with that one line added, when I run `rake routes` I see this:

```bash
$ rake routes
    articles GET    /articles(.:format)          {:action=>"index", :controller=>"articles"}
             POST   /articles(.:format)          {:action=>"create", :controller=>"articles"}
 new_article GET    /articles/new(.:format)      {:action=>"new", :controller=>"articles"}
edit_article GET    /articles/:id/edit(.:format) {:action=>"edit", :controller=>"articles"}
     article GET    /articles/:id(.:format)      {:action=>"show", :controller=>"articles"}
             PUT    /articles/:id(.:format)      {:action=>"update", :controller=>"articles"}
             DELETE /articles/:id(.:format)      {:action=>"destroy", :controller=>"articles"}
```

Declaring that I have resources called articles, implying that they'll follow Rails' RESTful pattern, adds seven entries to the routing table.

#### Routing Table Entries

An entry in the routes table looks like this:

```bash
articles GET    /articles(.:format)          {:action=>"index", :controller=>"articles"}
```

What do those components pieces mean?

* Column 1, here `articles`: This is the "name" of the route. In our application we can use it to generate URLs. There are helpers for `(name)_url` and `(name)_path`. The former generates a full URL including the protocol and server (like `http://localhost:3000/articles/`). The latter creates a URL relative to the site root (like `/articles/`). The `(name)_path`, like `articles_path`, is preferred.
* Column 2, here `GET`: The request verb that must match to trigger this route
* Column 3, here `/articles(.:format)`: The request pat that must match to trigger this route. We'll deal with parameters like `:format` in greater detail.
* Column 4, here `{:action=>"index", :controller=>"articles"}`: Which controller and action will be triggered when the route is matched

If those make sense, you might be confused by the following line in the routes table:

```bash
  POST   /articles(.:format)          {:action=>"create", :controller=>"articles"}
```

Where's the name in column 1? The way the table is formatted is for the names to "inherit down". Since this line has no listed name, it inherits the name from the line above it, here `articles`, or for practical usage `articles_path`.



#### Handling Formats and Parameters

#### Adding Custom Actions

#### Nested Resources

### Non-Restful Routes

#### Handling Parameters

#### Adding Names

#### When to Use Them

### Special Routes

root


### Exercises
