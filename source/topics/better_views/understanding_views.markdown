---
layout: page
title: Understanding Views
section: Better Views
---

The view layer is the most ignored part of our stack. We tend to think that the "real programming" happens at the model layer, that the controllers are an inconvenience, and views are just for designers.

This is just not true. We can add in components and techniques to the Rails stack that make the views more beautiful, functional, and easier to write. 

Before we dive into our views in depth, we need to have a common understanding of the request lifecycle and the view's responsibilities. Here's a typical Rails request:

![Rails MVC](/images/rails_mvc.png)

The view receives data from the controller and prepares output for the user. This preparation step includes both formatting the data and combining the data with view templates in order to generate the finished product. Let's first look at templating.
