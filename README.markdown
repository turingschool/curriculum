# Jumpstart Lab Curriculum

## Installation

### Ruby

Using RVM or rbenv, visit the project directory and the tool will guide you through installation. On ubuntu, system ruby-1.9.3-p290 works fine.

### Gems

```bash
bundle
```

### Authoring and Editing Content

#### View

```
bundle exec rake preview
```

Generates the content and then lauches a Sinatra web application. 


In your browser visit [localhost:4000](http://localhost:4000) or execute `open http://localhost:4000` to lauch the browser.

> Note: This project contains a lot of content so the initial generation will delay the initial startup of the webservice for a few seconds. Saved changes to the content will cause Jekyll to re-generate all of the content causing a delay before it is displayed in the browser. Ensure any caching is disabled.


#### Create

```
bundle exec rake new_page["source/path/to/new/page.markdown"]
```

This will generate a page file at the specified location. All content that is created should be placed within the source path.

> Note: Content pages should have the extension `.markdown` as the feedback link mechanism depends on that for creating the correct links to Github.


## Online

Visit [http://tutorials.jumpstartlab.com](http://tutorials.jumpstartlab.com)

### License

<p>Unless otherwise noted, all materials licensed <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/3.0/">Creative Commons Attribution-NonCommercial-ShareAlike 3.0</a>&nbsp;<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/3.0/"><img alt="Creative Commons License" style="border-width:0" src="http://i.creativecommons.org/l/by-nc-sa/3.0/80x15.png" /></a></p>

