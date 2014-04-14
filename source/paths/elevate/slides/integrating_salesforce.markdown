title: Integrating Salesforce
output: integrating_salesforce.html
controls: true
theme: JumpstartLab/cleaver-theme

--

# Integrating Salesforce

--

## Big Goal

* With the application running locally, visit [http://localhost:9000/companies](http://localhost:9000/companies)
* View the listing of all companies in our database
* Let's replace this with a listing of companies from our Salesforce `Account` data

--

## Introducing Heroku Connect

--

### Connect Syncs Data

* **Read-Only** one way sync where data flows from Salesforce into PostgreSQL
* **Read/Write** where data travels both ways

--

### Availability

--

## Setting up Connect

--

### Provision the Addon

--

```bash
$ heroku addons:add herokuconnect
Adding herokuconnect on play-demo-001... done, v17 (free)
Use 'heroku addons:open herokuconnect' to finish setup
```

--

### Web-Based Setup

```bash
$ heroku addons:open herokuconnect
```

--

#### Database

--

#### Schema

--

#### Salesforce Data

--

#### Login to Salesforce

--

#### Back to Connect

--

## Mapping Objects

--

### Account Data

--

### Create the Mapping

* Click the `Add` button
* Select `Account` and click Continue
* Check *AccountNumber* and *Name* boxes then *Continue*

--

### Create the Mapping

* See the actions to be taken and click *Continue*
* Notice the cloud sync icon spinning on the left
* See the sync icon change to a green check

--

### Inspecting the Data

```bash
$ heroku pg:psql
```

--

#### Normal Data

```
=> select * from Company limit 5;
 id |       name        
----+-------------------
  1 | Apple Inc.
  2 | Thinking Machines
  3 | RCA
  4 | Netronics
  5 | Tandy Corporation
(5 rows)
```

--

#### Synched Data

```
=> select * from Account limit 5;
ERROR:  relation "account" does not exist
LINE 1: select * from Account limit 5;
                      ^
```

--

```
=> select * from salesforce.Account limit 5;
 isdeleted | accountnumber |        sfid        | id | _c5_source |  lastmodifieddate   |                name                 
-----------+---------------+--------------------+----+------------+---------------------+-------------------------------------
 f         | CC978213      | 001i000000gEcgZAAS |  1 |            | 2014-03-27 00:02:24 | GenePoint
 f         | CD355119-A    | 001i000000gEcgaAAC |  2 |            | 2014-03-27 00:02:24 | United Oil & Gas, UK
 f         | CD355120-B    | 001i000000gEcgbAAC |  3 |            | 2014-03-27 00:02:24 | United Oil & Gas, Singapore
 f         | CD451796      | 001i000000gEcgcAAC |  4 |            | 2014-03-27 00:02:24 | Edge Communications
 f         | CD656092      | 001i000000gEcgdAAC |  5 |            | 2014-03-27 00:02:24 | Burlington Textiles Corp of America
```

--

## Changing the Application

--

#### `app/models/Company.java`

```java
public static String tableName = "Company";
```

--

```java
public static String tableName = "salesforce.Account";
```

--

### Deploying

```bash
$ git add .
$ git commit -m "Changing database name for Company"
$ git push heroku master
```

--

### Seeing Results

--

#### Changing Salesforce Data

* Click the *Accounts* Tab
* On the left side, click *Create New* then *Account*
* Add an Account Name
* Click *Save*

--

* Click the *Accounts* Tab
* Change the *View* drop-down to *All Accounts*
* Click *Go*
* See the company you just created in the listing

--

#### Effects in Connect

--

#### Effects in the App

--

## Writing to Salesforce

--

### Setting Connect for Read/Write

* Click the Salesforce tab
* Click the *Edit* button in the top right, then *Read/Write*
* Click *Ok* to the scary warning box

--

### Writing Data with `psql`

```bash
$ heroku pg:psql
play-demo-001::JADE=> INSERT INTO salesforce.Account (name) VALUES ('Jumpstart Lab');
INSERT 0 1
```

--

### Results

--

## Next Steps

--

## Resources

* Heroku Connect on [Dev Center](https://Dev Center.heroku.com/articles/herokuconnect)
