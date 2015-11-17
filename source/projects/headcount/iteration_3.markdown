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
epr = EconomicProfileRepository.new
epr.load_data({
  :economic_profile => {
    :median_household_income => "./data/Median household income.csv",
    :children_in_poverty => "./data/School-aged children in poverty.csv",
    :free_or_reduced_price_lunch => "./data/Students qualifying for free or reduced price lunch.csv",
    :title_i => "./data/Title I students.csv"
  }
})
ep = epr.find_by_name("ACADEMY 20")
# => <EconomicProfile>
```

## `EconomicProfile`

An instance of this class contains the data from the file above for a single district.
We would create one like this:

```ruby
data = {:median_household_income => {2015 => 50000, 2014 => 60000},
        :children_in_poverty => {2012 => 0.1845},
        :free_or_reduced_price_lunch => {2014 => {:percentage => 0.023, :total => 100}},
        :title_i => {2015 => 0.543},
       }
economic_profile = EconomicProfile.new(data)
```

And it would offer the following methods:

### `.median_household_income_in_year(year)`

This method takes one parameter:

* `year` as an integer

A call to this method with an unknown year should raise an `UnknownDataError`.

The method returns an integer.

*Example*:

```ruby
economic_profile.median_household_income_in_year(2015)
=> 50000
```

### `.median_household_income_average`

This method takes no parameters. It returns an integer averaging the known median household incomes.

*Example*:

```ruby
economic_profile.median_household_income_average
=> 60000
```

### `.children_in_poverty_in_year(year)`

This method takes one parameter:

* `year` as an integer

A call to this method with an unknown year should raise an `UnknownDataError`.

The method returns a float representing a percentage.

*Example*:

```ruby
economic_profile.children_in_poverty_in_year(2012)
=> 0.184
```

### `.free_or_reduced_price_lunch_percentage_in_year(year)`

This method takes one parameter:

* `year` as an integer

A call to this method with an unknown year should raise an `UnknownDataError`.

The method returns a float representing a percentage.

*Example*:

```ruby
economic_profile.free_or_reduced_price_lunch_in_year(2014)
=> 0.023
```

### `.free_or_reduced_price_lunch_number_in_year(year)`

This method takes one parameter:

* `year` as an integer

A call to this method with an unknown year should raise an `UnknownDataError`.

The method returns an integer representing the total number of children
on Free or Reduced Price Lunch in that year.

*Example*:

```ruby
economic_profile.free_or_reduced_price_lunch_total_in_year(2012)
=> 100
```

### `.title_i_in_year(year)`

This method takes one parameter:

* `year` as an integer

A call to this method with an unknown year should raise an `UnknownDataError`.

The method returns a float representing a percentage.

*Example*:

```ruby
economic_profile.title_i_in_year(2015)
=> 0.543
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

Additionally, let's use a dedicated "Result Set" object that aggregates
and provides an interface into these results.

```ruby
rs = ha.high_poverty_and_high_school_graduation
# => <ResultSet>
rs.matching_districts.count
# => 2
rs.matching_districts
# => [<ResultEntry>, <ResultEntry>]
rs.matching_districts.first.name
# => "District 1"
rs.matching_districts.first.free_and_reduced_price_lunch_rate
# => 0.021
rs.matching_districts.first.children_in_poverty_rate
# => 0.023
rs.matching_districts.first.high_school_graduation_rate
# => 0.67
rs.statewide_average
# => <ResultEntry>
rs.statewide_average.free_and_reduced_price_lunch_rate
# => 0.019
rs.statewide_average.children_in_poverty_rate
# => 0.023
rs.statewide_average.high_school_graduation_rate
# => 0.67
```

### Where do we see significant income disparity?

There are obviously going to be some wealthy and some poorer school districts. But which districts show a high disparity in income by both having a high median income and a high rate of child poverty?

Which districts satisfy all of the following:

* Above the statewide average in median household income
* Above the statewide average percentage of school-aged children in poverty

```ruby
rs = ha.high_income_disparity
# => <ResultSet>
rs.matching_districts.count
# => 2
rs.matching_districts
# => [<ResultEntry>, <ResultEntry>]
rs.matching_districts.first.name
# => "District 1"
rs.matching_districts.first.median_household_income
# => 52000
rs.matching_districts.first.children_in_poverty
# => 0.023
rs.statewide_average
# => <ResultEntry>
rs.statewide_average.median_hosuehold_income
# => 48000
rs.statewide_average.children_in_poverty_rate
# => 0.017
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
