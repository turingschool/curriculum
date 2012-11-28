---
layout: page
title: Configuring Heroku Features
section: Small Topics
---

Earlier you learned how to deploy your app to the [Heroku](http://www.heroku.com/) platform. In this section
you'll learn how to work with various Heroku features and add-ons.

## Core Features

### Setting Configuration Variables

As your app grows it will need various pieces of configuration data to run. Some of this data will be too sensitive or change too frequently for you to be able to store it in source control. Heroku allows you to store configuration variables so that your app can configure itself in production mode. 

All apps start out with a default set of variables, which you can view with the command `heroku config`. Pay special attention to `RACK_ENV` (which determines the environment your app boots into) and `DATABASE_URL` which points at your app's database.

Read more about [Heroku configuration variables](http://devcenter.heroku.com/articles/config-vars).

### Setting Up Workers

For performance reasons, most web applications end up offloading work to worker processes that operate asynchronously, outside the context of a web request. This usually involves setting up a queueing system such as [delayed_job](http://devcenter.heroku.com/articles/delayed-job]) or [Resque](https://github.com/defunkt/resque). 

delayed_job is the more documented, simpler approach since you can use your existing relational database. Follow [Heroku's setup instructions](http://devcenter.heroku.com/articles/delayed-job) to get this running.

Note that if you are creating an app using Heroku's Cedar stack, you will need to add a worker process to the app's [Procfile](http://devcenter.heroku.com/articles/procfile), described below.

### Using the `Procfile`

Heroku's Celadon Cedar stack affords much more flexibility about what kinds of processes can be run on Heroku. A typical
web app configuration using `delayed_job` and `thin` is below:

```bash
worker: bundle exec rake jobs:work
web: bundle exec thin start -p $PORT -e $RACK_ENV
```

Read more about Procfile configuration [here](http://devcenter.heroku.com/articles/procfile).

### Scaling Dynos

As your app gets more usage you will need more processes (called dynos) to handle requests. 

Use the `ps:scale` command to increase thenumber of dynos allocated to each of the processes in your Procfile. You can specify absolute numbers like 2 for 2 total dynos, or relative numbers like +1, for one additional dyno:

{% terminal %}
$ heroku ps:scale web=2 worker+1
{% endterminal %}

The names "web" and "worker" in this case refer to the labels in your `Procfile`.

### Configuring the Rails 3.1 Asset Pipeline

If your app uses the [Rails asset pipeline](http://guides.rubyonrails.org/asset_pipeline.html), [Heroku will compile the assets for you](http://devcenter.heroku.com/articles/rails31_heroku_cedar) at deploy time using the `rake assets:precompile` task. Be sure to add these gems to the `asset` group in your Gemfile:

<div class='opinion'>
<p>This is the simplest way to get started, but eventually you may want to serve your assets from a separate host such as <a href="http://aws.amazon.com/cloudfront/">CloudFront</a>.</p>

<p>Using an asset host frees up your Heroku dynos to handle dynamic requests. You can run the precompile task yourself:</p>

<code>RAILS_ENV=production rake assets:precompile</code>

<p>which will add a <code>public/assets/manifest.yml</code> file to your app. If Heroku sees this file, it will not bother to compile your assets. You are then free to upload the compiled files to your CDN. You may wish to use the <a href="https://github.com/rumblelabs/asset_sync">asset_sync gem</a> to automate this process.</p>

<p>You'll also need to configure the asset host in your <code>config/environments/production.rb</code> file:</p>

<code>
config.action_controller.asset_host = "https://d2mfbgzuncgoal.cloudfront.net"
</code>

</div>

## Managing Data

### Exporting Data

The simplest way to export your database is the `pgbackups:url` command to get a temporarily-accessible download:

{% terminal %}
$ curl -o latest.dump `heroku pgbackups:url`
{% endterminal %}

You can also transfer data between Heroku databases using the procedure explained at the end of the pgbackups documentation.

### Importing Data

The `pgbackups:restore` command will pull data from a URL into your database like so:

{% terminal %}
$ heroku pgbackups:restore DATABASE 'http://example.com/location/of/your/dump'
{% endterminal %}

### Automating Database Backups

The [PG Backups](http://addons.heroku.com/pgbackups) add-on will perform automatic daily backups, retaining the
last 7 daily backups and 5 weekly backups. Add this to your app via:

{% terminal %}
$ heroku addons:add pgbackups:auto-month
{% endterminal %}

If you know you're about to try something sensitive, you can perform manual backups. Heroku will retain 10 of them with the default plan. Create an immediate backup using this command:

{% terminal %}
$ heroku pgbackups:capture 
{% endterminal %}

Read more about [Heroku backups](http://devcenter.heroku.com/articles/pgbackups).

### Using a Dedicated Database

Heroku apps start off using a shared database. The performance of a shared database is only acceptable for staging environments or "low-scale production applications". Once you start to see serious usage you'll want to switch to a dedicated database. This upgrade can only be done from Heroku's web U/I since a significant cost increase is involved.

## Add-Ons

### Setting Up Custom Domains

You can run your app for free at a [custom domain](http://devcenter.heroku.com/articles/custom-domains) name by running:

{% terminal %}
$ heroku addons:add custom_domains:basic
{% endterminal %}

Add the domain names like this:

{% terminal %}
$ heroku domains:add www.example.com
$ heroku domains:add example.com
{% endterminal %}

You must configure a CNAME for your domains to point to Heroku in order for this to work, as explained in detail in the [Heroku Custom Domains](http://devcenter.heroku.com/articles/custom-domains) documentation.

### Using Cron

Heroku will run short-duration daily and hourly batch jobs for you using the [Cron add-on](http://addons.heroku.com/cron). 

You need to add a rake task named "cron" to your app in `lib/tasks/cron.rake`. 

```ruby
desc "run cron jobs"
task cron: :environment do
  if Time.now.hour % 3 == 0
    puts "do something every three hours"
  end

  if Time.now.hour == 0
    puts "do something at midnight"
  end
end
```

<div class="opinion">
<p>The most modular, easily-testable way to manage recurring tasks like this is to create a separate Cron task as described by Nick
Quaranto in <a href="http://robots.thoughtbot.com/post/7271137884/testing-cron-on-heroku">Testing Cron on Heroku</a>.</p>
</div>

With this task in place, just setup the add-on:

{% terminal %}
# daily cron is free
$ heroku addons:add cron:daily

# hourly cron costs $3/month
$ heroku addons:add cron:hourly
{% endterminal %}

### Setting Up SSL

If your app requires SSL your best option is to use Heroku's [Hostname Based SSL](http://addons.heroku.com/ssl). 

Heroku offers other options but that one works for most cases, and is among the easiest to setup. You'll need to purchase an SSL certificate for your domain. Follow the direction on Heroku's [SSL documentation](http://devcenter.heroku.com/articles/ssl#customdomain_ssl_wwwyourdomaincom) in order to add the certificate to your account.

If your SSL certificate requires the use of an intermediate certificate, be sure to append that file to your `.pem` file as described in the Heroku SSL documentation.

Once the certificate is added, the SSL add-on can be activated like this:

{% terminal %}
$ heroku addons:add ssl:hostname
{% endterminal %}

You will receive an email from Heroku containing the hostname of your SSL endpoint. You will need to add a CNAME to your domain's DNS settings corresponding to this endpoint. 

### Automating Deployment with Kumade

Although Heroku deployment is as simple as typing `git push heroku`, over time you may want more control over the 
deployment process. Or you may wish to automate other tasks like running migrations, packaging assets, and preventing deployments when your git repository is not clean. 

Thoughtbot has created a gem called [kumade](https://github.com/thoughtbot/kumade) which handles this for you. With it installed, instead of `git push heroku` you deploy with `bundle exec kumade`.

### Sending Email with Sendgrid

The [Sendgrid add-on](http://addons.heroku.com/sendgrid) gives you the ability to send outbound email from your app, saving you from needing to run your own SMTP server. The free version lets you send 200 emails per day. 

Add Sendgrid using this command:

{% terminal %}
$ heroku addons:add sendgrid:free
{% endterminal %}

The [Sendgrid documentation](http://devcenter.heroku.com/articles/sendgrid) explains how to configure ActionMailer to use Sendgrid's SMTP servers, which should be done in your `config/environments/production.rb` file:

```ruby
config.action_mailer.smtp_settings = {
  address:        "smtp.sendgrid.net",
  port:           "25",
  authentication: :plain,
  user_name:      ENV['SENDGRID_USERNAME'],
  password:       ENV['SENDGRID_PASSWORD'],
  domain:         ENV['SENDGRID_DOMAIN']
}
```
