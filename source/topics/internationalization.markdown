---
layout: page
title: Internationalization
---

Internationalization is one of those things people always plan to do...eventually. We're so lazy about it, that's probably the last time you'll see anyone actually spell out the word -- instead we opt for the compressed shorthand "i18n" (which means "an 'i', then 18 letters, then an 'n'").

There a few different areas in your Rails applications which can utilize i18n:

* Model validations
* Controller flash messages
* View template content

Let's first talk about the locale file.

### Setup

{% include custom/sample_project_advanced.html %}

### Locale Files

Every Rails application has a folder `config/locales` in which you'll find an `en.yml`. Let's open that now for experimentation throughout this tutorial.

#### Locale File Structure

The locale file is written in YAML (http://www.yaml.org/), a plain-text language for writing simple data objects. The locale file makes use primarily of hashes.

##### YAML Experiments

Write a plain text file named `sample.yml` with these contents:

```yaml
student:
  first_name: "John"
  last_name:  "Smith"
  grades:
    - 88
    - 92
    - 93
  classes:
    1st_period: Science
    2nd_period: Math
```

Load an IRB session in the same directory and try the following:

{% irb %}
$ require 'yaml'
$ output = YAML.load(File.open('./sample.yml'))
$ output['student']['first_name']
{% endirb %}

Our YAML file specifies a hash with a top level key `'student'` which has a nested key `'first_name'` which holds the value `"John"`.

Figure out how, using YAML, to extract the values `"Smith"`, `92`, and `'Math'`.

##### YAML in Locale Files

The Rails i18n system is built around having a single YAML file per language. You create the file with the language identifier and a `.yml` extension under the `locales` folder.

Every locale file in a Rails app is going to have the language identifier as the root key. In the default file, that's `"en"`. Some of the most common other identifiers include `"es"` (Spanish), `"fr"` (French), and `"de"` (German).

The keys under that language identifier should, generally speaking, be **identical** across the various locale files.

##### The Big Goal

In a well-built Rails application, the locale file is the **only** place in the application where user-facing text is defined.

### Determining Locale / Language

There's often a correlation between country and language preference, but it's naive to consider one indicative of the other.

A well built solution will detect the language the user *probably* wants and allows them to override that choice. Let's look at some methods of determining and tracking a user's locale code.

#### Geolocation

You could use a geolocation service to determine a user's location and set the language accordingly. Don't ever do this, seriously.

#### HTTP Headers

One of the simplest solutions is built right into the HTTP 1.1 spec. Browsers will, with each request, submit a header named `"HTTP_ACCEPT_LANGUAGE"`.

The value under that name can be a single locale identifier or a comma-separated list of preferences. These are set by the browser at either install or load time and are likely detected from the host operating system. The user can typically override this setting somewhere in the browser configuration, but they probably don't know how.

If you're dealing with *public, unauthenticated users*, reacting to the `"HTTP_ACCEPT_LANGUAGE"` is your best bet.

##### Seeing the `HTTP_ACCEPT_LANGUAGE`

Assuming you have the sample project available and running, go to `ArticlesController#index` and add this exception:

```ruby
def index
  raise request.env["HTTP_ACCEPT_LANGUAGE"]
  @articles, @tag = Article.search_by_tag_name(params[:tag])
end
```

You'll probably see this output:

```
en-US,en;q=0.8
```

My browser is saying that my top choice locale is `"en-US"` (US English), but I'll settle for `"en"` (English) and consider that about 80% as good as the first choice.

##### Which Locales are Available?

From a Rails console, try this:

```ruby
I18n.available_locales
```

Most of those represent validation error messages and such that are built in to Rails.

Let's try an experiment. Create a file `config/locales/arr.yml` with this content:

```yaml
arr:
  hello: "Ahoy, Matey!"
```

Then *Exit* your Rails console session, start it again, and run `I18n.available_locales` again. You should now see `:arr` available.

##### A Recommendation

Unless you have a compelling case for it, build your app using one, two, or three locales. Don't try and support everything from the beginning, you'll just make a mess and do a bunch of unnecessary work. If everything is extracted to work from locale files correctly, then adding new languages as you prepare to ship is very easy.

#### Setting the Locale via HTTP Headers

Let's implement a `before_filter` which will set the current locale based on the request's HTTP headers. In `ApplicationController`:

```ruby
class ApplicationController < ActionController::Base
  before_filter :set_locale

private

  def set_locale
    I18n.locale = LocaleSetter.from(request.env["HTTP_ACCEPT_LANGUAGE"])
  end
end

module LocaleSetter
  def self.from(accepts)
    (accept_list(accepts) & I18n.available_locales).first
  end

  def self.accept_list(accepts)
    accepts.downcase.gsub(/\;q=\d[.\d]*/, "").split(",").map(&:to_sym)
  end
end
```

Check out the results from a controller by calling:

```ruby
raise I18n.locale.inspect
```

#### Overriding the Locale

It would be nice to be able to override the locale from the URL parameters. Imagine in testing, for instance, that we want to easily flip between languages.

Let's modify that earlier approach:

```ruby
class ApplicationController < ActionController::Base
  before_filter :set_locale

private

  def set_locale
    I18n.locale = LocaleSetter.from_param(params[:locale]) ||
                  LocaleSetter.from_http(request.env["HTTP_ACCEPT_LANGUAGE"])
  end
end

module LocaleSetter
  def self.from_param(param)
    if param
      locale = sanitize_param(param)
      I18n.available_locales.include?(locale) ? locale : false
    end
  end

  def self.sanitize_param(param)
    param.downcase.to_sym
  end

  def self.from_http(accepts)
    (accept_list(accepts) & I18n.available_locales).first
  end

  def self.accept_list(accepts)
    accepts.downcase.gsub(/\;q=\d[.\d]*/, "").split(",").map(&:to_sym)
  end
end
```

Now setting the locale in the URL (like `http://localhost:3000/articles?locale=arr`) will override the HTTP header.

#### Appending the Locale to All URLs

The above approach generally works, but when you click any link on the site it'll drop the locale.

Instead, let's embed the locale parameter into every URL. All Rails URL helpers make use of the `url_for` method, which itself calls a method named `default_url_options`. If we override that method, we can set the option for every URL.

In our `ApplicationController`:

```ruby
def default_url_options(options = {})
  { locale: I18n.locale }.merge(options)
end
```

That's it!

#### Account-Based Locale

When a user registers with your system, you should store their preferred locale in the user record. Whenever they login, regardless of the HTTP header, use the locale stored in their profile. Allow them to change it along with their other attributes.

Why bother with this? I am always going to prefer English, whether I'm using my machine from the US or using a friend's machine in France. Do the smart thing.

#### `locale_detector`

Thinking this is too much work? You might try out https://github.com/Exvo/locale_detector which at least takes care of the HTTP header part for you.

### Model Validations

Ok ok, we've set the locale. Now what can we **do** with it?

Let's put this into practice at the model layer.

#### The `:message` Option

The built in validations have an infrequently used option `:message` like this:

```ruby
validates_presence_of :title, message: "needs a title genius"
```

Now that you know it's there, **don't ever use this**.

Why? The concept of a validation error is a business-logic-level concern and it totally belongs in the model. The specific message that explains the error, however, has *nothing* to do with business logic and it's absolutely wrong to put it in the model layer.

#### Validation Messages in Translation Files

Instead, define your validation messages in the locale files.

Rails will attempt several lookups in your locale file automatically. The first hit will be used. The lookup order is:

```
activerecord.errors.models.[model_name].attributes.[attribute_name]
activerecord.errors.models.[model_name]
activerecord.errors.messages
errors.attributes.[attribute_name]
errors.messages
```

To really understand how this works, you need to pull up the Rails guide here: http://guides.rubyonrails.org/i18n.html#translations-for-active-record-models

##### An Example with Article Validation in Arr

I want to deal with the case where a pirate attempts to write an article without a title. The model already has this validation:

```ruby
validates :title, presence: true, uniqueness: true
```

To figure out what key I need to define, I look at the hierarchy above. Let's first make the message specific just to this model/attribute, then look at how we could generalize it.

I want to match this pattern:

```
activerecord.errors.models.[model_name].attributes.[attribute_name]
```

Which here is:

```
activerecord.errors.models.article.attributes.title
```

But I need to get specific about which validation message I'm supplying. If you've pulled up the documentation linked above, scroll down to the heading "5.1.2 Error Message Interpolation" and look at the table.

Find `presence` on the third line. The `message` column lists the key `:blank`. Therefore, the locale lookup path for our title blank message is:

```
activerecord.errors.models.article.attributes.title.blank
```

Easy-peasy! You'll have to look up this documentation every time you want to use the feature, guaranteed. :)

Here's how to write it in `arr.yml`:

```yaml
arr:
  hello: "Ahoy, Matey!"

  activerecord:
    errors:
      models:
        article:
          attributes:
            title:
              blank: "Ye title musn't be blank, varmit!"
```

Then try it out in your Rails console:

{% irb %}
$ I18n.locale = :arr
 => :arr
$ a = Article.new(body: "Arrr!")
 => #<Article id: nil, title: nil, body: "Arrr!", created_at: nil, updated_at: nil>
$ a.save
 => false
$ a.errors.full_messages
 => ["Title translation missing: arr.activerecord.errors.models.article.attributes.title.blank"]
{% endirb %}

Say whaaaat? Oh, there's this little wrinkle: locale files are parsed at starup. You need to stop/restart your console and/or server to see the difference. Try it again and you should see this:

{% irb %}
$ a.errors.full_messages
=> ["Title Ye title musn't be blank, varmit!"]
{% endirb %}

That's awesome as long as we don't need our messages to make sense.

##### Note on Outputting Messages

This part is particularly icky. If you use the `full_messages` method like the example above, as far as I can tell, you're always going to get the attribute name appended to the front of the error message.

The solution, when you go to output the error messages, is to do something like this:

```ruby
a = Article.new(body: "Making Errors")
a.save
a.errors.collect{|e| e.last}
```

#### Abstracting Validation Messages

Earlier we saw the lookup chain that would be followed and chose the most specific case for our `Article#title`. If you have many models, though, it's probably a huge pain and unwise to rewrite the same validation message several times in the locale file.

Let's go further down the chain. To remind you, the priorities are:

```
activerecord.errors.models.[model_name].attributes.[attribute_name]
activerecord.errors.models.[model_name]
activerecord.errors.messages
errors.attributes.[attribute_name]
errors.messages
```

The top-two are specific to a single model, but the bottom three are more general. Here's how we could reappropriate our translation about the title to all presence validations in the locale:

```yaml
arr:
  hello: "Ahoy, Matey!"

  activerecord:
    errors:
      messages:
        blank: "Ye title musn't be blank, varmit!"
```

But that's going to complain about the `title` even when the validation is on the `body`. Instead, we use a special interpolation syntax:

```yaml
arr:
  hello: "Ahoy, Matey!"

  activerecord:
    errors:
      messages:
        blank: "Ye %{attribute} musn't be blank, varmit!"
```

##### Localizing Attributes

That's great until you implement your Spanish translation like this:

```yaml
es:
  hello: "Buenos Dias!"

  activerecord:
    errors:
      messages:
        blank: "Necessita un %{attribute}!"
```

Then your user gets the message `"Necessita un title"` instead of `"Necessita un titulo"`. You need to specify how the `title` attribute should be localized. You'd add it to the locale file like this:

```yaml
es:
  hello: "Buenos Dias!"

  activerecord:
    errors:
      messages:
        blank: "Necessita un %{attribute}!"
    attributes:
      article:
        title: "titulo"
```

Now your user will get the correct message and attribute name.

### Controllers & Views

You're probably convinced that I18n is hard. The above ActiveRecord hoops are a bit much to jump through, but *much* of what you need to internationalize is easy to work with.

#### The `t` Helper

In your controllers and views you have access to a helper named `t`. You supply a key to `t` and it fetches the value from the current locale file. Nothing fancy to remember.

##### Example Flash Message

Returning to Pirate:

```yaml
arr:
  articles:
    not_found: "Arr, thy article has jumped ship!"
```

Then in my `ArticlesController`:

```ruby
def show
  @article = Article.find(params[:id])
  unless @article
    flash[:warning] = t 'articles.not_found'
    redirect_to articles_path
  end
end
```

You use a dot notation to navigate through the YAML hierarchy to whatever key you want.

##### Interpolating Arbitrary Values

You can also interpolate arbitrary values into messages. Imagine you want to do something like this:

```yaml
arr:
  articles:
    not_found: "Foolish %{user}, thy article has jumped ship!"
```

Then you pass in the data like this:

```ruby
flash[:warning] = t 'articles.not_found', user: current_user.name
```

*Minor note:* the keys `:default` and `:scope` may not be used here.

### Topics We Haven't Covered

Internationalization goes deeper than you'd think. Here are some other areas of interest that you can read about in the guide/API:

* Pluralization
* Dealing with Dates & Times
* Handling Exceptions (like missed lookups)

### References

* Rails I18n Guide: http://guides.rubyonrails.org/i18n.html
