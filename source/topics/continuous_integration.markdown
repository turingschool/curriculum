---
layout: page
title: Continuous Integration with Jenkins
section: Small Topics
---

The use of Continuous Integration (CI) is an integral aspect of any team's development efforts.  A CI tool performs the necessary work of integrating and compiling the code within a source repository on an independent system.  The CI tool then ensures the health of the code base and sends alerts when the code base ceases to work correctly.

As outlined on [Wikipedia](http://en.wikipedia.org/wiki/Continuous_integration), several tenets make up the core philosophy of a proper CI environment:

* Automation of builds
* Self-testing of builds
* Building of every commit
* Emphasizing build speed
* Testing in a clone of the production environment
* Publishing the results of the latest build

Below is a configuration outline for use of the [Jenkins](http://jenkins-ci.org/) CI build system. While written in Java, Jenkins has numerous plugins which enable support of Ruby and Rails projects. Also, most popular Ruby test frameworks provide output in the [jUnit](http://www.junit.org/) XML format which is parseable by Jenkins.

## Jenkins

### Creating a Job

Generating a job requires you to:

#### Give your job a Name and description

Select a name that clearly defines what the job is building or executing so that the purpose of the build task is absolutely clear to you and other individuals.

#### Specify the type and location of source repository

Jenkins provides support for several source control systems including CVS, SVN, Mercurial, and Git. 

#### Specify a build interval

When first starting with CI, it is best to build on every change.

#### Define your job build steps and post-build steps

The most important parts of the job are the build step and the post-build actions.

Remember that the information stored in the Jenkins job is not part of the source code within your project. If the job defines complicated or complex build steps or scripts consider consolidating them into a script within the project's source code. This will allow you to update, track changes, and more easily port your project to different build systems.

#### Adding a Build Step

Within a Jenkins job you can add a `Build` step to the `Execute shell` command. This gives you the ability to define a bash script to perform your build execution.

```bash
#!/bin/bash
[[ -s '/usr/local/lib/rvm' ]] && source '/usr/local/lib/rvm'
cd $WORKSPACE
bundle install
bundle exec rake db:migrate spec RAILS_ENV=test
```

Let's examine this script line-by-line:

1. The first line informs Jenkins to execute the build step as a bash script.

2. Enable RVM for the current user. RVM in this case is installed at the system-level and not locally to a particular user. When RVM is installed at the system-level, users are prompted to include this command in their `.bashrc` or `.bash_profile`. In some cases, the Jenkins user account may be missing this line. It may also be ignored in some cases because the build user is started in a non-interactive mode, ignoring some of the environment files.

3. Move into the workspace of the job. The Jenkins user that is executing the script starts within the home of that particular job's directory. This is sometimes, but not always the same directory that Jenkins refers to as the $WORKSPACE. Here we are ensuring that the Jenkins user is within the directory where the recently updated source code is present. Jenkins provides a number of environment variables that can be used as part of jobs. There are a list of environment variables below the `Execute shell` command box. Follow the link provided by the text 'See the list of available environment variables'.

4. Install any necessary dependencies. As dependencies change or become updated, builds may fail if Jenkins does not update the gems that it has installed for the project.

5. Execute a database migration and then the project's tests. With the environment defined by Bundler, execute your `rake` script that first migrates the database, `db:migrate`, and then execute your test suite `spec`.

#### Adding a Documentation Step

In addition to executing tests, you can use Jenkins to compile documentation for your project.

```bash
#!/bin/bash
[[ -s '/usr/local/lib/rvm' ]] && source '/usr/local/lib/rvm'
cd $WORKSPACE
yard 'lib/**/*.rb' 'app/**/*.rb'
```

The script in this step is similar to the script in the previous build step. After the build finishes successfully, Jenkins will continue on to the documentation step. In this step, we have the application generate documentation with the [YARD](http://yardoc.org/) gem.

This documentation step will generate output in the `doc` directory within your workspace. This documentation can be included on the Jenkins job page by using the [DocLinks Plugin](http://wiki.hudson-ci.org/display/HUDSON/DocLinks+Plugin).

The _DocLinks Plugin_ provides a *Post-build Action* named *Publish documents* which allow you define:

* title - the name as it appears on the job page
* description - additional information about the documentation
* directory to archive - the directory where the documentation exists (in the above example `doc`)
* index file - it assumes `index.html` which is correct for YARD; other values may be specified

#### Adding a Coverage Step

Providing code coverage documentation is extremely simple if you use the [SimpleCov](https://github.com/colszowka/simplecov) gem.

1. Add SimpleCov to your `Gemfile` and then `bundle install`:

```ruby
gem 'simplecov', require: false, group: :test  
```

2. Load and launch SimpleCov *at the very top* of your `test/test_helper.rb`:

```ruby
require 'simplecov'
SimpleCov.start
```
        
When running your test suite coverage after installation of SimpleCov, coverage information will be placed in `coverage/index.html`. Using the [DocLinks Plugin](http://wiki.hudson-ci.org/display/HUDSON/DocLinks+Plugin) you can include the generated documentation on the Jenkins job page.
