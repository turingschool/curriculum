# Practicing with Capybara

Let's put these techniques to work!

## Setup

### Fetch the Starter Code

For this tutorial, we'll make use of a version of the JSBlogger sample application. Clone the repository and checkout the `starting_capybara` tag:

```console
git clone git://github.com/jcasimir/rails_components.git
git checkout starting_capybara
git checkout -b my_capybara
bundle
```

Run `bundle exec rake` and all the existing tests should be passing. Then try running `guard` to automatically watch your tests and files for changes.

Open a second terminal, start a server, and load http://127.0.0.1:3000/

### Dependencies

Open the `Gemfile` and observe that `capybara` already exists in the `development` dependencies group. That's all you need for now.

### Fabricators

Notice that `spec/fabricators` is already setup with an Article fabricator. We can then, in our examples, utilize them like this:

```ruby
Fabricate(:article)                # Creates a sample article
Fabricate(:article_with_comments)  # Creates a sample article with three attached comments
```

### Setup for Integration Tests

Look in the `spec` folder and you'll see existing `models` and `fabricators` folders.  Let's create a new folder `spec/integration` where we'll store our new examples.  

## Writing Examples

We're ready to start testing! Create a file `spec/integration/article_views_spec.rb`, starting with this framework:

```ruby
  require 'spec_helper'
  require 'capybara/rspec'

  describe "the articles interface" do

  end
```

The `require` lines load up our existing RSpec helper file and the Capybara library's RSpec (Steak-style) integration. Your `guard` should notice the new file, run it, and the existing tests should still be passing.

### A First Example

Let's first setup some sample data.  Create a @before(:all)@ block like this:

```ruby
  require 'spec_helper'
  require 'capybara/rspec'

  describe "the articles interface" do
    before(:all) do
      @articles = []
      3.times{ @articles << Fabricate(:article) }
    end
  end
```

h4. Add the Example

Let's check that the index page lists each of the article titles:

```ruby
  it "should list the article titles on the index" do
    visit articles_path
    @articles.each do |article|
      page.should have_content(article.title)
    end
  end
```

Run @rake@ and the test should pass. We have no idea if it passed for the right reason, though. Hop over to the @/views/articles/index.html.erb@ and change

```ruby
  <%= link_to article.title, article_path(article) %>
```

to this:

```ruby
  <%= link_to "X", article_path(article) %>
```

Now run the example and it should *fail* because the index page is not showing the article titles.

Undo the change to @index.html.erb@ and re-run the example. Everything should be green.

h4. Being More Specific

The @have_content@ matcher has a wide scope: it just checks that the words appear somewhere on the page.  Let's get a little more specific.

First, let's sabotage that @index.html.erb@ again, changing the link line to just output the title:

```ruby
  <%= article.title %>
```

Run your existing example and it should still pass.  

Now let's together write a second example that makes sure each title is a link by using the @have_link@ matcher. Run the example and it should *fail*, then reinstate the line of the @index@ template, run the example, and it should go *green*.

h4. Refactoring our Examples

Both our examples' names end in @"on the index"@ and they both start by visiting the same page. This shows that we need to extract a nested context. Refactor your examples so they look like this:

```ruby
  describe "the articles interface" do
    before(:all) do
      @articles = []
      3.times{ @articles << Fabricate(:article) }
    end

    describe "on the index page" do
      before(:each) do
        visit articles_path
      end

      it "should list the article titles" do
        @articles.each do |article|
          page.should have_content(article.title)
        end
      end

      it "should have links for the articles on the index" do
        # Your implementation here
      end    
    end
  end
```

Run your examples and they should *pass*.



(has_link)...
We could use this in our existing example!

In your @"should have links for the articles"@ add the option @:href@ so it checks that the link points to the @show@ action for that article.



h3. Group Practice

So you've taken a tour of the features available, let's put them into practice. Together let's write examples that demonstrate these behaviors:

* When on the index page
** clicking the link for an article takes me to the show page for that article
** there is a link with the CSS ID @"new_article"@
** clicking on the new link takes me to the new article form
* When on the new article form
** submitting the form with no data is rejected because of validations
** when I fill in the form with valid data and submit the form, I see the show page and it has that same data

h3. Individual Practice

These exercises should require little or no modification to the underlying Rails code. It is recommended that you experiment with commenting out sections of the existing code to make sure the test fails, then bring it back to make the test pass.

* When on the article show page
** The title is displayed in H1 tags
** There is an link that reads "edit"
** When I click the edit link I go to the edit form
** Clicking the delete link should take me to the index page and the article should not appear. You'll need to click "OK" on the alert!
* When on the edit form
** Making no changes then clicking submit should take me to the show page for that article
** Removing the title and clicking submit should keep me on the edit form
** Making a change to the title and clicking save should go to the show and have the new title
** Changing the title so it duplicates another article should prevent saving

h3. Extensions

These exercises are a little trickier and may require modifying the underlying Rails application:

* When on the article show page
** it should display each of the comments associated with the article
** it should have a form for entering in a new comment
** when I click submit without filling out the comment form, it should display the article show page without a new comment added
** when I fill in the comment form with valid data and click submit, it should display the article show page and the comment should be there

h3. Harder Extensions

These may include adding significant functionality to the Rails application itself or the Fabricators:

* When on the article show page
** each comment should have a "delete" link
** clicking the delete link for a comment should remove only that comment and bring us back to the show page
** when there is a single comment, the heading should say "1 Comment"
** when there are multiple ("X") comments, the heading should say "X Comments"
* When on the articles index page
** Clicking a tag should show only articles with that tag
** A tag should not appear in the list if it has no associated articles