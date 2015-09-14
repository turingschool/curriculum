# Headcount

### Data Processing

Process each of the data files in the `data` folder to enable the following interactions.

Assume we start with loading our data and finding a school district like this:

```
dr = DistrictRepository.new("./data")
district = dr.find_by_name("ACADEMY 20")
```

Then each `district` has several child objects loaded with data allowing us to ask questions like this:

```
district.enrollment.in_year(2009) # => 22620
district.graduation_rate.for_high_school_in_year(2010) # => 0.895
district.statewide_testing.proficient_for_subject_by_grade_in_year(:math, 3, 2008) # => 0.857
```

### Objects and Methods for Basic Data Access

#### `District`

The `District` is the top of our data hierarchy. It has the following methods:

* `statewide_testing` - returns an instance of `StatewideTesting`
* `enrollment` - returns an instance of `Enrollment`

#### `StatewideTesting`

The instance of this object represents data from the following files:

* `3rd grade students scoring proficient or above on the CSAP_TCAP.csv`
* `4th grade students scoring proficient or above on the CSAP_TCAP.csv`
* `8th grade students scoring proficient or above on the CSAP_TCAP.csv`
* `Average proficiency on the CSAP_TCAP by race_ethnicity_Math.csv`
* `Average proficiency on the CSAP_TCAP by race_ethnicity_Reading.csv`
* `Average proficiency on the CSAP_TCAP by race_ethnicity_Science.csv`
* `Average proficiency on the CSAP_TCAP by race_ethnicity_Writing.csv`

An instance of this class represents the data for a single district and offers the following methods:

##### `.proficient_for_subject_by_grade_in_year(subject, grade, year)`

This method take three parameters:

* `subject` as a symbol from the following set: `[:math, :reading, :writing]`
* `grade` as an integer from the following set: `[3, 4, 8]`
* `year` as an integer for any year reported in the data

A call to this method with any invalid parameter (like subject of `:science`) should raise a `UnknownDataError`.

The method returns a truncated three-digit floating point number representing a percentage.

*Example*:

```
district.statewide_testing.proficient_for_subject_by_grade_in_year(:math, 3, 2008) # => 0.857
```

##### `.proficient_for_subject_by_race_in_year(subject, race, year)`

This method take three parameters:

* `subject` as a symbol from the following set: `[:math, :reading, :writing, :science]`
* `race` as a symbol from the following set: `[:asian, :black, :pacific_islander, :hispanic, :native_american, :two_or_more, :white]`
* `year` as an integer for any year reported in the data

A call to this method with any invalid parameter (like subject of `:history`) should raise a `UnknownDataError`.

The method returns a truncated three-digit floating point number representing a percentage.

*Example*:

```
district.statewide_testing.proficient_for_subject_by_race_in_year(:math, :asian, 2012) # => 0.818
```

##### `.proficient_for_subject_in_year(subject, year)`

This method take two parameters:

* `subject` as a symbol from the following set: `[:math, :reading, :writing, :science]`
* `year` as an integer for any year reported in the data

A call to this method with any invalid parameter (like subject of `:history`) should raise a `UnknownDataError`.

The method returns a truncated three-digit floating point number representing a percentage.

*Example*:

```
district.statewide_testing.proficient_for_subject_in_year(:math, 2012) # => 0.680
```

#### `Enrollment`

The instance of this object represents data from the following files:

* `Dropout rates by race and ethnicity.csv`
* `High school graduation rates.csv`
* `Kindergartners in full-day program.csv`
* `Online pupil enrollment.csv`
* `Pupil enrollment by race_ethnicity.csv`
* `Pupil enrollment.csv`
* `Special education.csv`

An instance of this class represents the data for a single district and offers the following methods:

##### `.proficient_for_subject_by_grade_in_year(subject, grade, year)`


### Trending and Representation

### Data Analysis



## Reference

### Data Sources

* [Search Index](http://datacenter.kidscount.org/data#CO/10/0)
* [Median Household Income](http://datacenter.kidscount.org/data/tables/6228-median-household-income?loc=7&loct=10#detailed/10/1278-1457/false/1376,1201,1074,880,815/any/12960)
* [School Aged Children in Poverty](http://datacenter.kidscount.org/data/tables/435-school-aged-children-in-poverty?loc=7&loct=10#detailed/10/1278-1457/false/36,868,867,133,38/any/11775,1084)
* [Pupil Enrollment](http://datacenter.kidscount.org/data/tables/5678-pupil-enrollment?loc=7&loct=10#detailed/10/1278-1457/false/869,36,868,867,133/any/12280)
* [Special Education](http://datacenter.kidscount.org/data/tables/5314-special-education?loc=7&loct=10#detailed/10/1278-1457/false/869,36,868,867,133/any/14675,11828)
* [Title 1 Students](http://datacenter.kidscount.org/data/tables/5325-title-i-students?loc=7&loct=10#detailed/10/1278-1457/false/869,36,868,867,38/any/11841)
* [Students Qualifying for Free and Reduced Price Lunch](http://datacenter.kidscount.org/data/tables/469-students-qualifying-for-free-or-reduced-price-lunch?loc=7&loct=10#detailed/10/1278-1457/false/869,36,868,867,133/109,110,111/11515,7665)
* [Kindergarteners in Full-Day Program](http://datacenter.kidscount.org/data/tables/449-kindergartners-in-full-day-program?loc=7&loct=10#detailed/10/1278-1457/false/869,36,868,867,133/any/11012)
* [High School Graduation Rates](http://datacenter.kidscount.org/data/tables/6134-high-school-graduation-rates?loc=7&loct=10#detailed/10/1278-1457/false/869,36,868,867,133/any/12806)
* [Dropout Rates by Race and Ethnicity](http://datacenter.kidscount.org/data/tables/7296-dropout-rates-by-race-and-ethnicity?loc=7&loct=10#detailed/10/1278-1457/false/868,867/785,786,787,788,789,790,791,792,3494,2302/14353)
* [Online Pupil Enrollment](http://datacenter.kidscount.org/data/tables/7141-online-pupil-enrollment?loc=7&loct=10#detailed/10/1278-1457/false/36,868,867/any/14171)
* [Remediation in Higher Education](http://datacenter.kidscount.org/data/tables/7663-remediation-in-higher-education?loc=7&loct=10#detailed/10/1278-1457/false/867,133,38/any/14818)
* [3rd Grade Students Scoring Proficient or Above on the CSAP/TCAP](http://datacenter.kidscount.org/data/tables/5651-3rd-grade-students-scoring-proficient-or-above-on-the-csap-tcap?loc=7&loct=10#detailed/10/1278-1457/false/869,36,868,867,133/129,130,145/12252)
* [4rd Grade Students Scoring Proficient or Above on the CSAP/TCAP](http://datacenter.kidscount.org/data/tables/7081-4th-grade-students-scoring-proficient-or-advanced-on-csap-tcap?loc=7&loct=10#detailed/10/1278-1457/false/869,36,868,867,133/any/14099)
* [8th Grade Students Scoring Proficient or Above on the CSAP/TCAP](http://datacenter.kidscount.org/data/tables/5657-8th-grade-students-scoring-proficient-or-above-on-the-csap-tcap?loc=7&loct=10#detailed/10/1278-1457/false/869,36,868,867,133/129,130,145/12262)
* [Pupil Enrollment by Race & Ethnicity](http://datacenter.kidscount.org/data/tables/3736-pupil-enrollment-by-race-ethnicity?loc=7&loct=10#detailed/10/1278-1457/false/869,36,868,867,133/84,87,86,85,88,1849,185,13/11661,7630)
* [AVERAGE PROFICIENCY ON THE CSAP/TCAP BY RACE/ETHNICITY: READING](http://datacenter.kidscount.org/data/tables/6727-average-proficiency-on-the-csap-tcap-by-race-ethnicity-reading?loc=7&loct=10#detailed/10/1278-1457/false/869,36,868,867/2756,2161,2159,2819,2157,2158,2820,2160/13821)
* [AVERAGE PROFICIENCY ON THE CSAP/TCAP BY RACE/ETHNICITY: MATH](http://datacenter.kidscount.org/data/tables/6567-average-proficiency-on-the-csap-tcap-by-race-ethnicity-math?loc=7&loct=10#detailed/10/1278-1457/false/869,36,868,867/2756,2161,2159,2819,2157,2158,2820,2160/13563)
* [AVERAGE PROFICIENCY ON THE CSAP/TCAP BY RACE/ETHNICITY: SCIENCE](http://datacenter.kidscount.org/data/tables/6728-average-proficiency-on-the-csap-tcap-by-race-ethnicity-science?loc=7&loct=10#detailed/10/1278-1457/false/867/2756,2161,2159,2819,2157,2158,2820,2160/13822)
* [AVERAGE PROFICIENCY ON THE CSAP/TCAP BY RACE/ETHNICITY: WRITING](http://datacenter.kidscount.org/data/tables/6729-average-proficiency-on-the-csap-tcap-by-race-ethnicity-writing?loc=7&loct=10#detailed/10/1278-1457/false/869,36,868,867/2756,2161,2159,2819,2157,2158,2820,2160/13823)
