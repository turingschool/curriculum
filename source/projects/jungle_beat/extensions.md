# Extensions

### 1. Validating Beats

There are a lot of words which aren't going to work for beats. Like `Mississippi`.

Add validation to your program such that the input beats must be members of your
defined list. Insertion of a beat not in the list is rejected. Like this:

```ruby
> jb = JungleBeat.new("deep")
> jb.append("Mississippi")
=> 0
> jb.all
=> "deep"
> jb.prepend("tee tee tee Mississippi")
=> 3 # number of beats successfully inserted
> jb.all
=> "tee tee tee deep"
```

Here's a starter list of valid beats, but add more if you like:

```
tee dee deep bop boop la na
```

### 2. Speed & Voice

Let's make it so the user can control the voice and speed of playback. Originally
we showed you to use `say -r 500 -v Boing` where `r` is the rate and `v` is the
voice. Let's setup a usage like this:

```ruby
> jb = JungleBeat.new("deep dop dop deep")
> jb.play
=> 4 # plays the four sounds normal speed with Boing voice
> jb.rate = 100
=> 100
> jb.play
=> 4 # plays the four sounds slower with Boing voice
> jb.voice = "Alice"
=> "Alice"
> jb.play
=> 4 # plays the four sounds slower with Alice voice
> jb.reset_rate
=> 500
> jb.reset_voice
=> "Boing"
> jb.play
=> 4 # plays the four sounds normal speed with Boing voice
```
