## Practice

h3. Practicing with RSpec and Capybara

We'll use a version of my JSBlogger project to demonstrate these tools. Check out the code from GitHub and get it ready for development:

```text
  git clone git://github.com/jcasimir/jsblogger.git  
  cd jsblogger
  bundle
```

h4. Browsing the Project

Take a minute to scope out the codebase, boot the server, and experiment with the workflow of creating Articles and Comments.

Look at the @Gemfile@ and you'll see that @rspec-rails@ and @capybara@ are set as dependencies in development and test environments. There's also a hidden @.spec@ file in the root directory that tell our app to use RSpec.

Kick off the existing unit tests with

```text
  rake
```

You should have nine unit tests passing.

h4. Fabrication

I've use a gem named *Fabrication* by our friend Paul Elliot. You can learn more about it here: "https://github.com/paulelliott/fabrication":https://github.com/paulelliott/fabrication

You can check out the fabrication definition in @/spec/fabricators/article_fabricator.rb@. The important take-aways are that you can use the following:

* @Fabricate(:article)@ to create a sample article
* @Fabricate(:article_with_comments)@ to create a sample article with three attached comments

All samples a pre-filled with "Lorem Ipsum" text to pass validations.

Try experimenting with them in the console!

h4. Setup for Integration Tests

Look in the @spec@ folder and you'll see an existing @models@ folder.  Let's create a new folder named @spec/integration@ where we'll store our new examples.  

Then within that folder create a file named @article_views_spec.rb@. Start with this framework:

```ruby
  require 'spec_helper'
  require 'capybara/rspec'

  describe "the articles interface" do

  end
```

The @require@ lines load up our existing RSpec helper file and the Capybara library's RSpec (Steak-style) integration. Run @rake@ and there should still just be 9 tests passing.

h4. Writing a First Example

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