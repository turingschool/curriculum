# Continuous Integration

Continuous Integration (CI) is an integral component of a development team as it performs the necessary work of integrating and compiling the code within a source repository on an independent system ensuring the health of the codebase and alerts when it ceases to work correctly.

Several tenants, outlined on Wikipedia, underscore the important aspects to consider when preparing your CI environment:

* Automate the build
* Make the build self-testing
* Every commit should be built
* Keep the build fast
* Test in a clone of the production environment
* Everyone can see the results of the latest build

Outlined below is configuration of the [Jenkins](http://jenkins-ci.org/) CI build system. While written in Java, it has numerous plugins and support for Ruby and Rails projects. Also most popular ruby test frameworks provide output in [jUnit](http://www.junit.org/) XML format which is parseable by Jenkins.

## Jenkins

### Creating a Job

Generating a job requires you to define the name, define the source repository location, and specify a building interval. Refer to your source repository for this information. With regard to the interval, it is often best to specifying a fairly frequent polling interval or every change.

The most important steps to articulate is adding a build step and post build actions.

    A build step should not contain overly complicated information about the build process. If it does, consider integrating it into a Rake task or a bash script within your project so that that information is captured within your project's source repository.

#### Adding a Build Step

Within a Jenkins job you can add a `Build` step to `Execute shell` command. This allows you the ability to define a bash script to perform your build execution.

```bash
#!/bin/bash
[[ -s '/usr/local/lib/rvm' ]] && source '/usr/local/lib/rvm'
cd $WORKSPACE
bundle install
bundle exec rake db:migrate spec RAILS_ENV=test
```
Let's examine the script line-by-line:

1. Execute as a bash script

The first line informs the build system to execute the system through Bash. Without that line Jenkins execute the build step in `sh` instead of `bash`.

2. Enable RVM for the current user

RVM in this case is installed to the system and not locally to a particular user.

When RVM is installed a user is prompted to include this command in their `.bashrc` or `.bash_profile`. This may be lacking from Jenkin user's account or may be ignored when in some cases because the build user is started in a non-interactive mode ignoring some of the environment files.

3. Move into the workspace of the job

Jenkins provides a number of environment variables that can be used to provide additional instruction. $WORKSPACE is the absolute path to the workspace where the latest code is awaiting test and execution.

Jenkins provides a list of environment variables below each `Execute shell` command box. Follow the link provided by the text 'See the list of available environment variables'.

4. Install any necessary dependencies

As dependencies change or become updated the build system could become inoperable if it does not update the gems that it has installed for the project.

5. Execute a migration and execute the tests

With the environment defined by Bundler execute your `rake` script to migrate the database `db:migrate` (within the Rails Test Environment) and then execute your test suite `spec`.

While Jenkins provides a [Rake Plugin](http://wiki.hudson-ci.org/display/HUDSON/Rake+Plugin) which provides the ability to specify RVM version information and execute rake commands in a more simplified interface I have found this to be problematic and it ultimately led to instability. Setting up the rvm environment, as we did on line 2, and executing the rake command with preface `bundle exec` we ensure that it is in the correct environment.

#### Publishing Test Results

[TODO: This all depends on the testing framework to output in junit xml]

#### Adding a Documentation Step

Besides executing tests you can use Jenkins to compile documentation of your project.

```bash
#!/bin/bash
[[ -s '/usr/local/lib/rvm' ]] && source '/usr/local/lib/rvm'
cd $WORKSPACE
yard 'lib/**/*.rb' 'app/**/*.rb'
```

This step is familiar to the previous build step that we defined. After the build step finishes successfully it will continue to the next step. Here we have the application generate documentation through the [YARD](http://yardoc.org/) gem.

The following will generate output into the `doc` directory within your workspace. This documentation can be included with the Jenkin's job page with the assistance of the [DocLinks Plugin](http://wiki.hudson-ci.org/display/HUDSON/DocLinks+Plugin).

The _DocLinks Plugin_ provides a *Post-build Action* named *Publish documents* which allow you define:

* title - the name as it appears on the job page
* description - additional information about the documentation
* directory to archive - the directory where the documentation exists (in the above example `doc`).
* Index file - it assumes `index.html` which is correct for YARD but you can always specify a value.

#### Adding a Coverage Step

Providing code coverage documentation is extremely simple if you use the [simplecov](https://github.com/colszowka/simplecov) gem.

1. Add SimpleCov to your `Gemfile` with and `bundle install`:
      
        gem 'simplecov', :require => false, :group => :test

2. Load and launch SimpleCov **at the very top** of your `test/test_helper.rb` (*or `spec_helper.rb`, cucumber `env.rb`, or whatever
   your preferred test framework uses*):

        require 'simplecov'
        SimpleCov.start

        # Previous content of test helper now starts here
        
      **Note:** If SimpleCov starts after your application code is already loaded (via `require`), it won't be able to track your files and their coverage!       
      The `SimpleCov.start` **must** be issued **before any of your application code is required!**

After installation anytime that you run your test suite coverage information will be generated to `coverage/index.html`. Using the [DocLinks Plugin](http://wiki.hudson-ci.org/display/HUDSON/DocLinks+Plugin) you can easily include the generated documentation on the Jenkin's job page. 