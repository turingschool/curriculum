---
layout: page
title: StoreEngine Evaluation Story 6
---

## Purchaser Submits Review

* Feature: Purchaser Submits Review
    * Background:
        * Given I am logged in as "demoXX+matt@jumpstartlab.com"
        * And I have purchased <product name>
        * And I am viewing the product detail page for <product name>
        * And there are no reviews for the product
    * Scenario: Submitting a product review
        * Given I fill in the review title with "Solid product", body with "Would buy again", and star rating as 4 stars
        * When I submit the review
        * Then I should see my review appear on the product details page
        * And I should see the average rating is 4 stars
* Feature: Product details shows average review score
    * Background:
        * Given I am logged in as "demoXX+jeff@jumpstartlab.com"
        * And I have purchased <product name>
        * And I am viewing the product detail page for <product name>
        * And there is one review of the product
        * And the average rating is 4 stars
    * Scenario: Shopper checks out with sale product
        * Given I fill in the review title with "Poor product", body with "Do not recommend", and star rating as 1 stars
        * When I submit the review
        * Then I should see my review appear on the product details page
        * And I should see the average rating is 2.5 stars

