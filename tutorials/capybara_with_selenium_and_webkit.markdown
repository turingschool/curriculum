h3. Driving with Selenium

By default Capybara uses @Rack::Test@ which is a headless browser emulator. It gives us great speed, but we sacrifice the ability to run JavaScript. If you need to test JS as part of your integration suite, then you need Selenium.

If you have Firefox installed then there are no extra setup steps. You can use Chrome or a Webkit-based browser, but it takes a little more setup and varies by platform.

h4. Activating Selenium

It's actually really easy to make your tests use a real browser. Here is the way I do it:

* Create a @describe@ block that contains the examples that need JavaScript
* Add a before-all block like this:

```ruby
  before(:all) do
    Capybara.current_driver = :selenium
  end
```

* Add an after-all block like this:

```ruby
  after(:all) do
    Capybara.use_default_driver
  end
```

There are short-hand flags that are supposed to work with just a single test, but I believe they're not working in the current gem of Capybara.

h4. Selenium Methods

If you're just triggering AJAX actions via JavaScript you can probably get by with the normal Capybara actions. But Selenium itself has many actions that are not directly supported by Capybara.

But that's ok! If you ask Capybara for @page.driver.browser@ while in a Selenium-powered test, it'll give you the @Selenium::WebDriver::Driver@ object. You can then access any Selenium method according to the API here: 

"http://selenium.googlecode.com/svn/trunk/docs/api/rb/Selenium/WebDriver/Driver.html":http://selenium.googlecode.com/svn/trunk/docs/api/rb/Selenium/WebDriver/Driver.html

h4. Experimenting with JavaScript

Here's a complete example of how you could use Selenium to check that an alert pops up when we attempt to delete an article:

```ruby
  describe "on the show page for an article" do
    before(:all) do
      Capybara.current_driver = :selenium
    end
    
    before(:each) do
      @article = @articles.first
      visit article_path(@article)
    end
    
    it "should pop-up a confirm dialog when we click delete" do
      page.click_link("Delete")
      dialog = page.driver.browser.switch_to.alert
      dialog.text.should == "Delete '#{@article.title}'?"
      dialog.dismiss
    end    
  end
```