# Configure your Heroku custom buildpack

If everything was setup correctly, your blog will be deployed onto heroku. Any changes pushed to your blog's URL will 

* Fork: https://github.com/austenito/heroku-buildpack-ruby-octopress
* In `config.yml`, edit the following:

**git_url** - The *read only* URL of the blog you want to deploy on Heroku.
**git_branch** - The branch your blog resides in.

* Run `rake setup`

This will change the following lines in [octopress.rb](https://github.com/austenito/heroku-buildpack-ruby-octopress/blob/master/lib/language_pack/octopress.rb)

```ruby
pipe("env PATH=$PATH git remote add upstream ##git_url##")
pipe("env PATH=$PATH git pull upstream ##git_branch##")
```

* Push your changes. When you deploy this repository on Heroku will pull this buildpack to setup and generate your blog.

# Add the post_recieve_hook on Github


# Deploy this webapp to Heroku.

This repository should be private.

* In `config.yml` add the the post_receive_hook URL you added to your blog on Github.

```yaml
git_post_receive_url: 
```

* Run the following command to apply your post receive hook URL.

```
rake -rakefile setup.rake
```

This will find and replace the post_receive_hook_url in [server.rb](https://github.com/austenito/octopress-heroku-autodeploy/blob/master/server.rb)

```ruby
get /##git_post_receive_url##/ do
```

* Deploy your blog!

```
heroku create --stack cedar --buildpack <your_buildpack_fork_git_url> 
git add .
git commit -m "Your commit message"
run `git push heroku master
```

Profit!


