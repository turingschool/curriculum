---
layout: page
title: StoreEngine Evaluation Story 5
---

## Admin Exercises Sale Workflow

* Feature: Admin Creates Sale
    * Background:
        * Given I am logged in as "demoXX+chad@jumpstartlab.com"
    * Scenario: Admin creates sale for product
        * Given I am viewing the product <product name> on the admin dashboard or edit screen
        * And I create a sale for that product at 20% off
        * When I view <product name> through normal store browsing
        * Then I should see its price is <sale price>
        * And it should indicate it is on sale
    * Scenario: Admin creates sale for category
        * Given that category <catgory name> contains <product name>
        * And <product name> is on sale at 20% off
        * And I am viewing the category <category name> on the admin dashboard or edit screen
        * When I create a sale for <category name> at 10% off
        * And I browse products by category for <category name>
        * Then I should see <product name> is 20% off
        * And I should see other products in <category name> are 10% off
* Feature: Shopper Buys Sale Product
    * Background:
        * Given I am logged in as "demoXX+matt@jumpstartlab.com"
        * And <product name> is on sale at 20% off
    * Scenario: Shopper checks out with sale product
        * Given I add <product name> to my cart
        * When I check out
        * Then I should see my total is <dollar amount>

