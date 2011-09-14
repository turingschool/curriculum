## Work Plan

|         Status Markers            ||
| :-: | :--------------------------- |
|  ^  | no exercises necessary       |
|  PENDING   | Needs rough content   |
|  EXERCISES | Needs Exercises       |
|  EDIT      | Needs Editing         |
|  REVIEW    | Jeff to Review        |
|  TODO      | Any to-dos            |
|  WIP:Jeff  | Working marker        |
|  §         | Finished              |

Write markers like `[PENDING]` or `[TODO: Double-check this syntax]`.

List all markers with `rake all` in the project directory. `rake -T` to see other available searches.

When you start working on a section, please mark it `[WIP:your name]` so we don't overlap effort. Check-in early and often!

## Day 1

###	Environment & Source Control

* [Environment Setup](environment/environment.markdown) ^ [REVIEW]
* [RVM](environment/rvm.markdown) ^ [REVIEW]
* [Bundler](environment/bundler.markdown) ^ [REVIEW]
* [Common Git Practices](environment/git_strategy.markdown) ^ [REVIEW]
* [Heroku Configuration & Setup](environment/heroku.markdown) ^ [REVIEW]

###	Routes

* [Request Cycle & Component Roles](routes/request_cycle.markdown) ^ [REVIEW]
* [The Rails Router](routes/router.markdown) [REVIEW]

###	Internal Testing

* [RSpec and BDD](internal_testing/rspec_and_bdd.markdown) ^ [REVIEW]
* [RSpec Practices](internal_testing/rspec_practices.markdown) [PENDING]
* [Creating Objects with Factories](internal_testing/factories.markdown) [EDIT] [PENDING]
* [Measuring Code Coverage](internal_testing/code_coverage.markdown) ^ [REVIEW]

###	Integration Testing with Capybara

* [Capybara with Rack::Test](capybara/capybara_with_rack_test.markdown) [REVIEW]
* [JavaScript testing with Selenium & Capybara-Webkit](capybara/capybara_with_selenium_and_webkit.markdown) [REVIEW]
* [Practicing with Capybara](capybara/capybara_practice.markdown) [REVIEW] [PENDING]

## Day 2

###	Debugging

* [Outputting Text](debugging/outputting_text.markdown) [REVIEW]
* [Ruby Debugger](debugging/debugger.markdown) [REVIEW]
* [Error Tracking Services](debugging/error_services.markdown) ^ [REVIEW]

###	Models

* [Relationships](models/relationships.markdown) ^
* [Polymorphism](models/polymorphism.markdown)
* [Legacy/Non-conformant databases](models/legacy_databases.markdown)
* [Validations](models/validations.markdown)
* [Transactions & Locking](models/transactions.markdown) ^
* [Processor Model Design Pattern](models/processor_models.markdown)
* [Pulling out modules to share code](models/modules.markdown)

###	Controllers

* [Handling Parameters](controllers/parameters.markdown)
* [Filters](controllers/filters.markdown)
* [Friendly URLs](controllers/friendly-urls.markdown)
* [Managing the Flash](controllers/flash.markdown)
* [Render and redirect](controllers/render_and_redirect.markdown)
* [Sessions and Conversations](controllers/sessions_and_conversations.markdown)

## Day 3

###	Better Views

* [Understanding Views](better_views/understanding_views.markdown)
* [Rails Templating with ERB and HAML](better_views/erb_and_haml.markdown)
* [Utilizing View Partials](better_views/view_partials.markdown)
* [Pagination](better_views/pagination.markdown)

###	JavaScript & AJAX

* Rails + JavaScript [PENDING]
* [Using jQuery](javascript/jquery.markdown)
* Brief Introduction to CoffeeScript [PENDING]
* Patterns for managing JavaScript code ^ [PENDING]

###	Web Services

* [Exposing an API](web_services/api.markdown)
* [Encoding and Filtering Data](web_services/encoding_and_filtering.markdown)
* Consuming REST with ActiveResource [PENDING]
* Consuming SOAP with Savon [PENDING]

## Day 4

### Performance

* [Measuring Performance](performance/measuring.markdown)
* [Query Strategies](performance/queries.markdown)
* [Caching with Redis](performance/caching.markdown)
* [Background Jobs with Resque](performance/background_jobs.markdown)

### Systems Management

* Scheduling with Cron ^ [PENDING]
* Managing credentials ^ [PENDING]
* Flexible application configuration ^ [PENDING]
* Monitoring performance ^ [PENDING]

### Authentication

* Local authentication with Devise ^ *priority* (also: could we email auto-generated passwords.markdown)  [PENDING]
* Remote authentication with OmniAuth ^ [PENDING]

### Authorization

* Implementing Declarative Authorization [PENDING]
* Structuring roles [PENDING]
* Controlling view, controller, and model access [PENDING]

## Day 5

###	Small Topics & Cleanup

* Finishing anything cut short from the week [PENDING]
* Implementing Search with WebSolr [PENDING]
* Configuring Heroku features [PENDING]
* Continuous Integration with Jenkins ^ [PENDING] 

## General Notes

* [TODO: Push all code blocks flush left]
* [TODO: Work on output formatting of PRE blocks]
* [TODO: Write a capybara test suite for tutorials themselves]

## Extras

* How do we create a form that creates a parent object and children (many-to-many) and validation (fit into Models/Forms)
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
* Decided "Legacy Databases" didn't need exercises
* Consolidating "Non-persistent Models" into "Business Logic"
* Consolidated "ActiveSupport::Concern" into "Pulling out modules to share code"
* Consolidated "Business Logic" section into "Models"
* Merged "Managing sessions" and "Imitating conversations" into "Sessions and Conversations"
* Renamed "Changing over to jQuery" to "Using jQuery"
* Rename "Rails built-in JavaScript helpers" to "Rails + JavaScript"
* Renamed "Consolidating queries" to "Query Strategies"
* Renamed "Caching with Memcache & Redis" to "Caching with Redis"
* Renamed "Creating workers with DelayedJob" to "Background Jobs with Resque"
* Consolidated "View fragment caching" into "Caching with Redis"
* Added "Measuring Performance" to Performance
* Renamed "Exposing APIs from the controller" to "Exposing an API"
* Renamed "Encoding data in the model" to "Encoding and Filtering Data"
* Removed "Keeping the source contained" from APIs -- is this the same as filtering?
* Condensed "Consuming Web Services" and "Providing Web Services" into "Web Services"