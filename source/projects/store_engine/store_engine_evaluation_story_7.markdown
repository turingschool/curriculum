---
layout: page
title: StoreEngine Evaluation Story 7
---

## Exercising Search

* Feature: Shopper Searches For Products
    * Background:
        * Given I am logged in as "demoXX+matt@jumpstartlab.com"
    * Scenario: Submitting a product review
        * Given I am browsing the products
        * And I fill in the the search box with part of <product name>
        * When I submit the search
        * Then I should see a listing of product search results
        * And the listing should include <product name>
    * Scenario: Searching in my order history
        * Given I have purchased <product name>
        * And I am viewing my order history
        * And I fill in the the search box with part of <product name>
        * When I submit the search
        * Then I should see a listing of product search results
        * And the listing should include <product name>
* Feature: Admin Searches For Orders
    * Scenario: Searching for an order
        * Given I am logged in as "demoXX+chad@jumpstartlab.com"
        * And user "demoXX+matt@jumpstartlab.com" has made an order totalling <dollar amount>
        * And I am viewing the admin order dashboard
        * When I select "pending" as the order status for search
        * And I indicate that orders should be less than <dollar amount + 10>
        * And I submit the search
        * Then I should see a listing of orders
        * And the listing should include the order of <product name> by user "demoXX+matt@jumpstartlab.com"

