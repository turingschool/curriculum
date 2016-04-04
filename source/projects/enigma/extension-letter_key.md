# Extension - Four letter keys

Previously, it has been sufficient to encrypt our messages using a random five digit key and a four digit date offset. The enemy is decrypting a larger percentage of our messages and we desperately need to improve our encryption alogrithm. Instead of using a five digit key, we are going to use a four letter word as a key. The date offset key will stay the same.

The messages still ends with: `..end..`

## Expected behavior

Instead of encrypting messages with a five digit key and a date offset, we will be encrypting messages using a code word in conjunction with the date offset key.

Given the code word `ALAN`:

* The  "A" offset is the `A`
* The "B" offset is the `L`
* The "C" offset is the `A`
* The "N" offset is the `N`

### Code words

Use any of the following code words to encrypt messages:

```rb
["clue",
"fern",
"then",
"sign",
"gone",
"pair",
"hair",
"ring",
"site",
"sunk",
"coat",
"sane",
"show",
"lend",
"prim",
"rise",
"upon",
"find",
"gave",
"wing",
"plan",
"high",
"note",
"into",
"tree",
"hear",
"name",
"fate",
"view",
"wait",
"lent",
"gain",
"body",
"wash",
"kept",
"laid",
"does",
"left",
"door",
"less",
"sour",
"pack",
"rife",
"bolt",
"puts",
"torn",
"glib",
"came",
"tiny",
"stay",
"meal",
"thus",
"look",
"date",
"lead",
"tell",
"care",
"text",
"army",
"grew"]
```