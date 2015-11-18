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
data = {:median_household_income => {[2005, 2009] => 50000, [2008, 2014] => 60000},
        :children_in_poverty => {2012 => 0.1845},
        :free_or_reduced_price_lunch => {2014 => {:percentage => 0.023, :total => 100}},
        :title_i => {2015 => 0.543},
       }
economic_profile = EconomicProfile.new(data)
```

And it would offer the following methods:

### `.estimated_median_household_income_in_year(year)`

This method takes one parameter:

* `year` as an integer

A call to this method with an unknown year should raise an `UnknownDataError`.

To derive this number, we will average the values for all of the year
ranges in which your requested year appears.

The method returns an integer.

*Example*:

```ruby
economic_profile.median_household_income_in_year(2005)
=> 50000
economic_profile.median_household_income_in_year(2009)
=> 55000
```

### `.median_household_income_average`

This method takes no parameters. It returns an integer averaging the known median household incomes.

This should be an average of the reported income from all the available year ranges.

*Example*:

```ruby
economic_profile.median_household_income_average
=> 55000
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
economic_profile.free_or_reduced_price_lunch_number_in_year(2012)
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

No analysis for this iteration -- it'll happen in I4.
