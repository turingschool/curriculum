# Iteration 1 - Starting the Relationship & Analysis Layers

## Starting the Relationships Layer

Let's tweak our `DistrictRepository` to specify the kindergarten load file like this:

```ruby
dr = DistrictRepository.new
dr.load_data({
  :enrollment => {
    :kindergarten => "./data/Kindergartners in full-day program.csv"
  }
})
district = dr.find_by_name("ACADEMY 20")
```

And when a `DistrictRepository` is created in this way then it *automatically* creates the `EnrollmentRepository` as described previously and allows us to access the enrollment data for a district like this:

```ruby
district.enrollment.kindergarten_participation_in_year(2010) # => 0.436
```

## Starting the Analysis Layer: Kindergarten Analysis

Our analysis is centered on answering questions about the data.

Who will answer those questions? Assuming we have a `dr` that's an instance of `DistrictRepository` let's initialize a `HeadcountAnalyst` like this:

```ruby
ha = HeadcountAnalyst.new(dr)
```

Then ask/answer these questions:

### Does Kindergarten participation affect outcomes?

In many states, including Colorado, Kindergarten is offered at public schools but is not free for all residents. Denver, for instance, will charge as much as $310/month for Kindergarten. There's then a disincentive to enroll a child in Kindergarten. Does participation in Kindergarten correlate with other factors/outcomes?

Let's start to build tooling to answer this question.

### How does a district's kindergarten participation rate compare to the state average?

First, let's ask how an individual district's participation percentage compares to the statewide average:

```ruby
ha.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'COLORADO') # => 0.766
```

Where `0.766` is the result of the district average divided by state average. (i.e. find the district's average participation across all years and divide it by the average of the state participation data across all years.) A value less than 1 implies that the district performs lower than the state average, and a value greater than 1 implies that the district performs better than the state average.

### How does a district's kindergarten participation rate compare to another district?

Let's next compare this variance against another district:

```ruby
ha.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'YUMA SCHOOL DISTRICT 1') # => 0.447
```

Where `0.447` is the result of the district average divided by 'against' district's average. (i.e. find the district's average participation across all years and didvide it by the average of the 'against' district's participation data across all years.) A value less than 1 implies that the district performs lower than the against district's average, and a value greater than 1 implies that the district performs better than the against district's average.

### How does a district's kindergarten participation rate trend against the the state average?

Then, how are the numbers changing each year?

```ruby
ha.kindergarten_participation_rate_variation_trend('ACADEMY 20', :against => 'COLORADO') # => {2004 => 1.257, 2005 => 0.96, 2006 => 1.05, 2007 => 0.992, 2008 => 0.717, 2009 => 0.652, 2010 => 0.681, 2011 => 0.727, 2012 => 0.688, 2013 => 0.694, 2014 => 0.661 }
```

With the similar calculation as above now broken down by year.
