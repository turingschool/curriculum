# Iteration 4 - Creating a Linked List Wrapper

Awesome! We have built most of our program and now it's time to wrap the Linked List logic in a `JungleBeat` class.

When we create a new instance of the `JungleBeat` class, a `LinkedList` object is also instantiated and available as an attribute on the `JungleBeat` instance. Now, we can manage our linked list through the `JungleBeat` class. With this extra layer, the linked list itself does not have to make any assumptions about what data is provided when we append nodes. If we want to append "deep dop dii" as three nodes, the `JungleBeat` class can take care of properly formatting the data (eg: splitting the string) before passing it down to the `LinkedList`.

Expected behavior:

```ruby
> require "./lib/jungle_beat"
> jb = JungleBeat.new
=> <JungleBeat list=<LinkedList head=nil #234567890890> #456789045678>
> jb.list
=> <LinkedList head=nil #234567890890>
> jb.list.head
=> nil
> jb.append("deep doo ditt")
=> "deep doo ditt"
> jb.list.head.data
=> "deep"
> jb.list.head.next_node.data
=> "doo"
```
