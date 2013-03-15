---
layout: page
title: JetFuel
---

## Abstract

In this project you'll use Ruby and Sinatra to build a URL shortener service.

Your application will live on the Internet. It will allow anonymous users and registered users to provide long, ugly URLs and create shortened URLs through your service.

The main goal of your application is to redirect a request at the shortened URL to their long URL equivalent.

Your secondary goal is to track URL usage and provide valueable statistics which you can use to share with your users and/or with advertisers.

## Learning Goals

* Understand how web traffic works
* Designing with RESTful interfaces
* Design a normalized SQL-based database structure
* Use ActiveRecord to interface with the database from Ruby
* Practice fundamental database storage and retrieval
* Understand and practice HTTP verbs including GET, PUT, and POST
* Practice using fundamental HTML and CSS to create a usable web interface

## Base Expectations

### Anonymous Users

```gherkin
Given that I am an anonymous user of the system
When I visit the site
And give a URL to the service
Then I expect it to return a service shortened URL

Given that I am an anonymous user of the system
When I follow a service shortened URL
Then I expect to be redirected to the original URL

Given that I am an anonymous user of the sytem
When I visit the site
Then I expect to see URLs sorted by popularity
And I expect to see URLs sorted by how recently they were added
```

### Registered Users

```gherkin
Given that I am a registered user of the system
When I visit the site
And give a URL to the service and a vanity string
Then I expect it to return a service shortened URL composed of the vanity string

Given that I am a registered user of the system
When I visit the site
And view my user page
Then I am able to view a list of all my service shortened URLs
```

Choose two extension scenarios.

## Extensions

### API

```gherkin
Given that I am a registered user of the system
When I visit the site
And view my user page
Then I should be able to see my personal API key
```

Create a ruby gem that uses your API

{% terminal %}
$ gem install --local jetfuel-0.0.1.gem
{% endterminal %}

{% irb %}
$ jf = JetFuel.new 'http://SERVER', 'IDENTIFIER', 'API_KEY'
$ jf.shorten "http://jumpstartlab.com"
=> "http://SERVER/AFGAD"
$ jf.shorten "http://jumpstartlab.com", "js"
=> "http://SERVER/js"
{% endirb %}

### Statistics

Provide additional statistics on the main page of your application, a user's page of shortened URLS, and indivudal URL pages.

```gherkin
Given that I am an anonymous user of the sytem
When I visit the site
Then I expect to see a list of influential users

Given that I am a registered user of the system
When I visit the site
And view my user page
Then I expect to see a list of links to each shortened URLs detail page

Given that I am a registered user of the system
When I visit the site
And view a shortened URL details page
Then I am able to see individual details about each individual who has used the URL
```

### URL Management

Provide additional tools that allow individuals to remove, deactivate and modify existing defined shortened URLs.

```gherkin
Given that I am a registered user of the system
When I visit the site
And view a shortened URL details page
And I change the target of a shortened URL
When I follow the service shortened URL
Then I expect to be redirected to the updated URL

Given that I am a registered user of the system
When I visit the site
And view a shortened URL details page
And I set the shortened URL to inactive
When I follow the service shortened URL
Then I expect to be directed to an error-inactive page

Given that I am a registered user of the system
When I visit the site
And view a shortened URL details page
And I set the shortened URL to active
When I follow the service shortened URL
Then I expect to be directed to the original URL

Given that I am a registered user of the system
When I visit the site
And view a shortened URL details page
And I delete the shortened URL
When I follow the service shortened URL
Then I expect to be directed to an error-deleted page
```

### Search Engine

Create a job process that collects information about all the
defined target URLs. The data should be stored and indexed.
Users are able to search through all the stored/indexed data
and appropriate links are returned to them.

### Cucumber

Create a cucumber test suite that employs Capybara to
test your applications current feature set.


## Evaluations

### Documentation

* Is it clear on how to get started with the application?
* Is it clear the external dependencies of the project?
* Is it clear to run the tests?
* Is it clear on the features of the application?
* Is it clear the limitations of the application?

### Application

* Does the application meet the expectations defined above?

### Code Clarity

* Is the application consistent with other ruby applications you have written or seen?
* Are the files of the application laid out in a logical manner?
* Does the code within each file directly relate to the name of the file and location within the application?
* Is the code clearly laid out within the class?
* Does each method accomplish their intended task or do they do more than their intended?

### Models

* Are the user passwords stored securly in the database?
* Are the shortened urls generated within the Url model or within a class method?

### Controller Code

* Does each sinatra routing action handle a single operation?
* Are there a small number of instance variables defined?
* Could multiple of the instance variables be represented with a singular concept/object?

### View

* Are the views well formatted?
* Are the views broken into appropriate sub-view templates?
* Are the views free of complicated code and conditional logic?

### Tests

* Do the tests run? Are there failures?
* Are the tests within the test file directly related to the file they are testing?
* Is it clear what code is under test?
* Is it clear what scenario is being tested?
* Is it clear the expected results of the scenario?
* Is there a lot of repetition of setup/teardown in the tests?
