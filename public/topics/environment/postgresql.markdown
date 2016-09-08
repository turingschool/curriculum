#### Set It to Run on Startup

Run the following commands to make it start when you turn on your computer *and* start right now:

{% terminal %}
ln -sfv /usr/local/opt/postgresql/*.plist ~/Library/LaunchAgents
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
{% endterminal %}

#### Verifying Install and Permissions

Let's create a database and connect to it:

{% terminal %}
$ createdb sample_db
$ psql sample_db
{% endterminal %}

You should see the following (note: use `\q` to exit):

{% terminal %}
$ psql sample_db
psql (9.3.3)
Type "help" for help.

sample_db=# \q
{% endterminal %}

If you got that, then Postgres is good to go.
