---
layout: page
title: Capybara Workflow
section: Testing with Capybara
---

Capybara is a great tool, but what do you actually *do* with it?

## Acceptance & Feature Tests

### Acceptance Tests are for End Users

### Feature Tests are for Clients & Developers

### They Look the Same

### Maintaining the Veil

You interact with the site like a customer, don't know about the implementation.

#### Making Compromises

Your tests will be crazy slow if you follow all the rules. For example, you'll have to create a new account and set it as an admin before every admin test.

#### Encapsulating Cheats

Make methods like `login_as_admin` so that you can do a direct database insert in development, but actually walk through the signup process in CI.

## Outside-In Testing

### Write an Acceptance Test

### Write a Feature Test

### Dive Inside the App

#### Write a Controller Test

#### Write a Unit/Model Test

#### Repeat and Bubble-Up

### Write the Next Feature Test

Repeat.