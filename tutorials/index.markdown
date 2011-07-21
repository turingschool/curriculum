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

* [Outputting Text](/tutorials/outputting_text)
* [Ruby Debugger](/tutorials/debugger)
* [Error Tracking Services](/tutorials/error_services) ^

###	Models

* [Relationships](/tutorials/models/relationships) ^
* [Polymorphism](/tutorials/models/polymorphism)
* Legacy/Non-conformant databases [PENDING]
* Validations [PENDING]
* Transactions & Locking ^ [PENDING]
* Non-persistent Models [PENDING]

###	Business Logic

* Processor Model Design Pattern [PENDING]
* Pulling out modules to share code [PENDING]
* ActiveSupport::Concern [PENDING]

###	Controllers

* Handling parameters [PENDING]
* Friendly URLs [PENDING]
* Managing the Flash [PENDING]
* Render and redirect [PENDING]
* Managing sessions [PENDING]
* Imitating conversations [PENDING]

## Day 3

###	Better Views

* [Understanding Views](/tutorials/understanding_views/)
* [Rails Templating with ERB and HAML](/tutorials/erb_and_haml/)
* [Utilizing View Partials](/tutorials/view_partials/)
* [Pagination](/tutorials/pagination/)

###	JavaScript & AJAX

* Changing over to jQuery [PENDING]
* Rails built-in JavaScript helpers [PENDING]
* Patterns for managing JavaScript code ^ [PENDING]

###	Providing Web Services

* Exposing APIs from the controller [PENDING]
* Encoding data in the model [PENDING]

### Consuming Web Services

* Consuming REST with ActiveResource [PENDING]
* Consuming SOAP with Savon [PENDING]
* Keeping the source contained ^ [PENDING]

## Day 4

### Performance

* Consolidating queries [PENDING]
* Caching with Memcache & Redis [PENDING]
* Creating workers with DelayedJob [PENDING]
* View fragment caching [PENDING]

### Systems Management

* Scheduling with Cron ^ [PENDING]
* Managing credentials ^ [PENDING]
* Flexible application configuration ^ [PENDING]
* Monitoring performance ^ [PENDING]

### Authentication

* Local authentication with Devise ^ *priority* (also: could we email auto-generated passwords)  [PENDING]
* Remote authentication with OmniAuth ^ [PENDING]

### Authorization

* Implementing Declarative Authorization [PENDING]
* Structuring roles [PENDING]
* Controlling view, controller, and model access [PENDING]

## Day 5

###	Small Topics & Cleanup

* Finishing anything cut short from the week [PENDING]
* Implementing Search [PENDING]
* Configuring Heroku features [PENDING]
* Continuous Integration ^ [PENDING]

## Trimmed Topics

* Other persistence options ^
* Implementing presenter models ^
*	Providing Web Services - Writing customized view templates
*	Creating workers with resque ^
*	Outside-in testing (black-box testing) ^

## Changelog

* Renamed "Manipulating the logs" to "Outputting Text"
* Moved "Raising exceptions" from Debugging into "Outputting Text"
* Consolidated "Ruby 1.9’s debugger & Integrated debugging with RubyMine" into "Ruby Debugger"
* Renamed "Heroku Add-ons: Hoptoad and Exceptional" to "Error Tracking Services"
* Consolidated "Database locking" and "Transactions" into "Transactions & Locking"
* "Reviewing relationships" renamed to "Relationships"