## Project Status

|         *Status Markers*          ||
| :-- | :--------------------------- |
|  ^  | no exercises necessary       |
|  OUTLINE   | Needs Outline from JC |
|  PENDING   | Needs rough content   |
|  EXERCISES | Needs Exercises       |
|  EDIT      | Needs Editing         |
|  REVIEW    | Jeff to Review        |
|  TODO      | Any to-dos            |
|  WIP:Jeff  | Working marker        |
|  §         | Finished              |

## Day 1

###	Environment & Source Control

* [Environment Setup](environment/environment.markdown) ^ §
* [RVM](environment/rvm.markdown) ^ §
* [Bundler](environment/bundler.markdown) ^ §
* [Common Git Practices](environment/git_strategy.markdown) ^ §
* [Heroku Configuration & Setup](environment/heroku.markdown) ^ §

###	Routes

* [Request Cycle & Component Roles](routes/request_cycle.markdown) ^ §
* [The Rails Router](routes/router.markdown) §

###	Internal Testing

* [RSpec and BDD](internal_testing/rspec_and_bdd.markdown) ^ §
* [RSpec Practices](internal_testing/rspec_practices.markdown) [WIP: Frank]
* [Creating Objects with Factories](internal_testing/factories.markdown) §
* [Measuring Code Coverage](internal_testing/code_coverage.markdown) ^ §

###	Integration Testing with Capybara

* [Capybara with Rack::Test](capybara/capybara_with_rack_test.markdown) ^ §
* [JavaScript testing with Selenium & Capybara-Webkit](capybara/capybara_with_selenium_and_webkit.markdown) ^ §
* [Practicing with Capybara](capybara/capybara_practice.markdown) [Needs Major Edits by JC]

## Day 2

###	Debugging

* [Outputting Text](debugging/outputting_text.markdown) §
* [Ruby Debugger](debugging/debugger.markdown) §
* [Error Tracking Services](debugging/error_services.markdown) ^ §

###	Models

* [Relationships](models/relationships.markdown) ^ §
* [Polymorphism](models/polymorphism.markdown) §
* [Legacy/Non-conformant databases](models/legacy_databases.markdown) §
* [Validations](models/validations.markdown) §
* [Transactions](models/transactions.markdown) ^ §
* [Processor Model Design Pattern](models/processor_models.markdown) §
* [Pulling out modules to share code](models/modules.markdown) [PENDING: Finish small AS:C Section]

###	Controllers

* [Handling Parameters](controllers/parameters.markdown) [EDIT]
* [Filters](controllers/filters.markdown) [EDIT]
* [Friendly URLs](controllers/friendly-urls.markdown) [EDIT]
* [Managing the Flash](controllers/flash.markdown) [REVIEW]
* [Render and redirect](controllers/render_and_redirect.markdown) [REVIEW]
* [Sessions and Conversations](controllers/sessions_and_conversations.markdown) [EDIT]

## Day 3

###	Better Views

* [Understanding Views](better_views/understanding_views.markdown) [EDIT]
* [Rails Templating with ERB and HAML](better_views/erb_and_haml.markdown) [EDIT]
* [Utilizing View Partials](better_views/view_partials.markdown) [EDIT]
* [Pagination](better_views/pagination.markdown) §

###	JavaScript & AJAX

* Rails + JavaScript [OUTLINE]
* [Using jQuery](javascript/jquery.markdown) [REVIEW]
* Brief Introduction to CoffeeScript [OUTLINE]
* Patterns for managing JavaScript code ^ [OUTLINE]

###	Web Services

* [Exposing an API](web_services/api.markdown) [REVIEW]
* [Encoding and Filtering Data](web_services/encoding_and_filtering.markdown) [REVIEW]
* Consuming REST with ActiveResource [OUTLINE]
* Consuming SOAP with Savon [OUTLINE]

## Day 4

### Performance

* [Measuring Performance](performance/measuring.markdown) [PENDING: remove outline comments, needs "New Relic", PerfTools.rb usage with Rails]
* [Query Strategies](performance/queries.markdown) [PENDING: remove outline comments, fill in or remove "ActiveHash"]
* [Caching with Redis](performance/caching.markdown) [PENDING: remove outline comments, needs "Customizing Cached Pages" via JavaScript]
* [Background Jobs with Resque](performance/background_jobs.markdown) [PENDING: needs extended example for "Job Lifecycle", needs "Job Feedback/Review" and "Worker Considerations"]

### Systems Management

* [Credentials and Configuration](systems/credentials_and_configuration.markdown) ^ [PENDING]
* [Automated Tasks with Cron and Rake](systems/automation.markdown) ^ [WIP:Mark]

### Authentication & Authorization

* [Local Authentication with Devise](auth/local_authentication.markdown) ^ [WIP:Greg - sections through `Routes` drafted]
* [Remote Authentication with OmniAuth](auth/remote_authentication.markdown) ^ [OUTLINE]
* [Authorization with CanCan](auth/authorization.markdown) [WIP:Ryan]

## Day 5

###	Small Topics

* [Implementing Search with WebSolr](topics/search.markdown) [OUTLINE]
* [Configuring Heroku Features](topics/heroku.markdown) [OUTLINE]
* [Continuous Integration with Jenkins](topics/continuous_integration.markdown) ^ [REVIEW]