---
layout: page
title: Guard
---

Guard is a system for automatically running your tests whenever a file changes.

Check out the [Guard project page on GitHub](https://github.com/guard/guard).

## Install

Install the guard-minitest gem:

{% terminal %}
$ gem install guard-minitest
{% endterminal %}

## Create a `Guardfile`

You then need a `Guardfile`. Assuming you're in the root directory of your project:

{% terminal %}
$ touch Guardfile
{% endterminal %}

### Add a `guard` Group

The `Guardfile` allows you to define multiple entries for files you want to
react to grouped by type. For our exercise we only need to run Minitest tests.
Start with this:

```ruby
guard :minitest do

end
```

Which will contain a set of Minitest watchers.

### Add a Watcher

Inside that block, add a watcher:

```ruby
watch(/^lib\/.+\.rb/)
```

This regular expression matches files inside the `lib` folder that end in `.rb`.
Whenever a matching file changes, Guard will try to run the tests.

### Run Guard

Let's try it. From your project directory:

{% terminal %}
$ guard
16:28:16 - INFO - Guard is using TerminalTitle to send notifications.
16:28:16 - INFO - Guard::Minitest 2.3.1 is running, with Minitest::Unit 5.3.3!
16:28:16 - INFO - Running: all tests
Run options: --seed 43607
{% endterminal %}

Modify a file in `lib` and you'll see output like this:

{% terminal %}
16:31:22 - INFO - Running:
Run options: --seed 18199

# Running:

Finished in 0.000942s, 0.0000 runs/s, 0.0000 assertions/s.

0 runs, 0 assertions, 0 failures, 0 errors, 0 skips
[1] guard(main)>
{% endterminal %}

Guard saw that a file changed. But instead of running a test file it ran the file
in `lib` itself, which doesn't contain any tests.

### Improving the `watch`

Assuming we changed a file `lib/sample.rb` then we want to run a test file
`test/sample_test.rb`. We need to add a block to our `Guardfile` to make this work:

```ruby
guard :minitest do
  watch(/^lib\/.+\.rb/) { "test/sample_test.rb"}
end
```

When you save the `Guardfile`, Guard will re-read it automatically. Try changing
your file in `lib` and see the results. Guard runs the `sample_test.rb` file.

But that's not good enough because it's always running `sample_test.rb`,
regardless of which file was changed in `lib/`.

### Using the Captures

Because Guard relies on regular expressions, it passes a `MatchData` object to the
block. If we define a capture within the file pattern, then we can use that
capture in the block.

Let's start by adding the capture. Look carefully at this regular expression and
notice the parenthses around the `.+`. That'll capture the name of the file between the
folder and the `.rb`.

```ruby
guard :minitest do
  watch(/^lib\/(.+)\.rb/) { "test/sample_test.rb"}
end
```

Next we modify the block to use the capture:

```ruby
guard :minitest do
  watch(/^lib\/(.+)\.rb/) { |captures| "test/#{captures[1]}_test.rb"}
end
```

`captures` here acts like an array. `captures[0]` is the entire string which was
matched, like `lib/sample.rb`. But `captures[1]` is *just* the name fragment that
we need. We use string interpolation to inject it into the filename.

Save the `Guardfile`, see Guard re-evaluate it, then change your `lib/sample.rb`.
Guard should run the matching test file. Now any time you modify a file in `lib`
the matching test file will run.

### Watch the Tests

But what about the other way? It'd be great to have the tests run whenever *they*
change. Add another watcher like this:

```ruby
watch(/^test\/.+\.rb/)
```

This time we don't need any captures because we just want to run the file that
changed.

That's everything you need to get started with Guard. Check out the
[Guard project page on GitHub](https://github.com/guard/guard) for more tips and
ideas.

```ruby
puts "This is a test"
```
