---
layout: page
title: StoreEngine Evaluation Story 2
---

## Adding Products To The Cart From Multiple Sources

* Feature: Adding Products To The Cart From Multiple Sources
    * Background:
        * Given I am logged in as "demoXX+matt@jumpstartlab.com"
        * And I have previously purchased the product <purchased product name>
    * Scenario: Viewing products by category
        * Given I view the products in the category <category name>
        * Then I should see a list of products all in the category <category name>
    * Scenario: Viewing details for a product
        * Given I view the products in the category <category name>
        * When I click on the product <product name>
        * Then I should see the product details
        * And I should see "add to cart"
    * Scenario: Adding to cart
        * Given I am viewing the product <product name> from category <category name>
        * When I click "add to cart"
        * Then I should see my cart
        * And my cart should contain <product name> with quantity 1
    * Scenario: Viewing previous orders
        * Given I have added the product <product name> to my cart
        * When I view my previous orders
        * And I choose the order containing <purchased product name>
        * And I view the product <purchased product name>
        * And I add it to my cart
        * Then my cart should contain <product name> with quantity 1
        * And my cart should contain <purchased product name> with quantity 1

