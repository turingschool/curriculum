---
layout: page
title: Extending Spree
sidebar: true
---

## Setup Spree

```
rails new extending_spree
```

```
gem install spree_cmd
```

### Setup Imagemagick

```
brew install imagemagick
```

### Install Spree

```
spree install --auto-accept
```

### Try It Out

* `rails server`
* `http://localhost:3000/admin`
* `spree@example.com` / `spree123`

## Designing an Extension

* A store-wide banner
* Built with TDD

### Getting Started

```
group :development do
  gem 'rspec-rails'
  gem 'capybara'
  gem 'launchy'
end
```

```
rails generate rspec:install
rm -rf test
```

### Writing a feature spec

mkdir spec/features

```
require 'spec_helper'
describe 'the site-wide banner' do 
  context 'with an active banner' do
    let!(:banner){ Banner.create(:content => 'Everything is on sale!') }

    it "displays on the home page" do
      visit '/'
      within('.banner') do
        expect(page).to have_content(banner.content)
      end
    end
  end
end
```

rspec features

### Creating a `Banner`

rails generate model Banner content:text
rake db:migrate de:test:prepare

rspec features

### Inserting HTML

* Inspecting HTML

`<ul id="products" class="inline product-listing" data-hook="">`

* Finding the template to override:

bundle open spree_frontend

views/spree/home/index uses `views/spree/shared/_products.html.erb`

```
Deface::Override.new(:virtual_path  => "spree/shared/_products",
                     :insert_before => "ul#products",
                     :text          => "<h1>INJECTING HTML INTO YOUR PRODUCTS!</h1>",
                     :name          => "home_banner")
```

#### Adding a Bit of CSS

```
css = "border: 1px solid #FFEEE; background: #EEEEEE; padding: 5px; margin: 10px"

Deface::Override.new(:virtual_path  => "spree/shared/_products",
                     :insert_before => "ul#products",
                     :text          => "<h1 style='#{css}'>INJECTING HTML INTO YOUR PRODUCTS!</h1>",
                     :name          => "home_banner")
```

#### Outputting a Banner

```
def banner_css
  "border: 1px solid #FFEEE; background: #EEEEEE; padding: 5px; margin: 10px"
end

def styled_html_for(banner)
  "<h1 style='#{ banner_css }' id='banner'>#{ banner.content }</h1>"
end

active_banner = Banner.first

if active_banner
  Deface::Override.new(:virtual_path  => "spree/shared/_products",
                       :insert_before => "ul#products",
                       :text          => styled_html_for(active_banner),
                       :name          => "home_banner")
end
```

#### Creating a Banner in Development

Rails console:

Banner.create(:content => "Store-wide sale is on now!")

#### Run the Spec

* Fails
* Save and open page
* There are no products, so the HTML is not rendering
* Copy over the dev/sample database:

```
rails console
Banner.destroy_all
cp db/development.sqlite3 db/test.sqlite3
```

* Fails? Overrides are compiled when the tests start
* Have to rethink our strategy:

```
def erb_for_banner
  "<% active_banner = Banner.first %>
   <% if active_banner %>
      <h1 style='border: 1px solid #FFEEE; background: #EEEEEE; padding: 5px; margin: 10px' class='banner'>
        <%= active_banner.content %>
      </h1>
   <% end %>"
end

Deface::Override.new(:virtual_path  => "spree/shared/_products",
                       :insert_before => "ul#products",
                       :text          => erb_for_banner,
                       :name          => "home_banner")
```
