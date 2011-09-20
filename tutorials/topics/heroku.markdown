# Configuring Heroku Features 

Earlier you learned how to deploy your app to the [Heroku](http://www.heroku.com/) platform. In this section
you'll learn how to work with various Heroku features and add-ons.

## Core Features

### Setting Configuration Variables

As your app grows it will need various pieces of configuration data to run. Some of this data will be too sensitive or change too
frequently for you to be able to store it in source control. Heroku allows you to store configuration variables so that your
app can configure itself in production mode. All apps start out with a default set of variables, which you can view with
the command `heroku config`. Pay special attention to `RACK_ENV` (which determines the environment your app boots into) and 
`DATABASE_URL` which points at your app's database.

Read more about [Heroku configuration variables](http://devcenter.heroku.com/articles/config-vars).

### Setting Up Workers

For performance reasons, most web applications end up offloading work to worker processes that operate
asynchronously, outside the context of a web request. This usually involves settingin up a queueing
system such as [delayed_job](http://devcenter.heroku.com/articles/delayed-job]) or [Resque](https://github.com/defunkt/resque). 

delayed_job is the more documented, simpler approach (since you can use your existing relational database). Follow
[Heroku's setup instructions](http://devcenter.heroku.com/articles/delayed-job) to get this running.

Note that if you are creating an app using Heroku's Cedar stack, you will need to add a worker process to the app's 
[Procfile](http://devcenter.heroku.com/articles/procfile), described below.

### Using the Procfile

Heroku's Celadon Cedar stack affords much more flexibility about what kinds of processes can be run on Heroku. A typical
web app configuration using delayed_job and thin is below:

```bash
worker: bundle exec rake jobs:work
web: bundle exec thin start -p $PORT -e $RACK_ENV
```

Read more about Procfile configuration [here](http://devcenter.heroku.com/articles/procfile).

### Scaling Dynos

As your app gets more usage you will need more processes (called dynos) to handle requests. Use the `ps:scale` command to increase the 
number of dynos allocated to each of the processes in your Procfile. You can specify absolute numbers (like 2, for 2 total dynos)
or relative numbers (like +1, for one additional dyno):

```bash
heroku ps:scale web=2 worker+1
```

The names "web" and "worker" in this case refer to the labels in your Procfile.

### Configuring the Rails 3.1 Asset Pipeline

If your app uses the [Rails asset pipeline](http://guides.rubyonrails.org/asset_pipeline.html), [Heroku will compile the assets for you](http://devcenter.heroku.com/articles/rails31_heroku_cedar) 
at deploy time using the `rake assets:precompile` task. Be sure to add these gems to the `asset` group in your Gemfile:

<div class='opinion'>
This is the simplest way to get started, but eventually you may want to serve your assets from a separate host such as [CloudFront](http://aws.amazon.com/cloudfront/).
Using an asset host frees up your Heroku dynos to handle dynamic requests. You can run the precompile task yourself like so:

`RAILS_ENV=production rake assets:precompile`

which will add a `public/assets/manifest.yml` file to your app. If Heroku sees this file, it will not bother to compile your assets.
You are then free to upload the compiled files to your CDN. You may wish to use the [asset_sync gem](https://github.com/rumblelabs/asset_sync)
to automate this process.

You'll also need to configure the asset host in your `config/environments/production.rb` file:

```ruby
config.action_controller.asset_host = "https://d2mfbgzuncgoal.cloudfront.net"
```
</div>

## Managing Data

### Exporting Data

The simplest way to export your database uses the `pgbackups:url` command to get a temporarily-accessible download:

```bash
curl -o latest.dump `heroku pgbackups:url`
```

You can also transfer data between Heroku databases using the procedure explained at the end of the pgbackups documentation.

### Importing Data

The `pgbackups:restore` command will pull data from a URL into your database like so:

```bash
heroku pgbackups:restore DATABASE 'http://example.com/location/of/your/dump'
```

### Automating Database Backups

The [PG Backups](http://addons.heroku.com/pgbackups) add-on will perform automatic daily backups, retaining the
last 7 daily backups and 5 weekly backups. Add this to your app via:

```bash
heroku addons:add pgbackups:auto-month
```

If you know you're about to try something sensitive, you can perform manual backups (of which Heroku will retain 10 under the above plan) using this command:

```bash
heroku pgbackups:capture 
```

Read more about [Heroku backups](http://devcenter.heroku.com/articles/pgbackups).

### Using a Dedicated Database

Heroku apps start off using a shared database. The performance of a shared database is only acceptable for staging environments
or "low-scale production applications". Once you start to see serious usage you'll want to switch to a dedicated database.
This upgrade can only be done from Heroku's web U/I since a significant cost increase is involved.

## Add-Ons

### Setting Up Custom Domains

You can run your app for free at a [custom domain](http://devcenter.heroku.com/articles/custom-domains) name by running:

```bash
heroku addons:add custom_domains:basic
```

Add the domain names like this:

```bash
heroku domains:add www.example.com
heroku domains:add example.com
```

You must configure a CNAME for your domains to point to Heroku in order for this to work, as explained
in detail in the [Heroku Custom Domains](http://devcenter.heroku.com/articles/custom-domains) documentation.

### Using Cron

Heroku will run short-duration daily and hourly batch jobs for you using the [Cron add-on](http://addons.heroku.com/cron).
You need to add a rake task named "cron" to your app in `lib/tasks/cron.rake`. 
```ruby
desc "run cron jobs"
task :cron => :environment do
  if Time.now.hour % 3 == 0
    puts "do something every three hours"
  end

  if Time.now.hour == 0
    puts "do something at midnight"
  end
end
```

<div class="opinion">
The most modular, easily-testable way to manage recurring tasks like this is to create a separate Cron task as described by Nick
Quaranto in [Testing Cron on Heroku](http://robots.thoughtbot.com/post/7271137884/testing-cron-on-heroku).
</div>

### Setting Up SSL

[TODO: finish this]

### Automating Deployment with Kumade

Although Heroku deployment is as simple as typing `git push heroku`, over time you may want more control over the 
deployment process, or you may wish to automate other tasks like making sure migrations get run, assets
are packaged correctly (if using something like Jammit or More), and preventing deployments when your git repository is not clean. 
Thoughtbot has created a gem called [kumade](https://github.com/thoughtbot/kumade) which handles this for you. Instead of typing
`git push heroku` you type `bundle exec kumade`.

### Sending Email with Sendgrid

[TODO: finish this]
