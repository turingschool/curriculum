---
layout: page
title: StoreEngine Evaluation Story 1
---

## Anonymous Shopper Makes a Purchase

* Feature: Checking Out While Logged Out
    * Background:
        * Given I am not logged in
    * Scenario: Viewing products on the home page
        * When I view the home page
        * Then I should see a list of products
    * Scenario: Viewing details for a product
        * Given I am viewing the home page
        * When I click on the product <product name>
        * Then I should see the product details
        * And I should see "add to cart"
    * Scenario: Adding to cart
        * Given I am viewing the product <product name>
        * When I click "add to cart"
        * Then I should see my cart
        * And my cart should contain <product name> with quantity 1
        * And my cart total should be <dollar amount>
    * Scenario: Checking out
        * Given I have added the product <product name> to my cart
        * And I am viewing my cart
        * When I check out
        * Then I should be asked to login
            * When I log in as "demoXX+matt@jumpstartlab.com"
            * Then I should be purchasing <product name> with quantity 1
        * Or be asked to input billing and shipping information

* Feature: Checking Out After Logging In
    * Background:
        * Given I am logged in as "demoXX+matt@jumpstartlab.com"
        * And I have added the product <product name> to my cart
    * Scenario: Checking out
        * Given I am viewing my cart
        * When I check out
        * Then I should be asked for my billing address
        * And I should be asked for my optional shipping address
        * And I should be asked for my credit card info
    * Scenario: Purchasing
        * Given I have checked out with the product <product name>
        * And I have entered in my address and credit card info
        * When I purchase the order
        * Then I should see an order summary page
            * And I should see the order status as "paid"
            * And I should see the order total as <dollar amount>
        * Or see a notice with a link to the order summary page
            * When I follow the link to the order summary page
            * Then I should see the order status as "paid"
            * And I should see the order total as <dollar amount>
