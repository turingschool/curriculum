## The Scale-Up

Well, team: congratulations. Our [Pivot](http://tutorials.jumpstartlab.com/projects/the_pivot.html) did the trick.
It was a rousing success. Maybe even...too successful. In fact, we can barely keep our heads above water!
The site is crashing daily from too much load, and we can't keep up with consumer demand!

We need you, intrepid developers, to fix it. We've got to scale this app up and get things
running smoothly again before our VC's revoke our funding and we become the laughingstock
of HackerNews.

In this project, the __Scale Up__, we'll be optimizing an existing project for performance and
load. A few of the focuses of the project will be:

* Handling a database with large numbers of records
* Handling heavy request volume/throughput
* Diagnosing and fixing performance bottlenecks
  (without compromising existing features)
* Monitoring production (error and performance) behavior of an application

For this project, each student will be receiving an existing "Pivot" project
to maintain and continue building upon. Your projects will be already
deployed to production environments, and it will be your responsibility
to keep them that way, adding new features and improving performance while
avoiding downtime.

## Project Requirements:

#### 1. Production Deployment and Performance Monitoring

Upon receiving your codebase, you will be expected to:

1. Deploy the application to a fresh heroku instance
2. Add Newrelic to the application to monitor its performance in
   production

You will be evaluated on the metrics reported by this service at the end of the project.
Additionally, the project will be expected to comfortably handle several hundreds of requests
per minute.

The rubric for application performance will be:

* 4: Average response time below 100ms with 600+ RPM
* 3: Average response time below 200ms with 400+ RPM
* 2: Average resposne time below 400ms with 300+ RPM
* 1: Average response time above 400ms, or unable to handle 300 RPM

#### 2. Load Testing / User Scripting

In order to evaluate how our applications are performing, we'll need to expose them
to heavy load. To do this, each student will be responsible for implementing a load-testing
script which exercises the production application.

Your load script can be provided as a separate project/repository with its own structure and set of dependencies,
or included in the existing application as a rake task or other
executable script.

The goal of this script is to exercise as many of the application's
endpoints as possible. The evaluation rubric for this coverage will be
based on the _required user paths_ listed below:

* 4: Load testing script exercises all required endpoints and adds 2 or more of its own
* 3: Load testing script exercises all required endpoints
* 2: Load testing script misses 1-3 endpoints
* 1: Load testing misses many endpoints

__Required User Paths__

* Anonymous user browses loan requests
* User browses pages of loan requests
* User browses categories
* User browses pages of categories
* User views individual loan request
* New user signs up as lender
* New user signs up as borrower
* New borrower creates loan request
* Lender makes loan

#### 3. Database Load

In addition to handling heavy request load from users, our applications will need to handle
database load against a db with large numbers of records. To do this, we'll need to seed
the various tables in our DBs with lots of records. Your exact models or tables will
likely vary from these examples, but the table size expectations are as follows:

* 500,000+ "Item" records
* 200,000+ "User" records
* 30,000+ "Tenant" records (whichever entity provides the items-for-purchase within your app)
* 50,000+ "Order/Purchase" records
* 15+ Tag/Category records (each Item or similar object should have at least 1 category)
* Appropriate numbers of "associated records". So if each User has an associated address,
  then those records should be present in proportional numbers.

Writing your seed script won't be too difficult, but running it can take some time, so it's recommended
that you get started on this part early. Additionally, Ryan Bates' [Populator Gem](https://github.com/ryanb/populator)
may be worth a look.

#### 4. Performance Optimization Techniques

Utilizing Rails' performance optimization features is a major focus
for this project, and as such we will be evaluating your project on
how effectively it takes advantage of these features:


* 4 - Application appropriately utilizes multiple caching techniques
  along with sophisticated query optimizations and combinations.
* 3 - Application uses a proficient combination of caching, query
  optimization, and code restructuring to achieve acceptable
  performance.
* 2 - Application includes some optimizations in the form of basic
  caching or query optimization, but fails to attack the problem from
  multiple angles.
* 1 - Application lacks creativity in optimizing performance.

#### 5. Additional Features

In addition to the performance and scale requirements outlined above,
you will need to implement a few new features on top of the existing codebase.

These features will most likely be necessary in order to hit the
specified performance targets, but we specify them here to give you some
initial guidance.

Additionally a few extensions are included before which you may tackle
at your own discretion.

Rubric:

* 4: Implements all Required Features and 1 or more Extensions
* 3: Implements all Base Features
* 2: Implements some Base Features
* 1: Features are unreliable or partially impelemented

__Images: Uploads -> URLs__

Holy AWS Bills Batman! At this scale we can't afford to host images for all of our items, users, etc.
A first order of business should be replacing any image upload requirements with an option to provide
an image url.

__Pagination__

With all the records we're handling now, it won't be feasible to simply render a list of every
item that's for sale. On any page that includes a "list" of items (Index, Tags, etc), add a Pagination interface
that allows users to:

* Click through a numbered list of pages
* See which page they're currently on
* Go to the first page
* Go to the last page
* Go to the next page
* Go to the previous page

__Custom Exception and 404 Pages__

No matter how carefully we code, it's inevitable in a real production system that things will go wrong
from time to time. When this happens, we'd rather our users be greeted by a somewhat helpful and on-brand
error message. Add custom 5xx and 4xx html pages to your application so that the user will see these
pages in error cases rather than the generic "Something went wrong" Rails error pages. The custom error
pages should have relevant links back to main portions of the site, and should feature a design that follows
the overall style/branding of the site.

#### Additional Features -- Extensions

__Search By Date__

For dated item inventory, I generally care about making plans on a specific date.

* Add an interface on the index pages which allows me to search for Reservations/Tickets by a range of dates.
* Include a Calendar Picker UI for selecting the start and end dates.
* Don't allow me to select dates in the past, or an end date prior to my start date

__Wishlist__

Allow users to save items to a "wishlist", which they can use to track interesting items before purchasing them.

* This action should be available via a simple interaction from the Index/List UI
* Favoriting should be completed via AJAX so that the page doesn't have to reload when favoriting an item.
* Include a navbar link for logged in users to take them to their wishlist.
* From the wishlist, the user should be able to click an item to go to its detail page.
* Aditionally, each item on the List/Index should display the # of "favorites" it has received

__Recommendations (requires Wishlist)__

Once a user has added items to their wishlist, give them recommendations for other items to check out.
To determine which items to recommend for User A, take the items that User A has "favorited", then find
other users who have also favorited those items. Then find additional items that those users have also favorited, and recommend
them back to User A. Avoid recommending other items that User A has already favorited themselves.

__Infinite Scroll__

Rather than displaying pagination links, simply display a single page's worth
of items when I initially load the page. When I scroll to the bottom of the page, use AJAX to fetch the next
page's worth of items from the server, and append them to the bottom of the list.

__Error Tracking__

Your application integrates a production error tracking service which notifies the team whenever
an exception occurs in production. Some open source examples include: https://github.com/Sharagoz/rails_exception_handler,
http://smartinez87.github.io/exception_notification/, or http://errbit.github.io/errbit/.

__Background Processing__

At this kind of scale, it won't be tenable to handle any slow task processing during a web request cycle.
To solve this, we'll need to move these activities into asynchronous background workers using a queuing
library such as Resque or Sidekiq. Things to background include: sending emails, handling external API requests,
order confirmation processing, etc.
