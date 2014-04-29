title: Maximizing Heroku
output: maximizing_heroku.html
controls: true
theme: JumpstartLab/cleaver-theme

--

# Maximizing Heroku

--

## Touring the Web Interface

* scaling dyno numbers and size
* browse and manage add-ons
* display the deployment history
* control who has deployment access
* change the name, 404, domain names, and ownership

--

## Scaling Web Processes

--

### Through the GUI

* Login to heroku.com
* Click "Apps" in the top link bar
* Click the name of the application you want to manipulate
* Under "Dynos", slide the marker to the right
* Click "Apply Changes" (your account will really be debited by the minute)

--

### From the CLI

```
$  heroku ps
=== web (1X): `target/start -Dhttp.port=${PORT} ${JAVA_OPTS} -DapplyEvolutions.default=true -Ddb.default.driver=org.postgresql.Driver -Ddb.default.url=${DATABASE_URL}`
web.1: up 2014/03/24 19:53:41 (~ 25m ago)
```

--

* `web (1X)` shows that we're using Heroku's smallest, cheapest dyno type
* `target/start` is the actual process that is executed on the dyno
* `web.1` tells us that only a single dyno is running

--

```
$ heroku ps:resize web=2X
Resizing and restarting the specified dynos... done
web dynos now 2X ($0.10/dyno-hour)
```

--

```
$ heroku ps:scale web=8
Scaling dynos... done, now running web at 8:2X.web dynos now 2X ($0.10/dyno-hour)
```

--

```
$ heroku ps
=== web (2X): `target/start -Dhttp.port=${PORT} ${JAVA_OPTS} -DapplyEvolutions.default=true -Ddb.default.driver=org.postgresql.Driver -Ddb.default.url=${DATABASE_URL}`
web.1: up 2014/03/20 11:50:59 (~ 1m ago)
web.2: up 2014/03/20 11:51:45 (~ 38s ago)
web.3: up 2014/03/20 11:51:44 (~ 39s ago)
web.4: up 2014/03/20 11:51:45 (~ 38s ago)
web.5: up 2014/03/20 11:51:46 (~ 38s ago)
web.6: up 2014/03/20 11:51:45 (~ 39s ago)
web.7: up 2014/03/20 11:51:45 (~ 39s ago)
web.8: up 2014/03/20 11:51:47 (~ 37s ago)
```

--

```
$ heroku ps:resize web=1X
Resizing and restarting the specified dynos... done
web dynos now 1X ($0.05/dyno-hour)
$ heroku ps:scale web=1
web dynos now 1X ($0.05/dyno-hour)
$ heroku ps
=== web (1X): `target/start -Dhttp.port=${PORT} ${JAVA_OPTS} -DapplyEvolutions.default=true -Ddb.default.driver=org.postgresql.Driver -Ddb.default.url=${DATABASE_URL}`
web.1: up 2014/03/20 11:55:08 (~ 57s ago)
```

--

## Using the `Procfile`

--

### A Basic `Procfile`

* The `web` part defines the name of the process type
* The part to the right of the `:` is what you'd run from a UNIX terminal to execute the process
* Environment variables can be used (like `$PORT` and `$RACK_ENV` here)

```
web: bundle exec thin start -p $PORT -e $RACK_ENV
```

--

### A Java/Play Example

--

* Uses the name `web`
* Runs the executable `target/start`
* Passes several options from the environment variables (`PORT`, `JAVA_OPTS`, `DATABASE_URL`)
* Automatically runs the database "evolutions" if needed

```
web: target/start -Dhttp.port=${PORT} ${JAVA_OPTS} \
    -DapplyEvolutions.default=true \
    -Ddb.default.driver=org.postgresql.Driver \
    -Ddb.default.url=${DATABASE_URL}
```

--

### Defining Multiple Processes

```
web: bundle exec thin start -p $PORT -e $RACK_ENV
worker: bundle exec rake jobs:work
```

--

### References

* [Procfile configuration options](http://Dev Center.heroku.com/articles/procfile) on Heroku's Dev Center

--

## Configuration

* Resource locations, like the IP address of the database
* Security credentials, like OAuth tokens
* Execution environment markers, like *"production"* and *"development"*

--

### Querying the Config


```
$ heroku config
=== boiling-island-2815 Config Vars
DATABASE_URL:               postgres://username:password@ec2-54-225-101-119.compute-1.amazonaws.com:5432/d4tstdg3etpui8
HEROKU_POSTGRESQL_JADE_URL: postgres://username:password@ec2-54-225-101-119.compute-1.amazonaws.com:5432/d4tstdg3etpui8
JAVA_OPTS:                  -Xmx384m -Xss512k -XX:+UseCompressedOops
PATH:                       .jdk/bin:.sbt_home/bin:/usr/local/bin:/usr/bin:/bin
REPO:                       /app/.sbt_home/.ivy2/cache
SBT_OPTS:                   -Xmx384m -Xss512k -XX:+UseCompressedOops
```

--

### Adding a Value

--

```
$ heroku config:add OAUTH_SHARED_SECRET="helloworld"
Setting config vars and restarting boiling-island-2815... done, v8
OAUTH_SHARED_SECRET: helloworld
```

--

```
$ heroku config
=== boiling-island-2815 Config Vars
DATABASE_URL:               postgres://zvxdqpyretrsgk:DNKuFujjxCLKoCV3qQFyH7kz_E@ec2-54-225-101-119.compute-1.amazonaws.com:5432/d4tstdg3etpui8
HEROKU_POSTGRESQL_JADE_URL: postgres://zvxdqpyretrsgk:DNKuFujjxCLKoCV3qQFyH7kz_E@ec2-54-225-101-119.compute-1.amazonaws.com:5432/d4tstdg3etpui8
JAVA_OPTS:                  -Xmx384m -Xss512k -XX:+UseCompressedOops
OAUTH_SHARED_SECRET:        helloworld
PATH:                       .jdk/bin:.sbt_home/bin:/usr/local/bin:/usr/bin:/bin
REPO:                       /app/.sbt_home/.ivy2/cache
SBT_OPTS:                   -Xmx384m -Xss512k -XX:+UseCompressedOops
```

--

### Accessing Values in Code

--

#### Ruby

```
$ heroku run irb
Running `irb` attached to terminal... up, run.2128
irb(main):001:0> ENV['OAUTH_SHARED_SECRET']
=> "helloworld"
irb(main):002:0>
```

--

#### Java

```
$ heroku run sbt play console
Running `sbt play console` attached to terminal... up, run.2176
Picked up JAVA_TOOL_OPTIONS:  -Djava.rmi.server.useCodebaseOnly=true
Getting org.scala-tools.sbt sbt_2.9.1 0.11.2 ...
...
scala> System.getenv("OAUTH_SHARED_SECRET")
res0: java.lang.String = helloworld
```

--

### Considering Security

* Collaborators on an application
* A person who steals your laptop and can login as you and you have no SSH passphrase
* A person who accesses your computer while the SSH keychain is unlocked

--

### References

* [Configuration Variables](http://Dev Center.heroku.com/articles/config-vars) on Heroku's Dev Center

--

## Installing an Add-on / Upgrading Your Database

--

### PostgreSQL Levels

--

#### Hobby-Dev Limitations

* It allows only 10,000 rows of data in aggregate across all tables
* It does not allow for "follower" databases, making backup more complex
* Max 20 connections
* 0mb of RAM

--

#### Standard-Yanari

* Costs $50/month
* Unlimited data rows, 64gb total data
* Follower databases enabled
* Max 60 connections
* 410mb RAM

--

### Replacement vs Migration

--

### Checking the Before-State

```
heroku config
=== boiling-island-2815 Config Vars
DATABASE_URL:               postgres://username:password@ec2-54-225-101-119.compute-1.amazonaws.com:5432/d4tstdg3etpui8
HEROKU_POSTGRESQL_JADE_URL: postgres://username:password@ec2-54-225-101-119.compute-1.amazonaws.com:5432/d4tstdg3etpui8
```

--

### Using `pg:info`

```
$ heroku pg:info
=== HEROKU_POSTGRESQL_JADE_URL (DATABASE_URL)
Plan:        Dev
Status:      available
Connections: 5
PG Version:  9.3.3
Created:     2014-03-26 03:19 UTC
Data Size:   6.7 MB
Tables:      3
Rows:        574/10000 (In compliance)
Fork/Follow: Unsupported
Rollback:    Unsupported
```

--

### Provisioning

```
$ heroku addons:add heroku-postgresql:standard-yanari
Adding heroku-postgresql:standard-yanari on boiling-island-2815... done, v9 ($50/mo)
Attached as HEROKU_POSTGRESQL_ROSE_URL
The database should be available in 3-5 minutes.
 ! The database will be empty. If upgrading, you can transfer
 ! data from another database with pgbackups:restore.
Use `heroku pg:wait` to track status.
Use `heroku addons:docs heroku-postgresql` to view documentation.
```

--

```
$ heroku pg:wait
Waiting for database HEROKU_POSTGRESQL_ROSE_URL... available
```

--

### Configuring

* Change the `DATABASE_URL` variable to the newly provisioned instance
* Restart the application
* Run any data migrations / evolutions

--

#### Change the `DATABASE_URL`

```
$ heroku config
=== boiling-island-2815 Config Vars
DATABASE_URL:               postgres://username:password@ec2-54-225-101-119.compute-1.amazonaws.com:5432/d4tstdg3etpui8
HEROKU_POSTGRESQL_JADE_URL: postgres://username:password@ec2-54-225-101-119.compute-1.amazonaws.com:5432/d4tstdg3etpui8
HEROKU_POSTGRESQL_ROSE_URL: postgres://username:password@ec2-54-83-63-243.compute-1.amazonaws.com:5542/d4bibagdniev3f
```

--

```
$ heroku config:unset DATABASE_URL
Unsetting DATABASE_URL and restarting boiling-island-2815... done, v10
```

--

```
$ heroku config:set DATABASE_URL=postgres://username:password@ec2-54-83-63-243.compute-1.amazonaws.com:5542/d4bibagdniev3f
Setting config vars and restarting boiling-island-2815... done, v11
DATABASE_URL: postgres://username:password@ec2-54-83-63-243.compute-1.amazonaws.com:5542/d4bibagdniev3f
```

--

#### Migrating / Evolving

```
$ heroku run bundle exec rake db:migrate
```

--

### Deprovisioning

* Change the `DATABASE_URL` back to the free instance
* Remove the Yanari instance

--

```
$ heroku config:unset DATABASE_URL
$ heroku config:set DATABASE_URL=postgres://username:password@ec2-54-225-101-119.compute-1.amazonaws.com:5432/d4tstdg3etpui8
$ heroku addons:remove heroku-postgresql:standard-yanari
```

--

### References

* [Choosing the Right Heroku PostgreSQL Plan](https://Dev Center.heroku.com/articles/heroku-postgres-plans#hobby-tier)
* [Creating and Managing Postgres Follower Database](https://Dev Center.heroku.com/articles/heroku-postgres-follower-databases)

--

## Setting Up Custom Domains

--

### Adding a Domain Name

```
$ heroku domains:add www.example.com
$ heroku domains:add example.com
```

--

### DNS Configuration

--

### References

* [Custom Domains](https://Dev Center.heroku.com/articles/custom-domains) on Heroku's Dev Center
