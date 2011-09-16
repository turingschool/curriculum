# Continuous Integration

The use of Continuous Integration (CI) is an integral aspect of any teams' development efforts.  A CI tool performs the necessary work of integrating and compiling the code within a source repository on an independent system.  The CI tool then ensures the health of the code base and sends alerts when the code base ceases to work correctly.

[TODO: Do we want a link to the wikipedia CI page?]

As outlined on Wikipedia, several tenets make up the core philosophy of a proper CI environment:

* Automation of builds
* Self-testing of builds
* Building of every commit
* Emphasizing build speed
* Testing in a clone of the production environment
* Publishing the results of the latest build

Below is a configuration outline for use of the [Jenkins](http://jenkins-ci.org/) CI build system. While written in Java, Jenkins has numerous plugins which enable support of Ruby and Rails projects. Also, most popular ruby test frameworks provide output in the [jUnit](http://www.junit.org/) XML format which is parseable by Jenkins.

## Jenkins

### Creating a Job

[TODO: The name of what? The name of the project? Of the job? Of the repository?]

Generating a job requires you to define the name, define the source repository location, and specify a building interval. Refer to your source repository for this information. When first starting with CI, it is often best to specify a fairly frequent polling interval, or simply build on every change.

The most important parts of the job are the build step and the post-build actions.

Remember that builds are, in theory, not part of the source code of your project.  If builds become overly complicated, consider integrating them into Rake tasks or bash scripts within your project so that these important processes are captured within your project's source repository.

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

1. Execute as a bash script

[TODO: verify that you really mean "sh instead of bash", as most Linux systems and Mac appear to have sh/bash as the same executable]

The first line informs Jenkins to execute the build through Bash. Without that line, Jenkins would execute the build step in `sh` instead of `bash`.

2. Enable RVM for the current user

RVM in this case is installed at the system-level and not locally to a particular user.

When RVM is installed at the system-level, users are prompted to include this command in their `.bashrc` or `.bash_profile`. In some cases, the Jenkins user account may be missing this line. It may also be ignored in some cases because the build user is started in a non-interactive mode, ignoring some of the environment files.

3. Move into the workspace of the job

Jenkins provides a number of environment variables that can be used as part of jobs. $WORKSPACE is the absolute path to the workspace where the latest code is awaiting test and execution.

[TODO: This just feels funny but I've never used Jenkins so someone else may want to verify this makes sense]

Jenkins provides a list of environment variables below each `Execute shell` command box. Follow the link provided by the text 'See the list of available environment variables'.

4. Install any necessary dependencies

As dependencies change or become updated, builds may fail if Jenkins does not update the gems that it has installed for the project.

5. Execute a migration and execute the tests

With the environment defined by Bundler, execute your `rake` script to migrate the database (`db:migrate` within the Rails Test Environment) and then execute your test suite `spec`.

[TODO: It what?  We ensure the migrate is executed in the correct environment? The test suite execution? Both?]

Jenkins has a [Rake Plugin](http://wiki.hudson-ci.org/display/HUDSON/Rake+Plugin) which provides the ability to specify RVM version information and to execute rake commands in a more simplified interface. Using this is sometimes problematic and it ultimately can lead to instability. By setting up the rvm environment, as we did on line 2, and executing the rake command with the prefix `bundle exec`, we ensure that it is in the correct environment.

#### Publishing Test Results

[TODO: This all depends on the testing framework to output in jUnit XML]

#### Adding a Documentation Step

In addition to executing tests, you can use Jenkins to compile documentation for your project.

```bash
#!/bin/bash
[[ -s '/usr/local/lib/rvm' ]] && source '/usr/local/lib/rvm'
cd $WORKSPACE
yard 'lib/**/*.rb' 'app/**/*.rb'
```

The script in this step is similar to the script in the previous build step. After the build step finishes successfully, Jenkins will continue on to the documentation step. In this step, we have the application generate documentation with the [YARD](http://yardoc.org/) gem.

This documentation step will generate output in the `doc` directory within your workspace. This documentation can be included on the Jenkins job page by using the [DocLinks Plugin](http://wiki.hudson-ci.org/display/HUDSON/DocLinks+Plugin).

The _DocLinks Plugin_ provides a *Post-build Action* named *Publish documents* which allow you define:

* title - the name as it appears on the job page
* description - additional information about the documentation
* directory to archive - the directory where the documentation exists (in the above example `doc`)
* index file - it assumes `index.html` which is correct for YARD; other values may be specified

#### Adding a Coverage Step

Providing code coverage documentation is extremely simple if you use the [SimpleCov](https://github.com/colszowka/simplecov) gem.

1. Add SimpleCov to your `Gemfile` and then `bundle install`:
      
        gem 'simplecov', :require => false, :group => :test

2. Load and launch SimpleCov **at the very top** of your `test/test_helper.rb` (*or `spec_helper.rb`, cucumber `env.rb`, or whichever file your preferred test framework uses*):

        require 'simplecov'
        SimpleCov.start

        # Previous content of test helper now starts here
        
      **Note:** If SimpleCov starts after your application code is already loaded (via `require`), it will not be able to track your files and their coverage!       
      The `SimpleCov.start` **must** be issued **before any of your application code is required!**

When running your test suite coverage after installation of SimpleCov, coverage information will be placed in `coverage/index.html`. Using the [DocLinks Plugin](http://wiki.hudson-ci.org/display/HUDSON/DocLinks+Plugin) you can easily include the generated documentation on the Jenkin's job page.