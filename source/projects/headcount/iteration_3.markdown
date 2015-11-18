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

No analysis for this iteration -- it'll happen in I4.
