---
layout: page
title: Deploying Java Apps on Heroku
section: Salesforce Elevate
sidebar: true
---

Now that you understand the basics of how Heroku works, let's actually deploy an application.

## Using the Toolbelt

Let's talk a bit more about the Toolbelt.

### Setup

The prerequisites here are a [Heroku Account](http://heroku.com/signup) and to [install the Toolbelt]().

### Does It Belong to a Project?

The Heroku toolbelt is an executable that gets installed and added to your path. That means that you can run it within your terminal, regardless of which folder you're in.

Most of the time you'll run it from inside a project's root folder.

### What Can It Do?

Anything you can do to an application through the Heroku website, you can do with the toolbelt. You can also do several things that are difficult, impossible, or just slow through the website. The most common include:

* Creating applications
* Adding and removing backups
* Managing addons
* Running one-off commands on the server
* Manipulating environment variables
* Checking the runtime logs

The best way to learn about it is to use it. Here goes!

## Creating an Application

### Setup

We're assuming you've got the sample project cloned already. If not, do so like this:

{% terminal %}
$ git clone https://github.com/JumpstartLab/play_sample
$ cd play_sample
{% endterminal %}

As it stands, the application can be run locally, but it's not ready for Heroku! Let's intentionally run into some problems, then look at the resolutions.

### `heroku create`

As in the instructions above, you've used `cd` to change into the project directory. Now let's provision an instance on Heroku:

{% terminal %}
$ heroku create
Creating calm-ocean-7332... done, stack is cedar
http://calm-ocean-7332.herokuapp.com/ | git@heroku.com:calm-ocean-7332.git
{% endterminal %}

"Calm Ocean"! That's the kind of serenity I'm looking for in my web development.

### `heroku rename`

But maybe you want your application to sound more official. You can use `heroku rename`:

{% terminal %}
$ heroku rename deploying-java-001
Renaming boiling-island-2815 to deploying-java-001... done
http://deploying-java-001.herokuapp.com/ | git@heroku.com:deploying-java-001.git
Git remote heroku updated
{% endterminal %}

Now we're ready for the enterprise.

**Got an error?** Applications need to have a unique name for across the platform. So if you followed the example exactly your name collided with an instance we previously created. Come up with your own name!

### `heroku open`

You have a running instance...kind of. Run this:

{% terminal %}
$ heroku open
{% endterminal %}

Your browser will pop up, attempt to load the application, and give you an ** Application Error**. You haven't actually deployed the code yet!

## Deploying the Application

Let's get our code running on Heroku.

### `git push`

We explained before that you transmit code to Heroku through git. To deploy the application, do the following:

{% terminal %}
$ git push heroku master
{% endterminal %}

#### Try Again

Once the code is up we can try the site again in the browser. Just refresh with the same address. You'll still see an **Application Error**

### The `Procfile`

Remember the `Procfile`? It's a file that tells Heroku exactly how to run your application. The execution process will be very different for a Java application versus Python, Ruby, or JavaScript.

#### The Process for Play

When we ran the Play application locally we did it with:

{% terminal %}
$ play run
{% endterminal %}

In production it'll be a bit more complicated.

#### `target/start`

On Heroku's DevCenter they recommend:

```plain
web: target/start -Dhttp.port=${PORT} ${JAVA_OPTS} -DapplyEvolutions.default=true -Ddb.default.driver=org.postgresql.Driver -Ddb.default.url=${DATABASE_URL}
```

What? Let's unpack that piece by piece:

* The process will be named `web`
* The executable to run is `target/start`
* We want it to run on the port specified by the environment variable `PORT`, which is automatically set by Heroku
* We'll pass in any options for the JVM stored in `JAVA_OPTS`
* We want to automatically apply any "evolutions", the technique Play apps use for changing the structure/contents of the database
* The database driver should default to PostgreSQL
* The URL for the Postgres database is specified in environment variable `DATABASE_URL`

#### Make It!

* Use your text editor to create a file named `Procfile` in the root directory of the project. Note that it starts with a capital P.
* In that file, add just a single line: the `web:` line above.
* Save the file
* Commit it to git

You can do those same steps with a bit of UNIX-fu like this:

{% terminal %}
$ echo 'web: target/start -Dhttp.port=${PORT} ${JAVA_OPTS} -DapplyEvolutions.default=true -Ddb.default.driver=org.postgresql.Driver -Ddb.default.url=${DATABASE_URL}' > Procfile
$ git add .
$ git commit -m "Adding a Procfile"
{% endterminal %}

Push it to Heroku again (`git push heroku master`) and refresh it in your browser.

#### Looking at Logs

Still getting an **Application Error**? Try this...

{% terminal %}
$ heroku logs
{% endterminal %}

You'll see a lot of output from the log file including some lines like this:

```plain
2014-03-26T03:31:19.798557+00:00 app[web.1]:  at java.lang.Class.forName(Class.java:266)
2014-03-26T03:31:19.798557+00:00 app[web.1]:  at play.api.db.BoneCPApi.play$api$db$BoneCPApi$$register(DB.scala:272)
2014-03-26T03:31:19.798420+00:00 app[web.1]: Caused by: java.lang.ClassNotFoundException: org.postgresql.Driver
2014-03-26T03:31:19.798420+00:00 app[web.1]:  at scala.Option.map(Option.scala:133)
2014-03-26T03:31:19.798045+00:00 app[web.1]:  at play.api.db.BoneCPPlugin.onStart(DB.scala:231)
2014-03-26T03:31:19.798045+00:00 app[web.1]:  at play.core.StaticApplication.<init>(ApplicationProvider.scala:51)
```

Specifically:

```
Caused by: java.lang.ClassNotFoundException: org.postgresql.Driver
```

The app is crashing because it can't load the PostgreSQL driver.

## Dependencies

When you deploy an application to Heroku the platform has to build the *slug*. Typically web applications rely on external libraries for some of their functionality. For the slug to be ready-to-run, it needs those dependencies downloaded and zipped in.

### Expressing Dependencies

*How* you express dependencies will vary by application. In a Ruby app, it's through the `Gemfile`. In a Play app, that happens in `project/Build.scala`.

#### `project/Build.scala`

Open that file and you'll see:

```scala
import sbt._
import Keys._
import PlayProject._

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

Note the middle section about `appDependencies`.

#### Adding PostgreSQL

In this section we need to express a dependency on the Java library for PostgreSQL like so:

```scala
    val appDependencies = Seq(
      "org.hibernate" % "hibernate-entitymanager" % "3.6.9.Final",
      "postgresql" % "postgresql" % "9.1-901-1.jdbc4"
    )
```

Note the **comma** that was added to the end of the `hibernate` line, too.

#### Commit and Re-Deploy

With that dependency in place we can retry deployment:

{% terminal %}
$ git add .
$ git commit -m "Adding PostgreSQL dependency"
$ git push heroku master
{% endterminal %}

If you watch closely during the deployment you'll see:

```
[info] downloading http://repo1.maven.org/maven2/postgresql/postgresql/9.1-901-1.jdbc4/postgresql-9.1-901-1.jdbc4.jar ...
[info] [SUCCESSFUL] postgresql#postgresql;9.1-901-1.jdbc4!postgresql.jar (206ms)
[info] Done updating.
```

Now the Postgres driver is available.

#### Try It

Refresh your browser and...you should see a working web application!

## Recap

* We started with a working play application
* We provisioned the application with `heroku create`
* We renamed it with `heroku rename`
* We pushed up code with `git push heroku master`
* We created a `Procfile` telling Heroku how to execute the application
* We used `git push heroku master` to update the application in place
* We used `heroku logs` to learn more about our application error
* We expressed a dependency on the PostgreSQL library
* We updated the app and it worked!

## References

* [Deploying to Heroku](http://www.playframework.com/documentation/2.1.1/ProductionHeroku), Play Framework Documentation
* [Heroku Play Framework Support](https://devcenter.heroku.com/articles/play-support), Heroku DevCenter
