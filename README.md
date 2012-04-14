This Sinatra web app is used to update your [Octopress](https://github.com/imathis/octopress) blog automatically. When you make
change to your blog and push up to Github, your changes will be pulled down and your blog will be regenerated.

Slick! Nothing is free, so you'll have to do a bit of configuration.


# Configure your Heroku custom buildpack

1. Fork: https://github.com/austenito/heroku-buildpack-ruby-octopress
2. In `config.yml`, edit the following:
  * **git_url** - The *read only* URL of the blog you want to deploy on Heroku.
  * **git_branch** - The branch your blog resides in.
3. Run `rake setup`
4. Push your changes. When you deploy this repository on Heroku will pull this buildpack to setup and generate your blog.

# Add the Post-Receive URL on Github

In the `Admin` section of your blog's Github repo add a post-receive URL. For example, `http://www.jumpstartlab.com/generate`. A POST request will be submitted whenever you commit changes to your blog. This is how the server will pull your blog's latest changes from Github and generate the new static content.

For security, you may want to generate a hash string that will be difficult for people to guess.

![Github Post-Receive Section](https://img.skitch.com/20120414-j1fhk2mwei7e4u7n4bxg5y2ubt.jpg)


# Deploy to Heroku.

1. Clone this repository.
2. In `config.yml` add the **relative** post-receive URL you added in the admin section of your blog on Github. Using the example above: `generate`
                                      
3. Run `rake -rakefile setup.rake`
4. Deploy your blog!


```
heroku create --stack cedar --buildpack <your_buildpack_fork_git_url> 
git add .
git commit -m "Your commit message"
run `git push heroku master
```
5. **Profit!**


# Notes

* Running `rake setup` in your buildpack repository changes the following lines in [octopress.rb](https://github.com/austenito/heroku-buildpack-ruby-octopress/blob/master/lib/language_pack/octopress.rb)

```ruby
pipe("env PATH=$PATH git remote add upstream ##git_url##")
pipe("env PATH=$PATH git pull upstream ##git_branch##")
```

* Running `rake -rakefile setup.rake` in this repository finds and replaces the post_receive_hook_url in [server.rb](https://github.com/austenito/octopress-heroku-autodeploy/blob/master/server.rb)

```ruby
get /##git_post_receive_url##/ do
```
