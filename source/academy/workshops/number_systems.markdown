---
layout: page
title: Number Systems
---

Do you know how to count?

There's more than one way of counting. You're most familiar with the base-10
number system. In this session we'll work to:

* better understand base-10 (decimal)
* explain and explore base-2 (binary)
* explain and explore base-16 (hexadecimal)

## Base-10 (decimal)

You use base-10 numbers everyday, but let's think a bit more about how they work.

### Theory

* Uses the symbols `0`, `1`, `2`, `3`, `4`, `5`, `6`, `7`, `8`, `9`
* Digits carry over to the next place when `9` becomes `0`
* One digit can represent 10 unique numbers
* Two digits represent 100 unique numbers
* Moving right to left, positions represent:
  * 10^0 = 1
  * 10^1 = 10 ("tens")
  * 10^2 = 100 ("hundreds")
  * 10^3 = 1000 ("thousands")

## Base-2 (binary)

Everything in computing (hardware, software) is based on binary. At the electrical
level a binary zero means "no electricity", while a binary one means "yes electricity".

### Theory

* Uses the symbols `0` and `1` only
* Digits carry over to the next place when `1` becomes `0`
* One digit can represent only two unique numbers
* Two digits can represent only four unique numbers
* Moving right to left, positions represent:
  * 2^0 = 1
  * 2^1 = 2
  * 2^2 = 4
  * 2^3 = 8

### Conversions

#### From Binary to Decimal

To convert binary to decimal:

* Start from the right
* Multiply the digit in that place by the power of 2 corresponding to that place
* Add the results together

For example, say you have `101001`:

```plain
1 * 2^0 = 1
0 * 2^1 = 0
0 * 2^2 = 0
1 * 2^3 = 8
0 * 2^4 = 0
1 * 2^5 = 32

Total = 1 + 8 + 32 = 41 in decimal
```

#### From Decimal to Binary

* Take the whole decimal number
* Divide by two
* Note the quotient and the remainder
* Divide the quotient by 2, noting the new quotient and remainder
* Repeat until your quotient reaches zero
* Record the remainders from bottom to top

For example, say you have `41`:

```plain
41 / 2 = 20 remainder 1
20 / 2 = 10 remainder 0
10 / 2 = 5 remainder 0
5  / 2 = 2 remainder 1
2  / 2 = 1 remainder 0
1  / 2 = 0 remainder 1

Bottom to top it's 101001 in binary
```

#### Addition & Subtraction

You *can* convert back and forth to decimal and do your normal decimal addition/subtraction,
but doing them right in binary is actually straight-forward.

You use the same rules as when doing addition in decimal:

* Start from the right
* Add the two digits together
* If you get zero, write it down
* If you get one, write it down
* If you get two, write a zero and carry a one to the next column

For example, let's add `1011` and `101` like this:

```plain
  1011
+  101
------
```

The rightmost 1s add together to two, so a 1 gets carried and a zero written:

```plain
   (1)
  1011
+  101
------
     0
```

In the second column the previously carried 1 adds with the existing 1 and zero
to give two. A one is carried and the zero written:

```plain
  (1)
  1011
+  101
------
    00
```

Again the previously carried 1 adds with the existing zero and 1 to give two.
The one is carried and the zero written.

```plain
 (1)
  1011
+  101
------
   000
```

Finally the carried one adds with the existing one to give two, the one is
carried and the zero written. Since there are no more digits for the carry,
it is written too:

```plain
(1)
  1011
+  101
------
 10000
```

And we're done with the result `10000`.

**Subtraction** works the same way where you borrow from the left (so `1` becomes
`10` aka two).

### Exercises

#### Conversion

1. Convert 16 decimal to binary
2. Convert 1011 binary to decimal
3. Convert 31 decimal to binary
4. Convert 10101 binary to decimal

#### Addition & Subtraction

1. Add `1010` to `101`
2. Add `1010` to `1011`
3. Subtract `101` from `1111`
4. Subtract `11` from `1000`

## Base-16 (hexadecimal)

With binary under your belt, let's go the other direction with hexadecimal.

### Theory

In binary you have just two symbols, but in hex you have sixteen!

* Uses the symbols `0` through `9` then `A`, `B`, `C`, `D`, `E`, `F`
* Digits carry over to the next place when `F` becomes `0`
* One digit can represent sixteen unique numbers
* Two digits can represent 256 unique numbers
* Moving right to left, positions represent:
  * 16^0 = 1
  * 16^1 = 16
  * 16^2 = 256
  * 16^3 = 4096

### Conversions

#### From Hex to Decimal

To convert hex to decimal:

* Start from the right
* Multiply the digit in that place by the power of 16 corresponding to that place
* Add the results together

For example, say you have `A3F`:

```plain
F (15) * 16^0 (1)   = 15
3      * 16^1 (16)  = 48
A (10) * 16^2 (256) = 2560

Total = 15 + 48 + 2560 = 2623 in decimal
```

#### From Decimal to Hex

* Take the whole decimal number
* Divide by sixteen
* Note the quotient and the remainder
* Divide the quotient by sixteen, noting the new quotient and remainder
* Repeat until your quotient reaches zero
* Convert all the remainders to the hex symbol
* Record the remainders from bottom to top

For example, say you have `5007`:

```plain
5007 / 16 = 312 remainder 15 (F)
312 / 16 = 19 remainder 8
19 / 16 = 1 remainder 3
1  / 16 = 0 remainder 1

Bottom to top it's 138F in hex
```

### Exercises

#### Conversion

1. Convert 100 decimal to hex
2. Convert AF6C hex to decimal
3. Convert 10,000 decimal to hex
4. Convert FACE hex to decimal

#### Addition & Subtraction

1. Add 111 hex to 345 hex
2. Add F23 hex to 1A7 hex
3. Add 1 hex to FFFFFF hex

#### Try it in Ruby

Ruby by default represents numbers to us using base-10, even though it stores them in binary under the hood. However it also has the ability to represent numbers as strings of different bases when requested.

To do this, you simply pass an optional, numeric argument to the `to_s` method on `Fixnum`:

```
6.to_s(2)
=> "110"
```

Similarly, you can also pass an optional argument to the `to_i` method on `String` to tell ruby to use a different base when it's parsing a string into a number:

```
"110".to_i(2)
=> 6
```

Experiment with these methods to see if you can accomplish all the conversions from the exercises above using ruby.

1. Convert 100 decimal to hex
2. Convert AF6C hex to decimal
3. Convert 10,000 decimal to hex
4. Convert FACE hex to decimal
