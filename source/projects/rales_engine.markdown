---
layout: page
title: RalesEngine
sidebar: true
---

You haven't forgotten about your old friend [SalesEngine]({% page_url projects/sales_engine %}),
have you? That's ok if you have, since this project will re-acquaint you!

In this project, we'll use Rails and ActiveRecord to
build a JSON API which exposes the SalesEngine data schema.

## Base Expectations - API Design

* All endpoints will expect to return JSON data
* All endpoints should be exposed under an `api` and version (`v1`)
namespace (e.g. `/api/v1/merchants.json`)
* JSON responses should included `ids` only for associated records
unless otherwise indicated (that is, don't embed the whole record, just the id)

## Base Expectations - Schema and Data Importing

* You will create an ActiveRecord model for each
entity included in the [sales engine data](https://github.com/turingschool/sales_engine/tree/master/data).
* Your application should include a rake task which ingests
all of the CSV's and creates the appropriate records

## Base Expectations - Endpoints

### Searching

For your merchants, invoices, items, invoice items, and customers you need to build
the search functionality defined below. `/merchants/` has been used as an example, but assume it applies to `/invoices/`, `/items/`, etc.

#### Random

`api/v1/merchants/random.json` returns a random merchant.

#### Show Record

Each data category should include a `show` action which
renders a JSON representation of the appropriate record:

`GET /api/v1/merchants/1.json`

#### Single Finders

Each data category should offer `find` finders
to return a single object representation like this:

```
GET /api/v1/merchants/find?id=12
```

Which would find the one merchant with ID `12`. The finder should work with any of the attributes defined on the data type and always be case insensitive. For example:

```
GET /api/v1/merchants/find?name=Schroeder-Jerde
```

#### Multi-Finders

Each category should offer `find_all` finders like this:

```
GET /api/v1/merchants/find_all?name=Cummings-Thiel
```

Which would find all the merchants whose name matches this query.
The finder should work with any of the attributes defined on the data
type and always be case insensitive.

## Base Expectations -- Relationships

In addition to the direct queries against single resources,
we would like to also be able to pull relationship data from the API.

We'll expose these relationships using nested URLs, as outlined
in the sections below.

### Merchants

* `GET /api/v1/merchants/:id/items` returns a collection of items associated with that merchant
* `GET /api/v1/merchants/:id/invoices` returns a collection of invoices associated with that merchant from their known orders

### Invoices

* `GET /api/v1/invoices/:id/transactions` returns a collection of associated transactions
* `GET /api/v1/invoices/:id/invoice_items` returns a collection of associated invoice items
* `GET /api/v1/invoices/:id/items` returns a collection of associated items
* `GET /api/v1/invoices/:id/customer` returns the associated customer
* `GET /api/v1/invoices/:id/merchant` returns the associated merchant

#### Invoice Items

* `GET /api/v1/invoice_items/:id/invoice` returns the associated invoice
* `GET /api/v1/invoice_items/:id/item` returns the associated item

#### Items

* `GET /api/v1/items/:id/invoice_items` returns a collection of associated invoice items
* `GET /api/v1/items/:id/merchant` returns the associated merchant

#### Transactions

* `GET /api/v1/transactions/:id/invoice` returns the associated invoice

#### Customers

* `GET /api/v1/customers/:id/invoices` returns a collection of associated invoices
* `GET /api/v1/customers/:id/transactions` returns a collection of associated transactions

## Base Expectations -- Business Intelligence

We want to maintain the original Business Intelligence functionality
of SalesEngine, but this time expose the data through our API.

Remember that ActiveRecord is your friend. Much of the complicated logic
from your original SalesEngine can be expressed quite succinctly
using ActiveRecord queries.

### Merchants

#### All Merchants

* `GET /api/v1/merchants/most_revenue?quantity=x` returns the top `x` merchants ranked by total revenue
* `GET /api/v1/merchants/most_items?quantity=x` returns the top `x` merchants ranked by total number of items sold
* `GET /api/v1/merchants/revenue?date=x` returns the total revenue for date `x` across all merchants

Assume the dates provided match the format of a standard ActiveRecord timestamp.

#### A Single Merchant

* `GET /api/v1/merchants/:id/revenue` returns the total revenue for that merchant across all transactions
* `GET /api/v1/merchants/:id/revenue?date=x` returns the total revenue for that merchant for a specific invoice date `x`
* `GET /api/v1/merchants/:id/favorite_customer` returns the customer who has conducted the most successful transactions
* `GET /api/v1/merchants/:id/customers_with_pending_invoices` returns a collection of customers which have pending (unpaid) invoices

_NOTE_: Failed charges should never be counted in revenue totals or statistics.

_NOTE_: All revenues should be reported as a float with two decimal places.

### Items

* `GET /api/v1/items/most_revenue?quantity=x` returns the top `x` items ranked by total revenue generated
* `GET /api/v1/items/most_items?quantity=x` returns the top `x` item instances ranked by total number sold
* `GET /api/v1/items/:id/best_day` returns the date with the most sales for the given item using the invoice date

### Customers

* `GET /api/v1/customers/:id/favorite_merchant` returns a merchant where the customer has conducted the most successful transactions

## Extensions

If you complete the base extensions outlined above, consider
one of the following extensions

__Build a Client gem__

Using the gem, I should be able to interact with all of the endpoints
included in the application.

__Additional Formats -- CSV__

Business people love CSV's. Specifically they love CSV's
that they can import into a spreadsheet program and go to
town on.

For the business intelligence endpoints in the application,
include an option to request the resource as a CSV.

For example I might request top items with this request:

`GET /api/v1/items/most_revenue.csv?quantity=x`

Which should allow me to download the appropriate data as a CSV file.

## Project Rubric

### Completion

* 4 - Project completes all base requirements according to the spec harness and one or more extensions
* 3 - Project completes all requirements according to the spec harness
* 2 - Project completes most requirements but fails 4 or fewer spec harness tests
* 1 - Project fails more than 4 spec harness tests

### Rails and ActiveRecord Style

* 4 - Project makes great use of ActiveRecord relationships and queries, including
some advanced query functionality such as `joins` or `includes`
* 3 - Project makes good use of ActiveRecord to fulfill Business Reqs, but
drops to ruby enumerables for some query methods
* 2 - Project has some gaps in AR usage, including numerous business methods
that rely on ruby enumerables to find the appropriate data
* 1 - Project struggles to establish a coherent AR schema, including missing
relationships or dysfunctional queries

### Ruby Style and Code Quality

* 4 - Project demonstrates excellent Ruby style. Logic is pushed down the stack
and various POROs or Serializers are used to assist with complicated logic
* 3 - Project uses idiomatic Ruby with a handful of larger methods or bloated
controllers
* 2 - Project struggles to design useful Objects or push logic down the stack
* 1 - Project struggles with basic ruby method and class design

### API Design

* 4 - Project exemplifies API design idioms, with consistent and coherent
response structures, Serializers to format JSON data, and effective request
format handling
* 3 - Project uses strong and consistent data formats throughout, while relying
mostly on standard Rails JSON features
* 2 - Project has inconsistencies or gaps in how its JSON data is organized
or formatted
* 1 - Project's API is not fully functional or has significant confusion around
request formats

### Test Driven Design

* 4 - Project has exceptional test coverage at various application levels,
including coverage for edge cases and complicated logic methods
* 3 - Project has solid test coverage at multiple levels of the application,
but skips some edge cases or complicated methods
* 2 - Project focuses tests on only a single layer of the stack, or has large
gaps in the coverage
* 1 - Project has test failures, significant gaps in coverage, or a general
paucity of tests
