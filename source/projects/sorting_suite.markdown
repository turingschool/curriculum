# Sorting Suite

Sorting algorithms are one of the common domains for studying Computer Science data structures and algorithms. They give us an opportunity to focus on algorithms of various complexity all solving a relatively simple problem.

In this project, you are challenged to implement *three*
fundamental sorting algorithms.

## Bubble Sort

**Effective Practices**

* **First solve it by hand with playing cards** Isolate your lack of familiarity with the sorting algorithm from your lack of familiarity with the programming / language, so that they can't double team you. Here is how I would do this: get a few playing cards and do the sorting by hand on the table (do it with bubble sort since we have an entire example for that one). Once you can reliably do this, observe the things you are considering as you do it. How did you decide when to stop? How did you decide whether to swap? Those things are conditions for loops, or they are `if` statements. Are you using your hands to point at particular cards? Your hands are indexes in the array. What does the hand track? That's what you should name it :)
* **Don't try to make it good until you've made it work** Trying to find the "right way"™ is often paralyzing (because there isn't one). Don't let your perception of other people's perception of "right" / "wrong" prevent you from progressing. Once you get something that works, then consider how you can nudge it in effective ways until it is good. You don't have to have them split into files until the end, you don't have to have them in classes / methods until the end. If I were in your position right now, I'd totally solve them in a single file with no particular abstractions, running over and over with Seeing Is Believing, and then once it worked, wrap a class around it, and then google how to do the namespace thing and add that, and then figure out how to get them into a file, and figure out what tests I'd need to feel confident that it worked correctly and I hadn't missed anything, and add that, then move the tests out into a test file)


### Theory

https://vimeo.com/channels/sortalgorithms/15558527

<iframe src="https://player.vimeo.com/video/15558527?color=F6AD3F&byline=0&portrait=0" width="500" height="333" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>

A straight forward sorting algorithm to implement is Bubble Sort.
For a high level understanding check out the [wikipedia article](https://en.wikipedia.org/wiki/Bubble_sort).
Bubble sort works by comparing and possibly swapping two values in an array. Say we
start with this array of numbers:

```
2 0 1 3 4 5
```

The algorithm would start with a variable `previous` pointing to the first element,
`2` and `current` pointing to the second value `0`. Then if `current` is
less than `previous` the two values are *swapped*. The swap would take
place in this case, because `0` is less than `2`.
After that single swap the sequence would be:

```
0 2 1 3 4 5
```

The algorithm would continue with `previous` advancing one spot to the right,
to point at `2`, and `current` advancing to point at `1`.
`1` is less than `2`, so we swap them again to get:

```
0 1 2 3 4 5
```

Notice that the `2` moved forward two spaces.
This is commonly called "bubbling up".
The number being "bubbled" will always be the largest number seen up to this point.

Now, `previous` advances to `2`, and `current` advances to `3`.
`3` is not less than `2`, so the focus advances without swapping.
This repeats moving right one space at a time until
reaching the end of the array,
meaning the largest number in the array must be in the last position.

After the second bubbling, we know that the last two items must be the two
largest items in the array, and they are sorted. After the third iteration,
the last 3 items are sorted. Thus we repeat the process once for each
element in the array, allowing us to know that the last `n` items are sorted,
where `n` is the size of the array.

#### Richer Example

Let's look at the sequence for a more out-of-order sequence:

```
Pre-Sequence Previous Current Swap? Post-Sequence
   4 2 0 3 1     4       2      Y   2 4 0 3 1
   2 4 0 3 1     4       0      Y   2 0 4 3 1
   2 0 4 3 1     4       3      Y   2 0 3 4 1
   2 0 3 4 1     4       1      Y   2 0 3 1 4
   2 0 3 1 4     2       0      Y   0 2 3 1 4
   0 2 3 1 4     2       3      N   0 2 3 1 4
   0 2 3 1 4     3       1      Y   0 2 1 3 4
   0 2 1 3 4     3       4      N   0 2 1 3 4
   0 2 1 3 4     0       2      N   0 2 1 3 4
   0 2 1 3 4     2       1      Y   0 1 2 3 4
   0 1 2 3 4     2       3      N   0 1 2 3 4
   0 1 2 3 4     3       4      N   0 1 2 3 4
   0 1 2 3 4     0       1      N   0 1 2 3 4
   0 1 2 3 4     1       2      N   0 1 2 3 4
   0 1 2 3 4     2       3      N   0 1 2 3 4
   0 1 2 3 4     3       4      N   0 1 2 3 4
   0 1 2 3 4     0       1      N   0 1 2 3 4
   0 1 2 3 4     1       2      N   0 1 2 3 4
   0 1 2 3 4     2       3      N   0 1 2 3 4
   0 1 2 3 4     3       4      N   0 1 2 3 4
```


### Challenge

Implement a namespaced BubbleSort which will make the following code snippets
work.

```ruby
# Should work with strings, too, which is nice, because then your elements and indexes don't look the same
sorter = SortingSuite::BubbleSort.new
=> <#BubbleSort ...>
sorter.sort(["d", "b", "a", "c"])
=> ["a", "b", "c", "d"]
```

## Insertion Sort

**Internalize the lessons of Bubble Sort before attempting Insertion Sort:**

All the thought processes and tools of Bubble Sort will be useful on insertion sort.
Here is an approach to internalize the lessons:

* Try rewriting Bubble Sort without referincing your working implementation.
* If you get stuck, look at your working implementation, use that to get past the hurdle, then immediately delete the part you looked up, and rewrite it from memory.
* When you complete it, keep in mind the parts you got stuck on and what the solution was, then delete the whole thing and repeat it.
* Continue doing this until you can write it without referencing the other implementation.
* Now try to do it again, but faster
* Now try to do it again, but without any errors (ie it sorts correctly the first time)
* Now try to do it again, but as quickly as you can, with as few errors as you can.
* Now you are ready for Insertion Sort ;)

### Theory

https://vimeo.com/channels/sortalgorithms/15558983

<iframe src="https://player.vimeo.com/video/15558983?color=F6AD3F&byline=0&portrait=0" width="500" height="333" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>

For a high level understanding check out the [wikipedia article](https://en.wikipedia.org/wiki/insertion_sort).
Insertion sort works by creating a new array which will always be sorted,
and adding each element to it, in the correct position,
by comparing each element in the array, until it finds the insertion location,
and then inserting the element there by shifting all the elements after it down one to make space.

Let's start with this array of numbers:

#### Insert the 1:

Since the array is empty, it is sorted, so we add the `1` to the end.

```
unsorted:    [1,   0,   2,   3,   4  ]
sorted pre:  [nil, nil, nil, nil, nil]
sorted post: [1,   nil, nil, nil, nil]
```

#### Insert the 0:

We compare the 0 to the 1, it goes before the 1,
so we move the 1 down to make space, and then
place the 0 there.

```
unsorted:           [1,   0,   2,   3,   4  ]
sorted pre:         [1,   nil, nil, nil, nil]
after making space: [nil, 1,   nil, nil, nil]
sorted post:        [0,   1,   nil, nil, nil]
```

#### Insert the 2:

We compare the 2 to the 0 and then the 1.
We haven't found where it goes, and there are no more numbers to compare,
so we insert it at the end.

```
unsorted:    [1,   0,   2,   3,   4  ]
sorted pre:  [1,   nil, nil, nil, nil]
sorted post: [0,   1,   2,   nil, nil]
```

### Challenge

Implement a namespaced InsertionSort which will make the following code snippets
work.

```ruby
SortingSuite::InsertionSort.new([3, 2, 1]).sort
=> [1, 2, 3]

SortingSuite::InsertionSort.new([2,5,4,1,3]).sort
=> [1, 2, 3, 4, 5]
```

## Merge Sort

Merge sort is the most fascinating sorting algorithm of the three, IMO, because it uses a technique called recursion.
Recursion was a total mind-trip for me when I learned it.
Here is a video I made with the intent of introducing recursion in a much more gradual way: https://vimeo.com/24716767

### Theory

https://vimeo.com/channels/sortalgorithms/15559012

<iframe src="https://player.vimeo.com/video/15559012?color=F6AD3F&byline=0&portrait=0" width="500" height="333" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>

For a high level understanding check out the [wikipedia article](https://en.wikipedia.org/wiki/merge_sort).
For a sweet line dancing example, [see this](https://www.youtube.com/watch?v=XaqR3G_NVoo)
Merge sort can be thought of as splitting an array into two arrays and sorting
the halves by also splitting them in half and sorting those halves by splitting
them in half... and so on.

For a brief example let's look at a simple array. The first step would be to
split the array into smaller arrays

#### Split the arrays

```ruby
original_array:  [2, 0, 1, 3]
first_split:     [2, 0]
remaining_split: [1, 3]
```

We then proceed to split one of those arrays further until we are left with just
numbers to compare.

#### Split again

```ruby
first_split: [2, 0]
first_num:   2
second_num:  0
```

We then compare those numbers and put them back into an array together. 1 and 0
will swap, creating a sorted split array.

#### Sort the doubly split array

```ruby
sorted_first_split: [0, 2]
remaining_split:    [1, 3]
```

We do the same operation on the remaining split, but we it's already sorted so
there will be no change. We then merge these two sorted halves together to
create a final sorted array. This is accomplished by comparing the each element
in the first split to those in the remaining split.

#### Merge the split and sorted arrays

```ruby
first_split_candidates:     0, 2
remaining_split_candidates: 1, 3
first_combination:          0, 1
second_combination:         0, 1, 2
third_combination:          0, 1, 2, 3
merged_array:               [0, 1, 2, 3]
```

### Challenge

Implement a namespaced MergeSort which will make the following code snippets
work.

```ruby
SortingSuite::MergeSort.new([3, 2, 1]).sort
=> [1, 2, 3]

SortingSuite::MergeSort.new([5,3,1,2,4]).sort
=> [1, 2, 3, 4, 5]
```

## Extensions

### Benchmark

Sometimes you want to test more than the functionality. Sometimes you want
to test the speed of that functionality.
We can do that by timing how long it takes to do its job,
and then compare them as we choose arrays of different sizes,
or compare them to other algorithms to understand which is better.
This is called benchmarking.

Write a benchmarker which can evaluate the temporal
shortcomings and accomplishments of the algorithms you just wrote.

Implement a namespaced Benchmark which will make the following code snippets
work:

```ruby
benchmark = SortingSuite::Benchmark.new

benchmark.time(SortingSuite::InsertionSort, [3,3,4,5,1])
=> "InsertionSort took 0.004333 seconds"

benchmark.time(SortingSuite::MergeSort)
=> "MergeSort took 0.000274 seconds"

benchmark.fastest([2, 8, 1, 0, 5])
=> "MergeSort is the fastest"

benchmark.slowest([1, 2, 3, 4, 5])
=> "BubbleSort is the slowest"
```


### Selection Sort

https://vimeo.com/channels/sortalgorithms/15673458

<iframe src="https://player.vimeo.com/video/15673458?color=F6AD3F&byline=0&portrait=0" width="500" height="333" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>

For a high level understanding check out the [wikipedia article](https://en.wikipedia.org/wiki/selection_sort).
This sorting algorithm is most similar to the insertion sort, just in reverse.
The implementation chooses the lowest value and forms a new array starting with
that value and working up.

```ruby
SortingSuite::Selection.new([3, 2, 1])
=> [1, 2, 3]

SortingSuite::Selection.new([4, 0, 2, 3, 1])
=> [0, 1, 2, 3, 4]
```

### In-Place Insertion Sort

In-place insertion (or, if you did it in place earlier, then not in-place :P)

In-place sorting algorithms don't create new data structures while they solve the problem.
Instead, they move elements around within the array,
such that they never need to work with more than the array they are sorting.

Try writing the Insertion Sort so that it doesn't instantiate a new
array during the solution.

```ruby
SortingSuite::InsertionSort.new([3, 2, 1]).inplace_sort
=> [1, 2, 3]

array = [4, 0, 2, 3, 1]
SortingSuite::InsertionSort.new(array).inplace_sort
=> [0, 1, 2, 3, 4]

SortingSuite::InsertionSort.new(array).sort.object_id == array.object_id
=> true
```


## Rubric

This rubric works like so: In order to get a given score,
you must satisfy not only its description,
but also the requirements of all the scores beneath it.
ie if you did not satisfy the requirements of 2,
then you are not eligible for a 3, even if you satisfied it.

### Functional Expectations

  * 4: All three sort classes work as expected with 2 or more extensions.
  * 3: All three sort classes work as expected
  * 2: Two sort classes work as expected
  * 1: Zero or one sort classes work as expected

### Testing

  * 4: Test names describe the behavior not the example (I can read the test header and guess the implementation -- this is mostly applicable to MergeSort, it implies some of the smaller ideas are tested than just "it sorts the array")
  * 3: Edge cases are tested. Examples might include: empty arrays, pre-sorted arrays, arrays which are in reverse order, arrays of strings
  * 2: Sorting suites pass all the examples
  * 1: All tests pass and can be ran together with a single command

### Ruby Style

  * 4: Any given chunk of code can be understood at a single level of abstraction
  * 3: Adheres to the [style guide](https://github.com/styleguide/ruby) unless you can defend a deviation
  * 2: Adheres to [indentation guide](https://gist.github.com/JoshCheek/b3c6a8d430b2e1ac8bb2)
  * 1: There are no syntax errors or crashes during execution

### Organization

  * 4: Version control maintains the codebase
  * 3: Each sorter class has it's own file in the proper directory and it's own test in the test directory
  * 2: A file/directory structure provides basic organization via lib/ and spec/ or /test
  * 1: Components work together properly
