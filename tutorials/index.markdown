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

Write markers like `[PENDING]` or `[TODO: Double-check this syntax]`.

List all markers with `rake all` in the project directory. `rake -T` to see other available searches.

When you start working on a section, please mark it `[WIP:your name]` so we don't overlap effort. Check-in early and often!

### Schedule

* 9/14 - 9/16: Emphasis is on getting rough content written. Currently Day 3, 4, and 5 need significant work. Jeff is working on organization, Greg is continuing work on Day 4. Mike and Ryan will be joining the writing today/tonight. Gerred and Erik will be working on editing.
* 9/17 - 9/18: Editing and exercise writing/revision
* 9/18 - 9/19: Final tweaks, design
* Evening of 9/20: Goal Completion.

### Team Status

* Jeff / jcasimir: Working on outlines for pending sections.
* Greg / gjastrab (writer): Finishing performance section of Day 4 (working mostly evenings)
* Ryan / cookrn (writer): [ Starting Wednesday evening ]
* Mike / subelsky (writer): [ Fill me in ]
* Gerred / gerred (editor): [ Fill me in ]
* Erik / thoraxe (editor): [ Fill me in, starting Thursday, mostly available Friday/Saturday ]
* Geoff / gmassanek (editor): Starting with editing
* Brandon / imathis (design): [ Fill me in ]

### Notes for Editors

* If you notice sections that are more opinion than objective, I want to pull them into a side bar. Ideally, extract them into their own paragraph(s) and wrap them in an HTML DIV like this:

```html
<div class='opinion'>
  In my opinion, the better strategy is to...
</div>
```

* If there's something that needs more attention but you aren't sure what to do, just slap a to-do tag with explanation like this: `[TODO: It seems like there's a code snippet missing here]`

## Day 1

###	Environment & Source Control

* [Environment Setup](environment/environment.markdown) ^ §
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

* [Relationships](models/relationships.markdown) ^ [EDIT]
* [Polymorphism](models/polymorphism.markdown) [REVIEW]
* [Legacy/Non-conformant databases](models/legacy_databases.markdown) [EDIT]
* [Validations](models/validations.markdown) [EDIT]
* [Transactions & Locking](models/transactions.markdown) ^ [EDIT]
* [Processor Model Design Pattern](models/processor_models.markdown) [EDIT]
* [Pulling out modules to share code](models/modules.markdown) [EDIT]

###	Controllers

* [Handling Parameters](controllers/parameters.markdown) [EDIT]
* [Filters](controllers/filters.markdown) [EDIT]
* [Friendly URLs](controllers/friendly-urls.markdown) [EDIT]
* [Managing the Flash](controllers/flash.markdown) [EDIT]
* [Render and redirect](controllers/render_and_redirect.markdown) [EDIT]
* [Sessions and Conversations](controllers/sessions_and_conversations.markdown) [EDIT]

## Day 3

###	Better Views

* [Understanding Views](better_views/understanding_views.markdown) [EDIT]
* [Rails Templating with ERB and HAML](better_views/erb_and_haml.markdown) [EDIT]
* [Utilizing View Partials](better_views/view_partials.markdown) [EDIT]
* [Pagination](better_views/pagination.markdown) [EDIT]

###	JavaScript & AJAX

* Rails + JavaScript [OUTLINE]
* [Using jQuery](javascript/jquery.markdown) [EDIT]
* Brief Introduction to CoffeeScript [OUTLINE]
* Patterns for managing JavaScript code ^ [OUTLINE]

###	Web Services

* [Exposing an API](web_services/api.markdown) [EDIT]
* [Encoding and Filtering Data](web_services/encoding_and_filtering.markdown) [EDIT]
* Consuming REST with ActiveResource [OUTLINE]
* Consuming SOAP with Savon [OUTLINE]

## Day 4

### Performance

* [Measuring Performance](performance/measuring.markdown) [PENDING: remove outline comments, needs "New Relic", PerfTools.rb usage with Rails]
* [Query Strategies](performance/queries.markdown) [PENDING: remove outline comments, fill in or remove "ActiveHash"]
* [Caching with Redis](performance/caching.markdown) [PENDING: remove outline comments, needs "Customizing Cached Pages" via JavaScript]
* [Background Jobs with Resque](performance/background_jobs.markdown) [PENDING: needs "Job Lifecycle" and "Worker Considerations"]

### Systems Management

* [Credentials and Configuration](systems/credentials_and_configuration.markdown) ^ [PENDING]
* [Automated Tasks with Cron and Rake](systems/automation.markdown) ^ [PENDING]

### Authentication & Authorization

* [Local Authentication with Devise](auth/local_authentication.markdown) ^ [PENDING]
* [Remote Authentication with OmniAuth](auth/remote_authentication.markdown) ^ [OUTLINE]
* [Authorization with CanCan](auth/authorization.markdown) [PENDING]

## Day 5

###	Small Topics

* [Implementing Search with WebSolr](topics/search.markdown) [OUTLINE]
* [Configuring Heroku Features](topics/heroku.markdown) [OUTLINE]
* [Continuous Integration with Jenkins](topics/continuous_integration.markdown) ^ [OUTLINE] 

## Extra Topics

* How do we create a form that creates a parent object and children (many-to-many) and validation (fit into Models/Forms)
* Other persistence options ^
* Implementing presenter models ^
*	Providing Web Services - Writing customized view templates
*	Creating workers with resque ^
*	Outside-in testing (black-box testing) ^

## Content Structure Changes

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
* Merged "Authentication" and "Authorization" into "Authentication and Authorization"
* Renamed "Implementing Declarative Authorization" to "Authorization with CanCan"
* Condensed "Authorization with CanCan", "Structuring Roles" and "Controlling view, controller, and model access" into "Authorization with CanCan"
* Renamed "Scheduling with Cron" to "Automated Tasks with Cron and Rake"
* Condensed "Flexible Application Configuration" and "Managing Credentials" into "Credentials and Configuration"
* Removed "Monitoring Performance" from "Systems Managment" since it is already covered in Performance/Measuring
