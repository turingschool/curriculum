# Iteration 6 - Analysis: Economic Profile and Poverty

## Analysis

### ResultSets

For the analysis queries in this section, we'll often be
reporting multiple results in answer to a given query.

To clarify this process, let's use a dedicates `ResultSet` object that aggregates
and provides an interface into the given results.

The `ResultSet` will represent the aggregate collection of results, and
each data element will be respresented as a `ResultEntry` within that
collection.

The `ResultSet` should have the following methods:

* `#matching_districts` - returns an array of `ResultEntry` objects
* `#statewide_average` - returns a single `ResultEntry` object representing the average across the state

The `ResultEntry` should be a simple wrapper around a hash that
exposes certain keys of the hash as methods.

The accepted keys will be the following:

* `:free_and_reduced_price_lunch_rate`
* `:children_in_poverty_rate`
* `:high_school_graduation_rate`
* `:median_household_income`

Each of these keys should be accessible by invoking a method
of the same name.

**Example:**

```ruby
r1 = ResultEntry.new({free_and_reduced_price_lunch_rate: 0.5,
	children_in_poverty_rate: 0.25,
    high_school_graduation_rate: 0.75})
r2 = ResultEntry.new({free_and_reduced_price_lunch_rate: 0.3,
	children_in_poverty_rate: 0.2,
    high_school_graduation_rate: 0.6})

rs = ResultSet.new(matching_districts: [r1], statewide_average: r2)

rs.matching_districts.first.free_and_reduced_price_punch_rate # => 0.5
rs.matching_districts.first.children_in_poverty_rate # => 0.25
rs.matching_districts.first.high_school_graduation_rate # => 0.75

rs.statewide_average.free_and_reduced_price_punch_rate # => 0.3
rs.statewide_average.children_in_poverty_rate # => 0.2
rs.statewide_average.high_school_graduation_rate # => 0.6
```

**Note** That every key might not be present for every `ResultEntry` --
the methods whose keys are missing should return `nil` in these cases.

### Which districts have both high poverty and a high school graduation rate?

Which districts match all of these criteria:

* Above the statewide average in number of students qualifying for free and reduced price lunch
* Above the statewide average percentage of school-aged children in poverty
* Above the statewide average high school graduation rate

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
rs.matching_districts.first.children_in_poverty_rate
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

To determine this value, we'll take the district's `kindergarten_variation` and
divide it by the district's `median_income_variation`, where:

* *kindergarten variation* is defined as the district's average kindergarten participation
compared against the state's average as described in iteration 1.
* *median income variation* defined as the district's average median income divided by the state's average median income
as defined in iteration 3

Then dividing the *kindergarten variation* by the *median income variation* results in `1.234` in the sample.


### Statewide does the kindergarten participation correlate with the median household income?

If this result is close to `1`, then we'd infer that the *kindergarten variation* and the *median income variation* are closely related.

Let's consider the `kindergarten_participation_against_household_income` and set a correlation window between `0.6` and `1.5`.
If the result is in that range then we'll say that these percentages are correlated. For a single district:

```ruby
ha.kindergarten_participation_correlates_with_household_income(for: 'ACADEMY 20') # => true
ha.kindergarten_participation_correlates_with_household_income(for: 'COLORADO') # => true
```

Then let's look statewide.
If more than 70% percentage of districts across the state show a correlation, then we'll answer `true`.

```ruby
ha.kindergarten_participation_correlates_with_household_income(for: 'STATEWIDE') # => true
```

And let's add the ability to just consider a subset of districts:

```ruby
ha.kindergarten_participation_correlates_with_household_income(:across => ['ACADEMY 20', 'YUMA SCHOOL DISTRICT 1', 'WILEY RE-13 JT', 'SPRINGFIELD RE-4']) # => false
```

