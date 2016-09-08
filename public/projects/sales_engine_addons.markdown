#### NOTE:

Reference [this article by Yehuda Katz](http://yehudakatz.com/2010/04/02/using-gemspecs-as-intended/) as a starting point for familiarizing yourself with gemspec files.

### Performance

All projects will be assessed for performance. The rankings will be made based first on "Correctness" points awarded, then by the average speed of three test runs. 

These runs will only run our distributed evaluation test suite, not your individually created tests.

### Evaluation

6. Recognize Others
  * Each team may award a total of two points to any person or split among two persons as a "thank you" for exceptional help or support.

## ETC

* Tracker Evaluation
* Integrate CI
* Use Sequel
* Allow incoming data in one ZIP
* Rip test harness out to a gem
* Class Variables (`@@`)
* All classes are inside a namespace named `SalesEngine`
* Your root folder should have no Ruby files (`Rakefile`, `Gemfile`, and such do not count)
* The `lib` folder of your project has only one Ruby file, `sales_engine.rb` which provides at least the `SalesEngine.startup` mentioned below.
* All other ruby files are stored under `lib/sales_engine/`

Your code should be installable as a gem.

* You will need to have a Gem specification file in the root of the project named sales_engine.gemspec.
* The gemspec file must include both author names, must ensure that all needed files are included, and any external dependencies are declared.
* Do *not* push your gem out to rubygems.org
