---
layout: page
title: Win one for the Zipper
---

# Win one for the Zipper

Computers use one byte to store each character in a file. A byte is made up of 8 bits. There are 2^8 = 256 possible states of one byte. There are only 26 letters in the alphabet! Even when you include capital letters, numbers and special characters, you can only type 95 characters on a standard keyboard. We're wasting the rest of the space in those bytes. Maybe we should only use 7 bytes per character.

The most common character in english is the letter 'E'. It appears over 100x more often than a 'Z'. And spaces occur twice as often as 'E's. Should all of these characters take up the same number of bits? Why are we wasting all this space!?

## Huffman Coding

Huffman coding is one of the oldest compression algorithms, and forms of it are still used in MP3 and JPEG files today. It uses frequency of different characters in a text file to recode the bits used for each character.

### Building the Tree(trie)
I've looked at several videos to explain Huffman coding, but the best explanation of a simple algorithm is on [wikipedia](https://en.wikipedia.org/wiki/Huffman_coding#Basic_technique):

Building the trie begins by creating disconnected nodes containing the probabilities of the symbol they represent, and ordering them in a queue by probability. Then a new node is created whose children are the 2 nodes with smallest probability. The new node's probability is equal to the sum of the children's probability. Add the new node to the queue you've already created based on it's value.

With the previous 2 nodes merged into one node (thus not considering them anymore), and with the new node being now considered. The procedure is repeated until only one node remains, which becomes the root node.

> The simplest construction algorithm uses a priority queue where the node with lowest probability is given highest priority:

> 1. Create a leaf node for each symbol and add it to the priority queue.
> 2. While there is more than one node in the queue:
>   1. Remove the two nodes of highest priority (lowest probability) from the queue
>   2. Create a new internal node with these two nodes as children and with probability equal to the sum of the two nodes' probabilities.
>  3. Add the new node to the queue.
> 3. The last node is the root node, and the tree is complete.

You can now use this tree to determine the new bits for each character in your file. To find the bits for a character, just travel from the top of the tree, through the nodes, to the character's leaf. Each time you go left in the tree, add a `0`. Each time you go right, add a `1`. Once you arrive at the character, you're done.

If you've properly built your tree, more common characters will have shorter codes than characters that appear less frequently.

## Encoding

### Getting your codes

```
message = "That's no moon, it's a space station!"
encoder = Encoder.new(message)

encoder.character_counts
#=> {"T"=>1, "h"=>1, "a"=>4, "t"=>4, "'"=>2, "s"=>4,
#    " "=>6, "n"=>3, "o"=>4, "m"=>1, ","=>1, "i"=>2,
#    "p"=>1, "c"=>1, "e"=>1, "!"=>1}

encoder.build_tree
#=> "Built tree with 16 nodes and 17 leaves"

encoder.char_to_code("T")
#=> "10101"

```

### Calculating efficiency
```
encoder.original_bitstring
#=> "01010100011010000110000101110100001001110111001100100000011011100110111100100000011011010110111101101111011011100010110000100000011010010111010000100111011100110010000001100001001000000111001101110000011000010110001101100101001000000111001101110100011000010111010001101001011011110110111000100001"

encoder.coded_bitstring
#=> "1010110111101110011110000110111001011011111001001011100011011000101001111000011001111000010111001111111100111110000100011100001001011101011010100"

encoder.original_bitlength
#=> 296

encoder.coded_bitlength
#=> 145

encoder.coding_efficiency
#=> 49.0%
```

## Your very own zip file

### How it works

#### Writing to file

```
most_retweeted = "Wowwwww 5 years 5 boys what an amazing journey I couldn't thank you all ever enough and thank you Louis Niall Harry and zayn for everything"
encoder = Encoder.new(most_retweeted)

encoder.write_to_file("most_retweeted.compressed")
```

#### Reading from a file

```
decoder = Decoder.new_from_file("most_retweeted.compressed")

decoder.decoded_message
#=> "Wowwwww 5 years 5 boys what an amazing journey I couldn't thank you all ever enough and thank you Louis Niall Harry and zayn for everything"
```

### It gets real

- Until now, you've only had to determine codes as strings. Now you have to actually translate your "0"s and "1"s to bytes, and write them to the file.
- When you turn your bitstring into bytes, you'll need a number of bits divisible by 8. Otherwise, you can't translate your bits to bytes. How will you tell your decoder where to stop?
- Each Huffman code is specific to the message being coded. The file you write will have to communicate how to translate the coded message to the decoder. This will make your file longer than the original message, but don't worry about that right now.

## Extensions

### 1. Predetermined order

In order to reduce the amount of space your coding takes in your compressed file, use the following predetermined order. This will limit the characters you can encode.

```
PREDETERMINED_ORDER = [
  "\n","\t"," ","a","b","c","d","e","f","g","h","i","j","k",
  "l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
  "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O",
  "P","Q","R","S","T","U","V","W","X","Y","Z","0","1","2","3",
  "4","5","6","7","8","9","~","!","@","#","$","%","^","&","*",
  "(",")","_","+","-","=","[","]","\\",";","'",",",".","/","<",
  ">","?",":","\"","{","}","|"
]

```

### 2. Automated Reporting

* Setup [SimpleCov](https://github.com/colszowka/simplecov) to monitor test coverage along the way

## Evaluation Rubric

The project will be assessed with the following rubric:

### 1. Functional Expectations

* 4: Application fulfills all base expectations and one extension
* 3: Application fulfills all base expectations
* 2: Application is missing one base expectation
* 1: Application is missing more than one base expectation

### 2. Test-Driven Development

* 4: Application is broken into components which are well tested in both isolation and integration using appropriate data
* 3: Application is well tested but does not balance isolation and integration tests, using only the data necessary to test the functionality
* 2: Application makes some use of tests, but the coverage is insufficient
* 1: Application does not demonstrate strong use of TDD

### 3. Encapsulation / Breaking Logic into Components

* 4: Application is expertly divided into logical components each with a clear, single responsibility
* 3: Application effectively breaks logical components apart but breaks the principle of SRP
* 2: Application shows some effort to break logic into components, but the divisions are inconsistent or unclear
* 1: Application logic shows poor decomposition with too much logic mashed together

### 4. Fundamental Ruby & Style

* 4:  Application demonstrates excellent knowledge of Ruby syntax, style, and refactoring
* 3:  Application shows strong effort towards organization, content, and refactoring
* 2:  Application runs but the code has long methods, unnecessary or poorly named variables, and needs significant refactoring
* 1:  Application generates syntax error or crashes during execution

### 5. Enumerable & Collections

* 4: Application consistently makes use of the best-choice Enumerable methods
* 3: Application demonstrates comfortable use of appropriate Enumerable methods
* 2: Application demonstrates functional knowledge of Enumerable but only uses the most basic techniques
* 1: Application demonstrates deficiencies with Enumerable and struggles with collections
