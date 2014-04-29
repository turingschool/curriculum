title: Deploying Java Apps on Heroku
output: deploying_java_applications.html
controls: true
theme: JumpstartLab/cleaver-theme

--

# Deploying Java Apps on Heroku

--

## Using the Toolbelt

--

### Setup

--

### Does It Belong to a Project?

--

### What Can It Do?

* Creating applications
* Adding and removing backups
* Managing add-ons
* Running one-off commands on the server
* Manipulating environment variables
* Checking the runtime logs

--

## Creating an Application

--

### Setup

```
$ git clone https://github.com/JumpstartLab/play_sample
$ cd play_sample
```

--

### `heroku create`


```
$ heroku create
Creating calm-ocean-7332... done, stack is cedar
http://calm-ocean-7332.herokuapp.com/ | git@heroku.com:calm-ocean-7332.git
```

--

### Heroku Git Remote

* A repo is provisioned on Heroku's side
* The git URL for that repo is added as a master named `heroku`
* The toolbelt can later find the app by looking for that remote in the git config

--

### `heroku rename`


```
$ heroku rename deploying-java-001
Renaming boiling-island-2815 to deploying-java-001... done
http://deploying-java-001.herokuapp.com/ | git@heroku.com:deploying-java-001.git
Git remote heroku updated
```

--

### `heroku open`

```
$ heroku open
```

--

## Deploying the Application

--

### `git push`

```
$ git push heroku master
```

--

#### Try Again

--

### The `Procfile`

--

#### The Process for Play

```
$ play run
```

--

#### `target/start`

```
web: target/start -Dhttp.port=${PORT} ${JAVA_OPTS} \
       -DapplyEvolutions.default=true \
       -Ddb.default.driver=org.postgresql.Driver \
       -Ddb.default.url=${DATABASE_URL}
```

--

* The process will be named `web`
* The executable to run is `target/start`
* We want it to run on the port specified by the environment variable `PORT`, which is automatically set by Heroku
* We'll pass in any options for the JVM stored in `JAVA_OPTS`

--

* We want to automatically apply any "evolutions", the technique Play apps use for changing the structure/contents of the database
* The database driver should default to PostgreSQL
* The URL for the Postgres database is specified in environment variable `DATABASE_URL`

--

#### Make It!

* Use your text editor to create a file named `Procfile` in the root directory of the project. Note that it starts with a capital P.
* In that file, add just a single line: the `web:` line above.
* Save the file
* Commit it to git

--

```
$ echo 'web: target/start -Dhttp.port=${PORT} ${JAVA_OPTS} -DapplyEvolutions.default=true -Ddb.default.driver=org.postgresql.Driver -Ddb.default.url=${DATABASE_URL}' > Procfile
$ git add .
$ git commit -m "Adding a Procfile"
```

--

#### Push to Heroku Again

--

#### Looking at Logs


```
$ heroku logs
```

--

```
app[web.1]:  at java.lang.Class.forName(Class.java:266)
app[web.1]:  at play.api.db.BoneCPApi.play$api$db$BoneCPApi$$register(DB.scala:272)
app[web.1]: Caused by: java.lang.ClassNotFoundException: org.postgresql.Driver
app[web.1]:  at scala.Option.map(Option.scala:133)
app[web.1]:  at play.api.db.BoneCPPlugin.onStart(DB.scala:231)
app[web.1]:  at play.core.StaticApplication.<init>(ApplicationProvider.scala:51)
```

--

```
Caused by: java.lang.ClassNotFoundException:
           org.postgresql.Driver
```

--

## Dependencies

--

### Expressing Dependencies

--

#### `project/Build.scala`

```scala
object ApplicationBuild extends Build {

    val appName         = "computer-database-jpa"
    val appVersion      = "1.0"

    val appDependencies = Seq(
      "org.hibernate" % "hibernate-entitymanager" % "3.6.9.Final"
    )

    val main = PlayProject(appName, appVersion, appDependencies, mainLang = JAVA).settings(
      ebeanEnabled := false
    )

}
```

--

#### Adding PostgreSQL

```scala
val appDependencies = Seq(
  "org.hibernate" % "hibernate-entitymanager" % "3.6.9.Final",
  "postgresql" % "postgresql" % "9.1-901-1.jdbc4"
)
```

--


#### Commit and Re-Deploy

```
$ git add .
$ git commit -m "Adding PostgreSQL dependency"
$ git push heroku master
```

--

```
downloading http://repo1.maven.org/maven2/postgresql/postgresql/9.1-901-1.jdbc4/postgresql-9.1-901-1.jdbc4.jar ...
[SUCCESSFUL] postgresql#postgresql;9.1-901-1.jdbc4!postgresql.jar (206ms)
Done updating.
```

--

#### Try It

--

## Recap

* We started with a working play application
* We provisioned the application with `heroku create`
* We renamed it with `heroku rename`
* We pushed up code with `git push heroku master`

--

## Recap

* We created a `Procfile` telling Heroku how to execute the application
* We used `git push heroku master` to update the application in place
* We used `heroku logs` to learn more about our application error
* We expressed a dependency on the PostgreSQL library
* We updated the app and it worked!

--

## References

* [Deploying to Heroku](http://www.playframework.com/documentation/2.1.1/ProductionHeroku), Play Framework Documentation
* [Heroku Play Framework Support](https://Dev Center.heroku.com/articles/play-support), Heroku Dev Center
