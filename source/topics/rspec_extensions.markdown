---
layout: page
title: Rspec Extensions
---

While `describe` and `context` syntactically are not very different, save for the restriction that `context` cannot be used as a top level element within a spec file, it is often good to use `context` in situations where a group of tests are exercising particular paths through the method or illustrating a particular state.

```ruby
class Client

  # Connects to the specified server 
  def connect(server=@default_server)
    # ... performs connection to the server ...
  end
end
```

In the above situation our `Client` class has a `#connect` method which allows for a single input. 

The method accepts a server as a parameter or it defaults a sever value stored within the `Client` instance. Here, we have identified a context when the code is executed without a server specified and with a server specified.

As this is likely a client making a connection to a server it is possible that the server is not available. Again, we have identified a context when the code may generate a different result within the code.

An example outline of the resulting test file could look like the following:

```ruby
describe Client do
  describe '#connect' do
    context 'when the server value is not specified' do
      it 'should connect to the default server' do ; end
    end
    
    context 'when the server is not available' do
      it 'should raise an exception' do ; end
    end
  end
end
```

Each defined context here uses RSpec's `context` keyword with each description string starting with *when*. Again, this is a good practice as it makes it clear when what this context is attempting to describe.
