# Iteration 6 - Playing Beats

Now that we have our JungleBeat class put together using the internal Linked List to keep track of our beats, let's use it to actually play the beats.

Remember that, at the command line, we can play sounds using the `say` command:

```
$ say -r 500 -v Boing "ding dah oom oom ding oom oom oom ding dah oom oom ding dah oom oom ding dah oom oom "
```

It turns out we can also easily issue this command (or any other system command) from ruby by using backticks: ```.

For example:

```
$ pry
> `say -r 500 -v Boing "ding dah oom oom ding oom oom oom ding dah oom oom ding dah oom oom ding dah oom oom "`
```

Additionally, we can use standard string interpolation (`#{}`) to pass dynamic content into a system command:


```
$ pry
> beats = "ding dah oom oom ding oom oom oom ding dah oom oom ding dah oom oom ding dah oom oom "
> `say -r 500 -v Boing #{beats}`
```

For this final section, add a `play` method to your JungleBeat class that will generate the string content of the JungleBeat and use it as input to the `say` command.

> require "./lib/jungle_beat"
> jb = JungleBeat.new
=> <JungleBeat list=<LinkedList head=nil #234567890890> #456789045678>
> jb.append("deep doo ditt woo hoo shu")
=> "deep doo ditt woo hoo shu"
> jb.count
=> 6
> jb.list.count
=> 6
> jb.play
=> # plays the sounds deep doo ditt woo hoo shu
