---
layout: page
title: Request Cycle & Component Roles
section: Routes
---

To build great Rails applications you must understand the role of each component of its MVC architecture and carefully consider not just what code to write, but where to write it.

### Request/Response Cycle

In general, we can think of the Request/Response cycle like this:

![Rails MVC](/images/rails_mvc.png)

Let's quickly review those roles:

#### Router

The router is the front line of our application. It receives the request information from the web server and, based on that information, decides which controller action should be called. Rails applications typically follow the REST pattern which allows the router to make its decision based on two components: the _verb_ and the _path_.

The router relies on a "routes table" which you configure. It matches the request against the table then triggers the corresponding controller action. We'll go into more detail on the router in the next section.

#### Controller

The controller is like the coach of the team. It coordinates the other parts, but it should do as little actual *work* as possible. It receives the parameters from the router, passes them on to appropriate model methods, then feeds the results to the view layer.

Controllers are where the average Rails programmer goes wrong. An action should have very little intelligence and almost no "business logic", those responsibilities belong elsewhere. We'll see how to build actions following this premise in the Controller section.

#### Model

Persistence and business logic should all live at the model layer. It's been said that "the model is where real programming happens." When we deal with models we're working in plain Ruby, building up the tools that the rest of the app can use to access and manipulate data.

#### Views

Data flows up from the model through the controller to the views. Generally the *dumbest* part of our application, the views are responsible for mixing presentation code (HTML, CSS, JavaScript) with application data. There should never be business logic in a view, even non-printing lines are considered a "code smell."

### Start at the Beginning

With that general understanding of the application architecture, let's focus on the router.