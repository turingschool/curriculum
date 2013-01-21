---
layout: page
title: Writing C in Your Ruby
---

Don't do it. Well, don't do it until it's clear you need it _or_ you've already written the C libraries and want to take advantage of them from Ruby.

## Write Once, Run Someplace

The first problem is that each Ruby interpreter has quirks when it comes to running C on the local OS. You'd like your code to run on Mac, Windows, and Linux versions of the MRI interpreter, but running on JRuby/JVM for each would be nice too. If you stick with the straight C approach, you'll have to customize the code for each of those six platforms. And that's not the Ruby way.

## FFI

The FFI (Foreign Function Interface) project is a minimal abstraction shim to make your life easier. You gain the speed of native code but can still port it between architectures.

The authors claim that:

* It has a very intuitive DSL
* It supports all C native types
* It supports C structs (also nested), enums and global variables
* It supports callbacks
* It has smart methods to handle memory management of pointers and structs

### Demo

* Install the `ffi` gem with `gem install ffi`
* Open `irb`
* Try out this code to use native libc:

```ruby
require 'ffi'

module MyLib
  extend FFI::Library
  ffi_lib 'c'
  attach_function :puts, [ :string ], :int
end

MyLib.puts 'Native code in your Ruby!'
```

### More Information

The project provides a few snippet samples: https://github.com/ffi/ffi/tree/master/samples

Then examples with more depth including memory management: https://github.com/ffi/ffi/wiki/Examples

But to really understand how it can be used, there are many open source projects using FFI: https://github.com/ffi/ffi/wiki/projects-using-ffi