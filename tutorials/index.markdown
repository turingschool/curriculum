##### Note: Entries marked with ^ will not have exercises.

## Day 1

###	Environment & Source Control

* [Environment Setup](/tutorials/environment/) ^
* [RVM](/tutorials/rvm/) ^
* [Bundler](/tutorials/bundler/) ^
* [Common Git Practices](/tutorials/git_strategy/) ^
* [Heroku Configuration & Setup](/tutorials/heroku/) ^

###	Routes

* [Request Cycle & Component Roles](/tutorials/request_cycle/) ^
* [The Rails Router](/tutorials/router/)

###	Internal Testing

* [RSpec and BDD](/tutorials/rspec_and_bdd/) ^
* [RSpec practices: let, before, after, describe](/tutorials/rspec_practices/)
* [Creating Objects with Factories](/tutorials/factories/)
* [Coverage measurement with CoverMe](/tutorials/code_coverage/) ^

###	Integration Testing with Capybara

* [Capybara with Rack::Test](/tutorials/capybara_with_rack_test/)
* [JavaScript testing with Selenium & Capybara-Webkit](/tutorials/capybara_with_selenium_and_webkit)
* [Practicing Capybara](/tutorials/capybara_practice/)

## Day 2

###	Debugging

* [Outputting Text](/tutorials/outputting_text/)
* Ruby 1.9’s debugger
* Integrated debugging with RubyMine
* Heroku Add-ons: Hoptoad and Exceptional ^

###	Models

* Reviewing relationships ^
* Validations
* Polymorphism
* Legacy/Non-conformant databases
* Database locking ^
* Transactions
* Non-persistent Models

###	Business Logic

* Processor Model Design Pattern
* Pulling out modules to share code
* ActiveSupport::Concern

###	Controllers

* Handling parameters
* Friendly URLs
* Managing the Flash
* Render and redirect
* Managing sessions
* Imitating conversations

## Day 3

###	Better Views

* [Understanding Views](/tutorials/understanding_views/)
* [Rails Templating with ERB and HAML](/tutorials/erb_and_haml/)
* [Utilizing View Partials](/tutorials/view_partials/)
* [Pagination](/tutorials/pagination/)

###	JavaScript & AJAX

* Changing over to jQuery
* Rails built-in JavaScript helpers
* Patterns for managing JavaScript code ^

###	Providing Web Services

* Exposing APIs from the controller
* Encoding data in the model

### Consuming Web Services

* Consuming REST with ActiveResource
* Consuming SOAP with Savon
* Keeping the source contained ^

## Day 4

### Performance

* Consolidating queries
* Caching with Memcache & Redis
* Creating workers with DelayedJob
* View fragment caching

### Systems Management

* Scheduling with Cron ^
* Managing credentials ^
* Flexible application configuration ^
* Monitoring performance ^

### Authentication

* Local authentication with Devise ^ *priority* (also: could we email auto-generated passwords)
* Remote authentication with OmniAuth ^

### Authorization

* Implementing Declarative Authorization
* Structuring roles
* Controlling view, controller, and model access

## Day 5

###	Small Topics & Cleanup

* Finishing anything cut short from the week
* Implementing Search
* Configuring Heroku features
* Continuous Integration ^

## Trimmed Topics

* Other persistence options ^
* Implementing presenter models ^
*	Providing Web Services - Writing customized view templates
*	Creating workers with resque ^
*	Outside-in testing (black-box testing) ^

## Changelog

* Renamed "Manipulating the logs" to "Outputting Text"
* Moved "Raising exceptions" from Debugging into "Outputting Text"