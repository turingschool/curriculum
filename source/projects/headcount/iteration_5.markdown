## Iteration 5 - Analysis: Statewide Testing

### Where is the most growth happening in statewide testing?

We have district data about 3rd and 8th grade achievement in reading, math, and writing. Consider that our data sources have absolute values, not growth. We're interested in who is making the most progress, not who scores the highest. That means calculating growth by comparing the absolute values across two or more years.

#### A valid grade must be provided

Because there are multiple grades with which we could answer these questions,
the grade must be provided, or an `InsufficientInformationError` should be raised.

```ruby
ha.top_statewide_test_year_over_year_growth(subject: :math)
~> InsufficientInformationError: A grade must be provided to answer this question
```

And only valid grades are allowed.

```ruby
ha.top_statewide_test_year_over_year_growth(grade: 3, subject: :math)
=> ...some sort of result...
ha.top_statewide_test_year_over_year_growth(grade: 8, subject: :math)
=> ...some sort of result...
ha.top_statewide_test_year_over_year_growth(grade: 9, subject: :math)
~> UnknownDataError: 9 is not a known grade
```

#### Finding a single leader

```ruby
ha.top_statewide_test_year_over_year_growth(grade: 3, subject: :math)
=> ['the top district name', 0.123]
```

Where `0.123` is their average percentage growth across years. If there are three years of proficiency data (year1, year2, year3), that's `((proficiency at year3) - (proficiency at year1)) / (year3 - year1)`.

#### Finding multiple leaders

Let's say we want to be able to find several top districts using the same calculations:

```ruby
ha.top_statewide_test_year_over_year_growth(grade: 3, top: 3, subject: :math)
=> [['top district name', growth_1], ['second district name', growth_2], ['third district name', growth_3]]
```

Where `growth_1` through `growth_3` represents their average growth across years.

#### Across all subjects

What about growth across all three subject areas?

```ruby
ha.top_statewide_test_year_over_year_growth(grade: 3)
=> ['the top district name', 0.111]
```

Where `0.111` is the district's average percentage growth across years across subject areas.

But that considers all three subjects in equal proportion. No Child Left Behind guidelines generally emphasize reading and math, so let's add the ability to weight subject areas:

```ruby
ha.top_statewide_test_year_over_year_growth(grade: 8, :weighting => {:math => 0.5, :reading => 0.5, :writing => 0.0})
=> ['the top district name', 0.111]
```

The weights *must* add up to 1.

### [TODO: Add another area of analysis for this iteration]
