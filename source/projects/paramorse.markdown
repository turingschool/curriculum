# ParaMorse

> Morse code is a method of transmitting text information as a series of on-off tones, lights, or clicks that can be directly understood by a skilled listener or observer without special equipment.
s
Let's build a system to generate Morse code from plain text and decode Morse to
plain text.

## Learning Goals

In this project you'll practice:

* Building small objects with a single purpose
* Connecting multiple objects to achieve a single overall purpose
* Building software using iterative/agile methodologies
* Implementing a queue data structure

## Final Product

When your project is complete it will perform the following:

```ruby
encoder = ParaMorse::Encoder.new
encoder.encode("This is my message")
# => 111011000101010101010100010101010 (to be filled in later)
decoder = ParaMorse::Decoder.new
decoder.decode("111011000101010101010100010101010")
# => "This is my message"
# More expectations to be added
```

## Background Understandings

Before you begin, understand the following:

### What is Morse Code?

First, you should read the at least the opening section of the [Morse Code page
on wikipedia](https://en.wikipedia.org/wiki/Morse_code).

Note that the [graphic defining Morse codes](https://en.wikipedia.org/wiki/Morse_code#/media/File:International_Morse_Code.svg) should be your official reference.

### Dots, Dashes, and Timing

For our representation of Morse:

* a `1` represents a moment of signal
* a `0` represents a moment of silence.
* a "dot" is represented by `10` (one moment of signal, one of silence)
* a "dash" is represented by `1110` (three moments of signal, one of silence)
* a letter is separated from the next letter by `000`
* words are separated by a space equal to seven dots `0000000`

## Building in Iterations

### Iteration 0: Queues

Your implementation should use a "First-In-First-Out Queue".

* Read [this article about Queues](https://en.wikipedia.org/wiki/Queue_(abstract_data_type))
* Implement a queue that fulfills the following

```ruby
q = ParaMorse::Queue.new
q.push('1')
q.push('0')
q.push('0')
q.push('1')
q.push('1')
q.count
# => 5
q.tail
# => 1
q.tail(3)
# => ['1', '1', '0']
q.peek
# => '1'
q.peek_multiple(3)
# => ['1', '0', '0']
q.count
# => 5
q.pop
# => '1'
q.pop_multiple(3)
# => ['0', '0', '1']
q.count
# => 1
q.clear
q.count
# => 0
```

### Iteration 1: Encoding Plain Letters

Build a small "machine" capable of turning a letter into a series of dots and
dashes:

```ruby
letter_encoder = ParaMorse::LetterEncoder.new
letter_encoder.encode("a")
# => "10111"
letter_encoder.encode("q")
# => "1110111010111"
```

### Iteration 2: Decoding a Known Letter

Before we start encoding big messages we'd better prove that we can decode single letters
correctly.

```ruby
letter_decoder = ParaMorse::LetterDecoder.new
letter_decoder.decode("10111")
# => "a"
letter_decoder.decode("1110111010111")
# => "q"
```

### Iteration 3: Encoding & Decoding Words

Now start to stitch it together to work with words:

```ruby
encoder = ParaMorse::Encoder.new
encoder.encode("Word")
# => "1011101110001110111011100010111010001110101"
decoder = ParaMorse::Decoder.new
decoder.decode("1011101110001110111011100010111010001110101")
# => "word"
```

### Iteration 4: Multiple Words

Then take what is probably a small step: encode and decode whole words.

```ruby
encoder = ParaMorse::Encoder.new
encoder.encode("what light through yonder window breaks")
# => "1011101110001010101000101110001110000000101110101000101000111011101000101010100011100000001110001010101000101110100011101110111000101011100011101110100010101010000000111010111011100011101110111000111010001110101000100010111010000000101110111000101000111010001110101000111011101110001011101110000000111010101000101110100010001011100011101011100010101"
decoder = ParaMorse::Decoder.new
decoder.decode("1011101110001010101000101110001110000000101110101000101000111011101000101010100011100000001110001010101000101110100011101110111000101011100011101110100010101010000000111010111011100011101110111000111010001110101000100010111010000000101110111000101000111010001110101000111011101110001011101110000000111010101000101110100010001011100011101011100010101")
# => "what light through yonder window breaks"
```

### Iteration 5: Streaming

Messages aren't going to come in all at once. Let's build support for streaming the message in:

```ruby
stream = ParaMorse::StreamDecoder.new
stream.receive("1")
stream.receive("0")
stream.receive("1")
stream.receive("0")
stream.receive("1")
stream.receive("0")
stream.receive("1")
stream.receive("0")
stream.receive("0")
stream.receive("0")
stream.receive("1")
stream.receive("0")
stream.receive("1")
stream.receive("0")
stream.decode
# => "hi"
```

### Iteration 6: File I/O

We're going to start working with some big chunks of text. Let's add the capability to read and write files:

```ruby
file_enc = ParaMorse::FileEncoder.new
file_enc.encode("plain.txt", "encoded.txt")
# => (output the length of the written file)
# open the 'encoded.txt' file and verify that it's in morse
file_dec = ParaMorse::FileDecoder.new
file_dec.decode("encoded.txt", "plain_output.txt")
# => (output the length of the written file)
# open the "plain_output.txt" file and verify that it's in morse
```

### Iteration 7: Parallelization

Let's put the "Para" in "ParaMorse" by implementing parallel encoding and decoding.

```ruby

```

### Iteration 8: External Streaming

Let's hook into a broadcast stream and decode data in real-time.

```ruby

```
