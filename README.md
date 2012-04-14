# Configure your Heroku custom buildpack

<Explan why you need to have a custom build pack>

* Fork: https://github.com/austenito/heroku-buildpack-ruby-octopress
* In `config.yml`, edit the following:

```yaml
git_url: <The read-only url of your blog>
git_branch: <The branch your blog resides in>
```

* Run `rake setup`

This will change the following lines in [octopress.rb](https://github.com/austenito/heroku-buildpack-ruby-octopress/blob/master/lib/language_pack/octopress.rb)

```ruby
pipe("env PATH=$PATH git remote add upstream ##git_url##")
pipe("env PATH=$PATH git pull upstream ##git_branch##")
```

* Push your changes. Heroku will use this build pack to generate and deploy your blog.

# Add the post_recieve_hook on Github


# Deploy this webapp to Heroku.

This repository should be private.

* In `config.yml` add the the post_receive_hook URL you added to your blog on Github.

```yaml
git_post_receive_url: 
```

* Run the following commands:

```
rake -rakefile setup.rake
heroku create --stack cedar --buildpack <your_buildpack_fork_git_url> 
git add .
git commit -m "Your commit message"
run `git push heroku master
```

This will find and replace the post_receive_hook_url in 



* blah!

If everything was setup correctly, your blog will be deployed onto heroku. When
you push changes to your blog, 


