# Iteration 1 - Append, All and Count (Single Node)

Great! We have nodes. Next step is to build out the `JungleBeat` class which will manage the list.

We are also going to build the `append`, `all` and `count` methods. `append` will add another node to the end of the list, `all` will return the data of the linked list in order, and `count` will return the number of nodes in the list.

Expected behavior:

```ruby
> require "./lib/jungle_beat"
> jb = JungleBeat.new("deep")
=> 1 # number of nodes inserted
> jb.head
=> <Node data="deep" next_node=nil #4567890456789456789>
> jb.head.data
=> "deep"
> jb.count
=> 1
> jb.append("plop")
=> 1
> jb.count
=> 2
> jb.all
=> "deep plop"
> jb.head.data
=> "deep"
```