## Bundler

The Ruby ecosystem has tens of thousands of Gem libraries we can utilize in our programs. A typical Rails application might rely on 50 libraries. In the days of Rails 2 managing these dependencies was a real challenge, especially when coordinating multiple machines and developers.

Bundler (<http://gembundler.com/>) makes most of that challenge go away. In our project we create a `Gemfile` which specifies our gem dependencies and source(s). Using that file, Bundler can resolve the complex interactions of library dependencies and install/utilize gems as needed.

### A Basic Gemfile

A very simple Gemfile might look like this:

```ruby
source :rubygems
gem 'rails'
gem 'rake'
```

From the terminal, in the project directory, we can process this Gemfile and setup the dependencies with one command:

```bash
bundle install
```

Since `install` is the default `bundle` command you can omit it, like so:

```bash
bundle
```

Bundler will attempt to utilize gems already installed on the system to meet the dependencies, fetching additional gems from the "source" (in our example: RubyGems; <http://rubygems.org/>) as needed.

### Versioning Dependencies

Most Ruby libraries move fast, some move incredibly slowly. While there are established Version Policies (<http://docs.rubygems.org/read/chapter/7>) for RubyGems, their implemention is spotty at best. Using the above Gemfile, our application would (at the time of this writing) pull down Rails version 3.0.8 and Rake 0.9.0. 

Six months from now, though, it might pull down Rails version 3.2.0. Will that break our application? Probably. So we should lock our gems down to specific versions. Adding exact versions to my above Gemfile would look like this:

```ruby
source :rubygems
gem 'rails', '3.0.8'
gem 'rake', '0.9.0'
```

#### Flexible Versioning

But what about bug and security fixes? I can build against Rails 3.0.8, but if a security issue is found they'll release a 3.0.9. The third number is called the "patch level", and when it increments it is supposed to be completely backwards compatible. 3.0.9 should introduce no issues for an app built agains 3.0.8. This rule generally holds true.

But patch levels are released every few weeks. This can make keeping the Gemfile up to date a real pain. We can add some flexibility to our dependencies with the "squiggle-rocket" operator:

```ruby
source :rubygems
gem 'rails', '~>3.0.8'
gem 'rake', '~>0.9.0'
```

Now Bundler will use Rails version 3.0.8, 3.0.9, or any patch level in the 3.0._x_ series. It will *not*, however, use 3.1.0. This is usually the ideal behavior. Upgrading the "minor" version, from 3.0 to 3.1, is likely to necessitate changes in your application.

#### Managing Edge Code

Often you'll be developing a gem while you're developing an application that uses it. Or, sometimes you'll need to use the absolute bleeding edge code for a Gem before it's released on RubyGems. In that case, Bundler can resolve dependencies directly from Git or GitHub:

```ruby
source :rubygems
gem 'rails', :git => "https://github.com/rails/rails.git"
gem 'rake', '~>0.9.0'
```

Building an application using git-based dependencies is *an extremely bad idea* unless you control the repository. The easiest way to do that is fork the repository on GitHub, then reference your fork in your Gemfile.  You can keep your fork up to date by adding the original repository as an upstream remote (<https://github.com/MarkUsProject/Markus/wiki/Gitkeepingpace>).

Unless you have a lot of time to waste and enjoy frustration, never build against edge rails as I've shown here.