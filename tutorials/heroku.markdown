## Heroku Setup

We love deploying code to Heroku because the whole system was built to be easy. There are just a few steps to get going.

### SSH Keys

Heroku authenticates using SSH keys.

#### On Windows

If you've used RailsInstaller then it generated and saved SSH keys for you; there's nothing to do!

#### MacOS and Linux

If you're on MacOS or Linux there's a decent chance you've already created a set of SSH keys. Look in `~/.ssh/` and if you see files like `id_rsa` and `id_rsa.pub` then you're good to go!

If those files *aren't* present, generate new keys like this:

```bash
ssh-keygen -t rsa
```

If you choose to use a passphrase, you'd better remember it. If you forget it then you can't use your keys and you might not be able to access important resources like your code and server!

Once that setup completes you're ready to continue.

### Heroku Gem

Heroku has created a gem (https://github.com/heroku/heroku) that makes it ridiculously easy to interact with their service. If you use Heroku for all your projects, consider adding it to your `~/.rvm/gemsets/global.gems` and add it to your global gemset:

```bash
rvm gemset use global
gem install heroku
```

### Authenticate

Now you're ready to submit your credentials to Heroku. Start by attempting to list your applications:

```bash
heroku list
```

You'll be prompted for your Heroku.com username and password. If you don't have one, create one: http://www.heroku.com/signup

Once those credentials are entered, you should upload your SSH keys to allow password-less access in the future:

```bash
heroku keys:add
```

Once that upload completes, you can try `heroku list` again and it should complete *without* asking for a username/password.

## Heroku Basics

Here are some of the most common commands you'll use on Heroku:

create [<name>]              # create a new app
list                         # list your apps

Within the root directory of a project:

```bash
 info                         # show app info, like web url and git repo
 open                         # open the app in a web browser
 rename <newname>             # rename the app
 rake <command>               # remotely execute a rake command
 console                      # start an interactive console to the remote app
 config                       # display the app's config vars (environment)
 config:add key=val [...]     # add one or more config vars
 db:pull [<database_url>]     # pull the app's database into a local database
 db:push [<database_url>]     # push a local database into the app's remote
```

Check out the full list on Cheat (http://cheat.errtheblog.com/s/heroku/) or install the Cheat gem (`gem install cheat`) then display it with `cheat heroku`.