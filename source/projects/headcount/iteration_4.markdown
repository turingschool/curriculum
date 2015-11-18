# Iteration 4 - Economic/Poverty Analysis

## Analysis

### Which districts have both high poverty and a high school graduation rate?

Which districts match all of these criteria:

* Above the statewide average in number of students qualifying for free and reduced price lunch
* Above the statewide average percentage of school-aged children in poverty
* Above the statewide average high school graduation rate

```ruby
ha.high_poverty_and_high_school_graduation
# =>
#  [
#   ["District 1", {:free_and_reduced_price_lunch => 0.021,
#                   :children_in_poverty => 0.023,
#                   :high_school_graduation => 0.67}],
#   ["District 2", {:free_and_reduced_price_lunch => 0.021,
#                   :children_in_poverty => 0.023,
#                   :high_school_graduation => 0.67}],
#   ["Statewide Average", {:free_and_reduced_price_lunch => 0.019,
#                   :children_in_poverty => 0.018,
#                   :high_school_graduation => 0.55}],
#  ]
```

### Where do we see significant income disparity?

There are obviously going to be some wealthy and some poorer school districts. But which districts show a high disparity in income by both having a high median income and a high rate of child poverty?

Which districts satisfy all of the following:

* Above the statewide average in median household income
* Above the statewide average percentage of school-aged children in poverty

```ruby
ha.high_income_disparity
# =>
#  [
#   ["District 1", {:median_household_income => 52000,
#                   :children_in_poverty => 0.023}],
#   ["District 2", {:median_household_income => 51000,
#                   :children_in_poverty => 0.022}],
#   ["Statewide Average", {:median_household_income => 48000,
#                   :children_in_poverty => 0.017}],
#  ]
```

### How does kindergarten participation variation compare to the median household income variation?

Does a higher median income mean more kids enroll in Kindergarten? For a single district:

```ruby
ha.kindergarten_participation_against_household_income('ACADEMY 20') # => 1.234
```

Consider the *kindergarten variation* to be the result calculated against the state average as described above.
The *median income variation* is a similar calculation of the district's median income divided by the state average median income.
Then dividing the *kindergarten variation* by the *median income variation* results in `1.234` in the sample.

If this result is close to `1`, then we'd infer that the *kindergarten variation* and the *median income variation* are closely related.

### Statewide does the kindergarten participation correlate with the median household income?

Let's consider the `kindergarten_participation_against_household_income` and set a correlation window between `0.6` and `1.5`.
If the result is in that range then we'll say that these percentages are correlated. For a single district:

```ruby
ha.kindergarten_participation_correlates_with_household_income(for: 'ACADEMY 20') # => true
ha.kindergarten_participation_correlates_with_household_income(for: 'COLORADO') # => true
```

Then let's look statewide.
If more than some percentage of districts across the state show a correlation, then we'll answer `true`.

```ruby
ha.kindergarten_participation_correlates_with_household_income(for: 'ACADEMY 20') # => true
```

And let's add the ability to just consider a subset of districts:

```ruby
ha.kindergarten_participation_correlates_with_household_income(:across => ['ACADEMY 20', 'YUMA SCHOOL DISTRICT 1', 'WILEY RE-13 JT', 'SPRINGFIELD RE-4']) # => false
```
