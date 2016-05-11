# Extension: Chunks of six

Up until now, it has been enough to encrypt our messages using only five digits for our encryption key and grouped them in four chunks. However, we suspect that someone is leaking information to the enemy side because the enemy was clearly aware of our two last offenses. We need to strengthen our encryption algorithm by using more digits for the key offsets - both the key and the date offset.

The messages still ends with: `..end..`

## Expected behavior

**The unique encryption key**

* The key is six digits, like `1234567`
* The first two digits of the key are the "A" rotation (`12`)
* The second and third digits of the key are the "B" rotation (`23`)
* The third and fourth digits of the key are the "C" rotation (`34`)
* The fourth and fifth digits of the key are the "D" rotation (`45`)
* The fifth and sixth digits of the key are the "E" rotation (`56`)
* The sixth and sevent digits of the key are the "F" rotation (`67`)

**The date offsets**

* Consider the date in the format DDMMYY, like 020315
* Square the numeric form (412699225) and find the last **six** digits (699225)
* The first digit is the "A offset" (6)
* The second digit is the "B offset" (9)
* The third digit is the "C offset" (9)
* The fourth digit is the "D offset" (2)
* The sixth digit is the "E offset" (2)
* The seventh digit is the "F offset" (5)
