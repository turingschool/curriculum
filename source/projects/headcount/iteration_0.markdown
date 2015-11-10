# Iteration 0 - Initial Structure

For our first iteration, we're going to build out a complete "slice"
of project functionality across several of our data files.
For this iteration, the slice we'll be focusing on deals with Enrollment
data by district.

To complete the iteration, we'll need to achieve the following:

1. Provide a top-level interface to query for information by District
name
2. Create basic domain objects for the District and Enrollment data
3. Construct appropriate relationships between Districts and underlying
Enrollment data
4. Use these domain objects to answer some basic analytical questions
about enrollment by district.

![Iteration 0](http://i.imgur.com/hKqZTWG.png)

## Data Access Layer

### `DistrictRepository`

The `DistrictRepository` is responsible for holding and searching our `District`
instances. It offers the following methods:

* `find_by_name` - returns either `nil` or an instance of `District` having done a *case insensitive* search
* `find_all_matching` - returns either `[]` or one or more matches which contain the supplied name fragment, *case insensitive*

There is no one data file that contains just the districts. The data must be extracted from one of the other files. Let's use `Kindergartners in full-day program.csv` so the instance is created and used like this:

```ruby
dr = DistrictRepository.new
dr.load_data({
  :enrollment => {
    :kindergarten => "./data/Kindergartners in full-day program.csv"
  }
})
district = dr.find_by_name("ACADEMY 20")
# => <District>
```

### `District`

The `District` is the key concept in our data hierarchy. It starts with just one method:

* `name` - returns the upcased string name of the district

We create an instance like this:

```ruby
d = District.new({:name => "ACADEMY 20"})
```

### `EnrollmentRepository`

The `EnrollmentRepository` is responsible for holding and searching our `Enrollment`
instances. It offers the following methods:

* `find_by_name` - returns either `nil` or an instance of `Enrollment` having done a *case insensitive* search

For iteration 0, the instance of this object represents one line of data from the file `Kindergartners in full-day program.csv`. It's initialized and used like this:

```ruby
er = EnrollmentRepository.new
er.load_data({
  :enrollment => {
    :kindergarten => "./data/Kindergartners in full-day program.csv"
  }
})
enrollment = er.find_by_name("ACADEMY 20")
# => <Enrollment>
```

### `Enrollment`

An `Enrollment` instance holds the enrollment data for a single district. We create an instance like this:

```ruby
e = Enrollment.new({:name => "ACADEMY 20", :kindergarten_participation => {2010 => 0.3915, 2011 => 0.35356, 2012 => 0.2677})
```

An instance of this class offers the following methods:

#### `.kindergarten_participation_by_year`

This method returns a hash with years as keys and a truncated three-digit floating point number representing a percentage for all years present in the dataset.

*Example*:

```ruby
enrollment.kindergarten_participation_by_year
=> { 2010 => 0.391,
     2011 => 0.353,
     2012 => 0.267,
   }
```

#### `.kindergarten_participation_in_year(year)`

This method takes one parameter:

* `year` as an integer for any year reported in the data

A call to this method with any unknown `year` should return `nil`.

The method returns a truncated three-digit floating point number representing a percentage.

*Example*:

```ruby
enrollment.kindergarten_participation_in_year(2010) # => 0.391
```

## Starting the Relationships Layer

Instead of loading just one data file into our `DistrictRepository`, we now want to specify the data directory and have it figure out what data it wants/needs:

```ruby
dr = DistrictRepository.new
dr.load_data({
  :enrollment => {
    :kindergarten => "./data/Kindergartners in full-day program.csv"
  }
})
district = dr.find_by_name("ACADEMY 20")
```

And when a `DistrictRepository` is created in this way then it *automatically* creates the `EnrollmentRepository` as described above and allows us to access the enrollment data for a district like this:

```ruby
district.enrollment.kindergarten_participation_in_year(2010) # => 0.391
```

## Starting the Analysis Layer

Our analysis is centered on answering questions about the data.

Who will answer those questions? Assuming we have a `dr` that's an instance of `DistrictRepository` let's initialize a `HeadcountAnalyst` like this:

```ruby
ha = HeadcountAnalyst.new(dr)
```

Then ask/answer these questions:

### Does Kindergarten participation affect outcomes?

In many states, including Colorado, Kindergarten is offered at public schools but is not free for all residents. Denver, for instance, will charge as much as $310/month for Kindergarten. There's then a disincentive to enroll a child in Kindergarten. Does participation in Kindergarten with other factors/outcomes?

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
ha.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'YUMA SCHOOL DISTRICT 1') # => 1.234
```

Where `1.234` is the result of the district average divided by 'against' district's average. (i.e. find the district's average participation across all years and didvide it by the average of the 'against' district's participation data across all years.) A value less than 1 implies that the district performs lower than the against district's average, and a value greater than 1 implies that the district performs better than the against district's average.

### How does a district's kindergarten participation rate trend against the the state average?

Then, how are the numbers changing each year?

```ruby
ha.kindergarten_participation_rate_variation_trend('ACADEMY 20', :against => 'COLORADO') # => {2009 => 0.766, 2010 => 0.566, 2011 => 0.46 }
```

With the similar calculation as above now broken down by year.
