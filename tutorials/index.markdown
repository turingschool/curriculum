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

* [Environment Setup](environment/environment/) ^ [REVIEW]
* [RVM](/tutorials/environment/rvm/) ^ [REVIEW]
* [Bundler](/tutorials/environment/bundler/) ^ [REVIEW]
* [Common Git Practices](/tutorials/environment/git_strategy/) ^ [REVIEW]
* [Heroku Configuration & Setup](/tutorials/environment/heroku/) ^ [REVIEW]

###	Routes

* [Request Cycle & Component Roles](/tutorials/routes/request_cycle/) ^ [REVIEW]
* [The Rails Router](/tutorials/routes/router/) [REVIEW]

###	Internal Testing

* [RSpec and BDD](/tutorials/internal_testing/rspec_and_bdd/) ^ [REVIEW]
* [RSpec Practices](/tutorials/internal_testing/rspec_practices/) [PENDING]
* [Creating Objects with Factories](/tutorials/internal_testing/factories/) [EDIT] [PENDING]
* [Measuring Code Coverage](/tutorials/internal_testing/code_coverage/) ^ [REVIEW]

###	Integration Testing with Capybara

* [Capybara with Rack::Test](/tutorials/capybara/capybara_with_rack_test/) [REVIEW]
* [JavaScript testing with Selenium & Capybara-Webkit](/tutorials/capybara/capybara_with_selenium_and_webkit) [REVIEW]
* [Practicing with Capybara](/tutorials/capybara/capybara_practice/) [REVIEW] [PENDING]

## Day 2

###	Debugging

* [Outputting Text](/tutorials/debugging/outputting_text) [REVIEW]
* [Ruby Debugger](/tutorials/debugging/debugger) [REVIEW]
* [Error Tracking Services](/tutorials/debugging/error_services) ^ [REVIEW]

###	Models

* [Relationships](/tutorials/models/relationships) ^
* [Polymorphism](/tutorials/models/polymorphism)
* [Legacy/Non-conformant databases](/tutorials/models/legacy_databases)
* [Validations](/tutorials/models/validations)
* [Transactions & Locking](/tutorials/models/transactions) ^
* [Processor Model Design Pattern](/tutorials/models/processor_models)
* [Pulling out modules to share code](/tutorials/models/modules)

###	Controllers

* [Handling Parameters](/tutorials/controllers/parameters)
* [Filters](/tutorials/controllers/filters)
* [Friendly URLs](/tutorials/controllers/friendly-urls)
* [Managing the Flash](/tutorials/controllers/flash)
* [Render and redirect](/tutorials/controllers/render_and_redirect)
* [Sessions and Conversations](/tutorials/controllers/sessions_and_conversations)

## Day 3

###	Better Views

* [Understanding Views](/tutorials/better_views/understanding_views/)
* [Rails Templating with ERB and HAML](/tutorials/better_views/erb_and_haml/)
* [Utilizing View Partials](/tutorials/better_views/view_partials/)
* [Pagination](/tutorials/better_views/pagination/)

###	JavaScript & AJAX

* Rails + JavaScript [PENDING]
* [Using jQuery](/tutorials/javascript/jquery)
* Brief Introduction to CoffeeScript [PENDING]
* Patterns for managing JavaScript code ^ [PENDING]

###	Web Services

* [Exposing an API](/tutorials/web_services/api)
* [Encoding and Filtering Data](/tutorials/web_services/encoding_and_filtering)
* Consuming REST with ActiveResource [PENDING]
* Consuming SOAP with Savon [PENDING]

## Day 4

### Performance

* [Measuring Performance](/tutorials/performance/measuring)
* [Query Strategies](/tutorials/performance/queries)
* [Caching with Redis](/tutorials/performance/caching)
* [Background Jobs with Resque](/tutorials/performance/background_jobs)

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