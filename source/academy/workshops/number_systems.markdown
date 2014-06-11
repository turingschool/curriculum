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

### Exercises

#### Conversion

#### Addition & Subtraction

## Base-16 (hexadecimal)

### Theory

### Conversions

#### From Hex to Decimal

#### From Decimal to Hex

### Exercises

#### Conversion

#### Addition & Subtraction
