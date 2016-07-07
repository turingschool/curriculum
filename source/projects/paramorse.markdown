# ParaMorse

> Morse code is a method of transmitting text information as a series of on-off tones, lights, or clicks that can be directly understood by a skilled listener or observer without special equipment.

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
# => 11101100101010101010100010101010 (to be filled in later)
decoder = ParaMorse::Decoder.new
decoder.decode("11101100101010101010100010101010")
# => "This is my message"
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

Before we start encoding big message we'd better prove that we can decode letters
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
# => 11101100101010101010100010101010 (to be filled in later)
decoder = ParaMorse::Decoder.new
decoder.decode("11101100101010101010100010101010")
# => "Word"
```

### Iteration 4: Multiple Words

### Iteration 5: Streaming & Stacks

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

### Iteration 6: Parallelization

### Iteration 7: External Streaming
