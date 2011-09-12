
|             Legend               ||
| :-: | :-------------------------- |
|  ^  | no exercises for this entry |
|  ¥  | Jeff WIP                    |
|  †  | George WIP                  |
|  §  | Jeff to Review              |
|  ®  | includes note(s) to Jeff    |


## Development Schedule

* 8/31: Day 2 Completed
* 9/7: Day 3 Completed
* 9/14: Day 4 Completed
* 9/18: Day 5 Completed
* 9/20: Content Finalized
* 9/21: Design finalized
* 9/22: Book Printing
* 9/26: Course Begins

## Day 1

###	Environment & Source Control

* [Environment Setup](/tutorials/environment/environment/) ^ §
* [RVM](/tutorials/environment/rvm/) ^ §
* [Bundler](/tutorials/environment/bundler/) ^ §
* [Common Git Practices](/tutorials/environment/git_strategy/) ^ §
* [Heroku Configuration & Setup](/tutorials/environment/heroku/) ^ §

###	Routes

* [Request Cycle & Component Roles](/tutorials/routes/request_cycle/) ^ §
* [The Rails Router](/tutorials/routes/router/) §

###	Internal Testing

* [RSpec and BDD](/tutorials/internal_testing/rspec_and_bdd/) ^ §
* [RSpec Practices](/tutorials/internal_testing/rspec_practices/) ¥
* [Creating Objects with Factories](/tutorials/internal_testing/factories/) § ¥
* [Measuring Code Coverage](/tutorials/internal_testing/code_coverage/) ^ §

###	Integration Testing with Capybara

* [Capybara with Rack::Test](/tutorials/capybara/capybara_with_rack_test/) §
* [JavaScript testing with Selenium & Capybara-Webkit](/tutorials/capybara/capybara_with_selenium_and_webkit) §
* [Practicing with Capybara](/tutorials/capybara/capybara_practice/) § ®

## Day 2

###	Debugging

* [Outputting Text](/tutorials/debugging/outputting_text) §
* [Ruby Debugger](/tutorials/debugging/debugger) §
* [Error Tracking Services](/tutorials/debugging/error_services) ^ §

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

* Rails + JavaScript [PENDING] (include markup tips)
* [Using jQuery](/tutorials/javascript/jquery)
* Brief Introduction to CoffeeScript [PENDING]
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

* [Measuring Performance](/tutorials/performance/measuring)
* [Monitoring Queries](/tutorials/performance/queries)
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
* Renamed "Consolidating queries" to "Monitoring Queries"
* Renamed "Caching with Memcache & Redis" to "Caching with Redis"
* Renamed "Creating workers with DelayedJob" to "Background Jobs with Resque"
* Consolidated "View fragment caching" into "Caching with Redis"
* Added "Measuring Performance" to Performance