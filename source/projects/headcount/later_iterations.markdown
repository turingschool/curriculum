### Iteration 1: Adding Relationships and Business Intelligence

* `enrollment` - returns an instance of `Enrollment`


### Relationships Layer

Assume we start with loading our data and finding a school district like this:

```ruby
dr = DistrictRepository.from_csv('./data')
district = dr.find_by_name("ACADEMY 20")
```

Then each `district` now has a single child object loaded with data allowing us to ask questions like this:

```ruby
district.enrollment.kindergarten_participation_in_year(2010) # => 0.391
```

### Analysis Layer

Our analysis is centered on answering questions about the data.

Who will answer those questions? Assuming we have a `dr` that's an instance of `DistrictRepository` let's initialize a `HeadcountAnalyst` like this:

```ruby
ha = HeadcountAnalyst.new(dr)
```

Then ask/answer these questions:

#### Does Kindergarten participation affect outcomes?

In many states, including Colorado, Kindergarten is offered at public schools but is not free for all residents. Denver, for instance, will charge as much as $310/month for Kindergarten. There's then a disincentive to enroll a child in Kindergarten. Does participation in Kindergarten with other factors/outcomes?

##### `How does a district's kindergarten participation rate compare to the state average?`

First, let's ask how an individual district's participation percentage compares to the statewide average:

```ruby
ha.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'COLORADO') # => 0.766
```

Where `0.766` is the result of the district average divided by state average. (i.e. find the district's average participation across all years and didvide it by the average of the state participation data across all years.) A value less than 1 implies that the district performs lower than the state average, and a value greater than 1 implies that the district performs better than the state average.

##### `How does a district's kindergarten participation rate compare to another district?`

Let's next compare this variance against another district:

```ruby
ha.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'YUMA SCHOOL DISTRICT 1') # => 1.234
```

Where `1.234` is the result of the district average divided by 'against' district's average. (i.e. find the district's average participation across all years and didvide it by the average of the 'against' district's participation data across all years.) A value less than 1 implies that the district performs lower than the against district's average, and a value greater than 1 implies that the district performs better than the against district's average.

## Iteration 1: Adding more data

Next, now that we have the pieces working for a single CSV file of Kindergarteners, let's add some more data to the equation in Interaton 1.

![Iteration 1](http://imgur.com/7drdEKc.png)

### `Enrollment`

Back in the `Enrollment` class, let's add another CSV file:

* `High school graduation rates.csv`

And let's add the following methods:

#### `.graduation_rate_by_year`

This method returns a hash with years as keys and a truncated three-digit floating point number representing a percentage.

*Example*:

```ruby
enrollment.graduation_rate_by_year
=> { 2010 => 0.895,
     2011 => 0.895,
     2012 => 0.889,
     2013 => 0.913,
     2014 => 0.898,
     }
```

#### `.graduation_rate_in_year(year)`

This method takes one parameter:

* `year` as an integer for any year reported in the data

A call to this method with any unknown `year` should return `nil`.

The method returns a truncated three-digit floating point number representing a percentage.

*Example*:

```ruby
enrollment.graduation_rate_in_year(2010) # => 0.895
```

### Analysis

#### How does kindergarten participation variation compare to the high school graduation variation?

There's thinking that kindergarten participation has long-term effects. Given our limited data set, let's *assume* that variance in kindergarten rates for a given district is similar to when current high school students were kindergarten age (~10 years ago). Let's compare the variance in kindergarten participation and high school graduation.

For a single district:

```ruby
ha.kindergarten_participation_against_high_school_graduation('ACADEMY 20') # => 1.234
```

Call *kindergarten variation* the result of dividing the district's kindergarten participation by the statewide average. Call *graduation variation* the result of dividing the district's graduation rate by the statewide average. Divide the *kindergarten variation* by the *graduation variation* to find the *kindergarten-graduation variance*.

If this result is close to `1`, then we'd infer that the *kindergarten variation* and the *graduation variation* are closely related.

#### Does Kindergarten participation predict high school graduation?

Let's consider the `kindergarten_participation_against_high_school_graduation` and set a correlation window between `0.6` and `1.5`. If the result is in that range then we'll say that they are correlated. For a single district:

```ruby
ha.kindergarten_participation_correlates_with_high_school_graduation(for: 'ACADEMY 20') # => true
```

Then let's look statewide. If more than 70% of districts across the state show a correlation, then we'll answer `true`. If it's less than `70%` we'll answer `false`.

```ruby
ha.kindergarten_participation_correlates_with_high_school_graduation(:for => 'COLORADO') # => true
```

Then let's do the same calculation across a subset of districts:

```ruby
ha.kindergarten_participation_correlates_with_high_school_graduation(:across => ['district_1', 'district_2', 'district_3', 'district_4']) # => true
```

## Iteration 2 - Another Relationship - Statewide Testing

![Iteration 2](http://imgur.com/Rhpl1is.png)

### `District`

The `District` class now also has the following additional method:

* `statewide_testing` - returns an instance of `StatewideTesting`

### `StatewideTesting`

The instance of this object represents data from the following files:

* `3rd grade students scoring proficient or above on the CSAP_TCAP.csv`
* `8th grade students scoring proficient or above on the CSAP_TCAP.csv`
* `Average proficiency on the CSAP_TCAP by race_ethnicity_ Math.csv`
* `Average proficiency on the CSAP_TCAP by race_ethnicity_ Reading.csv`
* `Average proficiency on the CSAP_TCAP by race_ethnicity_ Writing.csv`

An instance of this class offers the following methods:

#### `.proficient_by_grade(grade)`

This method takes one parameter:

* `grade` as an integer from the following set: `[3, 8]`

A call to this method with an unknown grade should raise a `UnknownDataError`.

The method returns a hash grouped by year referencing percentages by subject all
as three digit floats.

*Example*:

```ruby
statewide_testing.proficient_by_grade(3)
=> { 2008 => {:math => 0.857, :reading => 0.866, :writing => 0.671},
     2009 => {:math => 0.824, :reading => 0.862, :writing => 0.706},
     2010 => {:math => 0.849, :reading => 0.864, :writing => 0.662},
     2011 => {:math => 0.819, :reading => 0.867, :writing => 0.678},
     2012 => {:math => 0.830, :reading => 0.870, :writing => 0.655},
     2013 => {:math => 0.855, :reading => 0.859, :writing => 0.668},
     2014 => {:math => 0.834, :reading => 0.831, :writing => 0.639}
   }
```

#### `.proficient_by_race_or_ethnicity(race)`

This method takes one parameter:

* `race` as a symbol from the following set: `[:asian, :black, :pacific_islander, :hispanic, :native_american, :two_or_more, :white]`

A call to this method with an unknown race should raise a `UnknownRaceError`.

The method returns a hash grouped by race referencing percentages by subject all
as truncated three digit floats.

*Example*:

```ruby
statewide_testing.proficient_by_race_or_ethnicity(:asian)
=> { 2011 => {math: 0.816, reading: 0.897, writing: 0.826},
     2012 => {math: 0.818, reading: 0.893, writing: 0.808},
     2013 => {math: 0.805, reading: 0.901, writing: 0.810},
     2014 => {math: 0.800, reading: 0.855, writing: 0.789},
   }
```

#### `.proficient_for_subject_by_grade_in_year(subject, grade, year)`

This method takes three parameters:

* `subject` as a symbol from the following set: `[:math, :reading, :writing]`
* `grade` as an integer from the following set: `[3, 8]`
* `year` as an integer for any year reported in the data

A call to this method with any invalid parameter (like subject of `:science`) should raise a `UnknownDataError`.

The method returns a truncated three-digit floating point number representing a percentage.

*Example*:

```ruby
statewide_testing.proficient_for_subject_by_grade_in_year(:math, 3, 2008) # => 0.857
```

#### `.proficient_for_subject_by_race_in_year(subject, race, year)`

This method take three parameters:

* `subject` as a symbol from the following set: `[:math, :reading, :writing]`
* `race` as a symbol from the following set: `[:asian, :black, :pacific_islander, :hispanic, :native_american, :two_or_more, :white]`
* `year` as an integer for any year reported in the data

A call to this method with any invalid parameter (like subject of `:history`) should raise a `UnknownDataError`.

The method returns a truncated three-digit floating point number representing a percentage.

*Example*:

```ruby
statewide_testing.proficient_for_subject_by_race_in_year(:math, :asian, 2012) # => 0.818
```

#### `.proficient_for_subject_in_year(subject, year)`

This method take two parameters:

* `subject` as a symbol from the following set: `[:math, :reading, :writing]`
* `year` as an integer for any year reported in the data

A call to this method with any invalid parameter (like subject of `:history`) should raise a `UnknownDataError`.

The method returns a truncated three-digit floating point number representing a percentage.

*Example*:

```ruby
statewide_testing.proficient_for_subject_in_year(:math, 2012) # => 0.680
```

### Analysis / Queries

#### Where is the most growth happening in statewide testing?

We have district data about 3rd and 8th grade achievement in reading, math, and writing.
Consider that our data sources have absolute values, not growth.
We're interested in who is making the most progress, not who scores the highest.
That means calculating growth by comparing the absolute values across two or more years.

#### A valid grade must be provided

Because there are multiple grades with which we could answer these questions,
the grade must be provided, or an `InsufficientInformationError` should be raised.

```ruby
ha.top_statewide_testing_year_over_year_growth(subject: :math)
~> InsufficientInformationError: A grade must be provided to answer this question
```

And only valid grades are allowed.

```ruby
ha.top_statewide_testing_year_over_year_growth(grade: 3, subject: :math)
=> ...some sort of result...
ha.top_statewide_testing_year_over_year_growth(grade: 8, subject: :math)
=> ...some sort of result...
ha.top_statewide_testing_year_over_year_growth(grade: 9, subject: :math)
~> UnknownDataError: 9 is not a known grade
```

#### Finding a single leader

```ruby
ha.top_statewide_testing_year_over_year_growth(grade: 3, subject: :math)
=> ['the top district name', 0.123]
```

Where `0.123` is their average percentage growth across years. If there are three years of proficiency data, that's `((year 2 - year 1) + (year 3 - year 2))/2`.

#### Finding multiple leaders

Let's say we want to be able to find several top districts using the same calculations:

```ruby
ha.top_statewide_testing_year_over_year_growth(grade: 3, top: 3, subject: :math)
=> [['top district name', growth_1], ['second district name', growth_2], ['third district name', growth_3]]
```

Where `growth_1` through `growth_3` represents their average growth across years.

#### Across all subjects

What about growth across all three subject areas?

```ruby
ha.top_statewide_testing_year_over_year_growth(grade: 3)
=> ['the top district name', 0.111]
```

Where `0.111` is the district's average percentage growth across years across subject areas.

But that considers all three subjects in equal proportion. No Child Left Behind guidelines generally emphasize reading and math, so let's add the ability to weight subject areas:

```ruby
ha.top_statewide_testing_year_over_year_growth(grade: 8, :weighting => {:math = 0.5, :reading => 0.5, :writing => 0.0})
=> ['the top district name', 0.111]
```

The weights *must* add up to 1.

## Iteration 3: Economic Profile

![Iteration 3](http://imgur.com/RYS8SJs.png)

### `District`

We'll add another relationship:

* `economic_profile` - returns an instance of `EconomicProfile`

### `EconomicProfile`

The instance of this object represents data from the following files:

* `Median household income.csv`

### Analysis/Queries

#### How does kindergarten participation variation compare to the median household income variation?

Does a higher median income mean more kids enroll in Kindergarten? For a single district:

```ruby
ha.kindergarten_participation_against_household_income('ACADEMY 20') # => 1.234
```

Consider the *kindergarten variation* to be the result calculated against the state average as described above.
The *median income variation* is a similar calculation of the district's median income divided by the state average median income.
Then dividing the *kindergarten variation* by the *median income variation* results in `1.234` in the sample.

If this result is close to `1`, then we'd infer that the *kindergarten variation* and the *median income variation* are closely related.

#### Statewide does the kindergarten participation correlate with the median household income?

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
