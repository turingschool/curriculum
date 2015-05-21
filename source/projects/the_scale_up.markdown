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
* Handling heavy request volumen/throughput
* Diagnosing and fixing performance bottlenecks
  (without compromising existing features)
* Adding features on top of an existing codebase
* Monitoring production (error and performance) behavior of an application

For this project, each group will be receiving an existing "Pivot" project
to maintain and continue building upon. Your projects will be already
deployed to production environments, and it will be your responsibility
to keep them that way, adding new features and improving performance while
avoiding downtime.

### Teams

The project will be completed by teams of four to five developers over the span of 7 days.

Like all projects, individual team members are expected to:

* Seek out features and responsibilities that are uncomfortable. The time to learn is now.
* Support your teammates so that everyone can collaborate and contribute.

## Project Requirements:

#### Production Performance Monitoring and Metrics

Your project will come pre-configured with a Skylight.io performance monitoring service.
You will be evaluated on the metrics reported by this service at the end of the project.
Additionally, the project will be expected to comfortably handle several hundreds of requests
per minute.

The rubric for application performance will be:

4: Average response time below 100ms with 600+ RPM
3: Average response time below 200ms with 400+ RPM
2: Average resposne time below 400ms with 300+ RPM
1: Average response time above 400ms, or unable to handle 300 RPM

#### Load Testing / User Scripting

In order to evaluate how our applications are performing, we'll need to expose them
to heavy load. To do this, each team will be responsible for implementing a load-testing
script which exercises the production application. Your load script should be provided as a
separate project/repository with its own structure and set of dependencies.
You will be evaluated on how thorough and scalable this script is:

4: Load testing script exercises 85% of application endpoints (as reported by rake routes)
3: Load testing script exercises 60% of application endpoints
2: Load testing script exercises 40% of application endpoints
3: Load testing script exercises 20% or less of application endpoints

#### Database Load

In addition to handling heavy request load from users, our applications will need to handle
database load against a db with large numbers of records. To do this, we'll need to seed
the various tables in our DBs with lots of records. Your exact models or tables will
likely vary from these examples, but the table size expectations are as follows:

* 500,000+ "Item" records
* 200,000+ "User" records
* 30,000+ "Tenant" records (whichever entity provides the items-for-purchase within your app)
* 50,000+ "Order/Purchase" records
* 15+ Tag/Category records (each Item or similar object should have at least 1 category)
* Appropriate numbers of associated records. So if each User has an associated address,
  then those records should be present in proportional numbers.

Writing your seed script probably won't be too bad, but running it can take some time, so it's recommended
that you get started on this part early. Additionally, Ryan Bates' [Populator Gem](https://github.com/ryanb/populator)
may be worth a look.

#### Additional Features

Alas, just because we made it to the bigtime does not mean we're done working on our apps. In addition to
the performance and scale requirements outlined above, your team will need to implement some new features on top
of the existing codebase. Features are divided into __Base__ and __Supporting__ groups, and you'll need to implement
some features from each:

4: Implements all Base Features and 2 or more Supporting Features
3: Implements all Base Features and 1 Supporting Feature
2: Implements some Base Features
1: Features are unreliable or partially impelemented

### Feature Additions -- Base Expectations

#### Pagination

With all the records we're handling now, it won't be feasible to simply render a list of every
item that's for sale. On any page that includes a "list" of items (Index, Tags, etc), add a Pagination interface
that allows users to:

* Click through a numbered list of pages
* See which page they're currently on
* Go to the first page
* Go to the last page

### Custom Exception and 404 Pages

No matter how carefully we code, it's inevitable in a real production system that things will go wrong
from time to time. When this happens, we'd rather our users be greeted by a somewhat helpful and on-brand
error message. Add custome 5xx and 4xx html pages to your application so that the user will see these
pages in error cases rather than the generic "Something went wrong" Rails error pages. The custom error
pages should have relevant links back to main portions of the site, and should feature a design that follows
the overall style/branding of the site.

__Extension -- Error Tracking:__ Your application integrates a production error tracking service which notifies the team whenever
an exception occurs in production. Some open source examples include: https://github.com/Sharagoz/rails_exception_handler,
http://smartinez87.github.io/exception_notification/, or http://errbit.github.io/errbit/.

### Background Processing

At this kind of scale, it won't be tenable to handle any slow task processing during a web request cycle.
To solve this, we'll need to move these activities into asynchronous background workers using a queuing
library such as Resque or Sidekiq. Things to background include: sending emails, handling external API requests,
order confirmation processing, etc.

### Feature Additions -- Supporting Features

#### Search By Date (HomeAway, HubStub)

For travel plans or event tickets, I generally care about making plans on a specific date.

* Add an interface on the index pages which allows me to search for Reservations/Tickets by a range of dates.
* Inclue a Calendar Picker UI for selecting the start and end dates. 
* Don't allow me to select dates in the past, or an end date prior to my start date

#### Search By Region (Keevah)

We already have the ability to search by category, but many lenders are especially attached to regions of the
world. Let's add a feature to:

* Collect "region" information when creating lender accounts (we can use continents as our regions for now)
* Add links at the top of the "Choose a Borrower", "Make a Loan", and "Category" pages that allow users
  to filter Loan Requests within that group by region

#### Wishlist

Allow users to save items to a "wishlist", which they can use to track interesting items before purchasing them.
This action should be available via a simple interaction from the Index/List UI, and should be completed via
AJAX so that the page doesn't have to reload when favoriting an item. Give the user a link in the navbar to
view their wishlist. From the wishlist, the user should be able to click an item to go to its detail page.

#### Recommendations (requires Wishlist): Once a user has added items to their wishlist, give them recommendations for other
items to check out. To determine which items to recommend for User A, take the items that User A has "favorited", then find
other users who have also favorited those items. Then find additional items that those users have also favorited, and recommend
them back to User A. Avoid recommending other items that User A has already favorited themselves.

#### Infinite Scroll:__ Rather than displaying pagination links, simply display a single page's worth
of items when I initially load the page. When I scroll to the bottom of the page, use AJAX to fetch the next
page's worth of items from the server, and append them to the bottom of the list.
