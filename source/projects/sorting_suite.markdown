# Sorting Suite

Sorting algorithms are one of the common domains for studying Computer Science data structures and algorithms. They give us an opportunity to focus on algorithms of various complexity all solving a relatively simple problem.

In this project, you are challenged to implement *three*
fundamental sorting algorithms. Your final submission should include at least these six files:

* `bubble_sort.rb`
* `bubble_sort_test.rb`
* `insertion_sort.rb`
* `insertion_sort_test.rb`
* `merge_sort.rb`
* `merge_sort_test.rb`

## 1. Bubble Sort

### Big Picture

Bubble Sort is often one of the first algorithms of any kind that programmers attempt. There are very few steps which make it not too difficult to implement. But it takes many instructions to actually execute -- so the performance is typically quite bad.

### The Algorithm

You can see a [graphical run of the algorithm here](https://vimeo.com/channels/sortalgorithms/15558527).

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

### Expectations

Implement a `BubbleSort` class which will make the following code snippet work:

```ruby
sorter = BubbleSort.new
=> #<BubbleSort:0x007f81a19e94e8>
sorter.sort(["d", "b", "a", "c"])
=> ["a", "b", "c", "d"]
```

## 2. Insertion Sort

### Big Picture

Insertion sort is a next step up from Bubble Sort. Make sure that you've successfully implemented Bubble Sort before you dive into this section.

Insertion sort uses slightly more complex logic but the algorithm is generally much higher performing than Bubble.

### The Algorithm

You can [see a visualization of the algorithm here](https://vimeo.com/channels/sortalgorithms/15558983).

For a high level understanding check out the [wikipedia article](https://en.wikipedia.org/wiki/insertion_sort).
Insertion sort works by creating a new, empty array of results. We iterate through the set to be sorted, pulling one element at a time, then inserting it into its correct position in the new array.

Let's start with this array of numbers: `[1,0,4,3,2]`

#### Pass 1

We pull the first element from the unsorted list and insert it into the sorted list:

```
unsorted:      [1,0,4,3,2]
to insert:     1
sorted pre:    []
sorted post:   [1]
unsorted post: [0,4,3,2]
```

#### Pass 2

We pull the first unsorted element, the `0`, and compare it to the first element of the sorted set, `1`. Since the `0` before the `1`, we insert it at the front of the sorted set:

```
unsorted:      [0,4,3,2]
to insert:     0
sorted pre:    [1]
sorted post:   [0,1]
unsorted post: [4,3,2]
```

#### Pass 3

We pull the first unsorted element, the `4`, and compare it to the first element of the sorted set, `0`. Since the `4` is greater, we look at the next position of the sorted set, `1`. The `4` is greater but there are no other elements, so we add the `4` to the end of the sorted array.

```
unsorted:      [4,3,2]
to insert:     4
sorted pre:    [0,1]
sorted post:   [0,1,4]
unsorted post: [3,2]
```

#### Pass 4

We pull the first unsorted element, the `3`, and compare it to the first element of the sorted set, `0`. Since the `3` is greater, we look at the next position of the sorted set, `1`. The `3` is greater, so we look at the next position of the sorted set, `4`. The `3` is less than `4`, so we insert the `3` at this position pushing the `4` to the right.

```
unsorted:      [3,2]
to insert:     3
sorted pre:    [0,1,4]
sorted post:   [0,1,3,4]
unsorted post: [2]
```

#### Pass 5

We pull the first unsorted element, the `2`, and compare it to the first element of the sorted set, `0`. Since the `2` is greater, we look at the next position of the sorted set, `1`. The `2` is greater, so we look at the next position of the sorted set, `3`. The `2` is less than `3`, so we insert the `3` at this position pushing the `3` to the right.

```
unsorted:      [2]
to insert:     2
sorted pre:    [0,1,3,4]
sorted post:   [0,1,2,3,4]
unsorted post: []
```

Then our unsorted array is empty, meaning we're done with the algorithm.

### Challenge

Implement an `InsertionSort` which will make the following code snippet
work:

```ruby
sorter = InsertionSort.new
=> #<InsertionSort:0x007f81a19e94e8>
sorter.sort(["d", "b", "a", "c"])
=> ["a", "b", "c", "d"]
```

## 3. Merge Sort

Merge sort is the most fascinating sorting algorithm of the three, IMO, because it uses a technique called recursion.
Recursion was a total mind-trip for me when I learned it.
Here is a video I made with the intent of introducing recursion in a much more gradual way: https://vimeo.com/24716767

### Theory

https://vimeo.com/channels/sortalgorithms/15559012

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
sorter = MergeSort.new
=> #<MergeSort:0x007f81a19e94e8>
sorter.sort(["d", "b", "a", "c"])
=> ["a", "b", "c", "d"]
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

* 4: Tests are clearly written with names that accurately describe the behavior. Edge cases
such as empty arrays, reversed arrays, etc are also tested.
* 3: Tests cover functionality and demonstrate some escalation of complexity across the examples.
* 2: Sorting suites pass all the examples
* 1: All tests pass and can be ran together with a single command

### Ruby Style

* 4: Any given chunk of code can be understood at a single level of abstraction
* 3: Code is a readable and effective implementation of the algorithm. Has fewer than 4 "what on earth is this?" lines of code.
* 2: Code runs effectively but has large issues with readbility (long methods, confusing
method or variable names, etc)
* 1: There are syntax errors or crashes during execution

### Organization

* 4: Version control maintains the codebase
* 3: Each sorter class has it's own file in the proper directory and it's own test in the test directory
* 2: A file/directory structure provides basic organization via lib/ and spec/ or /test
* 1: Components work together properly
