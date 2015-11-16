# Iteration 3: Economic Profile

![Iteration 3](http://imgur.com/RYS8SJs.png)

## Data Access Layer

### `EconomicProfileRepository`

The `EconomicProfileRepository` is responsible for holding and searching our `EconomicProfile`
instances. It offers the following methods:

* `find_by_name` - returns either `nil` or an instance of `EconomicProfile` having done a *case insensitive* search

The `EconomicProfile` instances are built using these data files:

* `Median household income.csv`
* `School-aged children in poverty.csv`
* `Students qualifying for free or reduced price lunch.csv`
* `Title I students.csv`

The repository is initialized and used like this:

```ruby
ep = EconomicProfile.new
ep.load_data({
  :economic_profile => {
    :median_household_income => "Median household income.csv",
    :children_in_poverty => "School-aged children in poverty.csv",
    :free_or_reduced_price_lunch => "Students qualifying for free or reduced price lunch.csv",
    :title_i => `Title I students.csv`
  }
})
ep = ep.find_by_name("ACADEMY 20")
# => <EconomicProfile>
```

## `EconomicProfile`

An instance of this class contains the data from the file above for a single district and offers the following methods:

### `.median_household_income_in_year(year)`

This method takes one parameter:

* `year` as an integer

A call to this method with an unknown year should raise an `UnknownDataError`.

The method returns an integer.

*Example*:

```ruby
economic_profile.median_household_income_in_year(2012)
=> 53125

```

### `.median_household_income_average`

This method takes no parameters. It returns an integer averaging the known median household incomes.

*Example*:

```ruby
economic_profile.median_household_income_average
=> 51234
```

### `.children_in_poverty_in_year(year)`

This method takes one parameter:

* `year` as an integer

A call to this method with an unknown year should raise an `UnknownDataError`.

The method returns a float representing a percentage.

*Example*:

```ruby
economic_profile.children_in_poverty(2012)
=> 0.203
```

### `.free_or_reduced_price_lunch_in_year(year)`

This method takes one parameter:

* `year` as an integer

A call to this method with an unknown year should raise an `UnknownDataError`.

The method returns a float representing a percentage.

*Example*:

```ruby
economic_profile.free_or_reduced_price_lunch_in_year(2012)
=> 0.125
```

### `.title_i_in_year(year)`

This method takes one parameter:

* `year` as an integer

A call to this method with an unknown year should raise an `UnknownDataError`.

The method returns a float representing a percentage.

*Example*:

```ruby
economic_profile.title_i_in_year(2012)
=> 0.010
```

## Relationships

### `District`

We'll add another relationship:

* `economic_profile` - returns an instance of `EconomicProfile`

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
