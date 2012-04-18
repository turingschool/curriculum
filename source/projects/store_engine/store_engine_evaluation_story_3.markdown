---
layout: page
title: StoreEngine Evaluation Story 3
---

## Admin Puts Product Through Lifecycle

* Feature: Admin Puts Product Through Lifecycle
    * Background:
        * Given I am logged in as "demoXX+chad@jumpstartlab.com"
        * And I am viewing the admin area of the store
    * Scenario: Admin creates product
        * Given I click the add product link/button
        * And I fill in the fields with <new product name>, <new product description>, <new product price>, <new product image url>
        * When I click the create product link/button
        * Then I should see the created product
        * And I should see the correct product info
    * Scenario: Admin creates category
        * Given I click the add category link/button
        * And I fill in the field with <new category name>
        * Then I should see the new category with name <new category name>
    * Scenario: Admin adds product to category
        * Given I have created the product <new product name>
        * And I have created the category <new category name>
        * When I edit the product <new product name>
        * And I add it to the category <new category name>
        * And I browse to the category <new category name>
        * Then I should see the product <new product name>
    * Scenario: Retiring a product
        * Given I am editing a product <purchased product name> that has been purchased by "demoXX+matt@jumpstartlab.com"
        * When I retire the product
        * And I log out
        * Then it should not show when browsing all products

