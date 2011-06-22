---
layout: tutorial
title: Understanding Views
---

The view layer is the most ignored part of our stack. We tend to think that the "real programming" happens at the model layer, the controllers are an inconvenience, and the views are just for designers.

That's just not true. We can add in components and techniques to the Rails stack that make the views more beautiful, functional, and easier to write. 

Before we dive into our views in depth, we need to have a common understanding of the request lifecycle and the view's responsibilities. Here's a typical Rails request:

![Rails MVC](https://github.com/jcasimir/jumpstartlab_tutorials/raw/master/images/rails_mvc.png)

The view receives data from the controller and prepares output for the user. The preparation step includes both formatting that data and combining it with view templates to generate the finished product. Let's look at templating first.