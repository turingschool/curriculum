The following list attempts to document the knowledge/skills a developer needs to be "proficient" in Ruby. It is not intended to be exhaustive, and likely many points can be debated.

## Ruby

### Classes

* Basic structure
* Writing instance methods
* Writing class methods
  * Using `self`
  * Using `class << self`
* Parameters
  * Finite
  * With Default Values
  * Named Parameters with Hashes
    * Combining with default values
* Modules
  * Basic Construction
  * Use in Namespacing
  * Used for Class Decomposition
    * Writing Instance Methods
    * Writing Class Methods
    * `include` vs `extend`
    * Using `self.included`
    * Using `ActiveSupport::Concern`
  * Testing a module
  * Method lookup chain

### Basic Objects
  
#### String

##### Concepts

* Creating / Definition
* Single vs. Double Quoted Strings
* Combining Strings and Other Data
  * Concatenation with `+`
  * Wrapping in an Array and using `join`
  * Interpolating
* Implications of UTF8 encoding and Ruby 1.9
* Implications of "Normal" and "Bang" method variants
* Differences between strings and symbols
* Memory requirements/usage of string creation and manipulation

##### Essential Methods

* Core Ruby
  * `chomp`
  * `strip`
  * `match`
  * `capitalize` / `downcase` / `upcase`
  * `each_char` / `chars`
  * `empty?`
  * `gsub`
  * `delete`
  * `replace`
  * `reverse`
  * `split`
  * `length`
  * `include?`
  * `<=>`
  * `[]`
  * `<<`
  * `=~`
  * `to_i` / `to_f`
* With `ActiveSupport`
  * `titleize`
  * `humanize`
  * `parameterize`
  * `pluralize` / `singularize`

#### Fixnum

##### Concepts

* Numbers in Ruby are Objects
  * We can call methods on numbers
  * We can define methods on numbers
* Tricks with Numbers
  * Integer with Integer gives Integer
  * Integer with Float gives Float
  * Calling `to_i` on a String
* Truth
  * 0 is truthy
* Order of Operations

##### Essential Methods

* Core Ruby
  * Core Math Operators (`+`, `-`, `*`, `/`)
  * Modulo `%`
  * `times`
  * `to_s` / `to_f`
* With `ActiveSupport`
  * Date/Time Extensions: `.hours`, `.days`, `.weeks`, `.months`, `.years`, `.ago`/`.until`, `.since`/`.from_now`
  * Byte Extensions: `.bytes`, `.kilobytes`, `.megabytes`, `.gigabytes`
  * `ordinalize`

#### Float

##### Concepts

* Challenges when using Floats
  * Math is not precise
  * Formatting can be more difficult
* Alternatives
  * `BigDecimal`
  * Avoiding fractional components
* Using `Kernel.format`
* Whole Number Math vs. Fractional Math (ex: `1.0/2` vs `1/2`)

##### Essential Methods

* Core Ruby
  * Core Math Operators (`+`, `-`, `*`, `/`)
  * `ceil` 
  * `to_i` / `floor`
  * `to_s`  

#### Regular Expressions

##### Concepts

* Regular expressions are about matching patterns
* Used for:
  * validating formats
  * extracting data

##### Writing Expressions

* Formatting
  * Start and end with `/`
  * Other formats exist, but are less commonly used
* Matchers
  * Plain Text
  * Any of the letters a, b, c: `[abc]`
  * Any of the letters except a, b, c: `[^abc]`
  * Any single character in the range a-z: `[a-z]`
  * Any single character in the range a-z or A-Z: `[a-zA-Z]`
  * Any single character: `.` 
  * Any whitespace character: `\s`
  * Any non-whitespace character: `\S`
  * Any digit: `\d`
  * Any non-digit: `\D`
  * Any word character (letter, number, underscore): `\w`
  * Any non-word character: `\W`
* Quantifiers
  * Zero or one of a: `a?`
  * Zero or more of a: `a*`
  * One or more of a: `a+`
  * Exactly 3 of a: `a{3}`
  * 3 or more of a: `a{3,}`
  * Between 3 and 6 of a: `a{3,6}`
* Anchors
  * Start of line: `^` 
  * End of line: `$` 
* Alternatives
  * Either a or b: `(a|b)`
* Captures
  * Capture everything enclosed: `(...)`

##### Essential Usages

* Extracting Data
  * Use the `.match` method
  * Returns a `MatchData` object
  * Query `MatchData` for captures
* Validating Format
  * Use the `=~` operator
  * Often used in conditions

#### Range

##### Concepts

* Specify a set of continuous values
* Used most commonly with strings and integers
  * Examples: `1..3`, `1...3`, `a..z`, `A..z`

##### Essential Methods

* `.to_a`
* `.each`

##### Essential Usages

* With iterations
* With `case` statements
* Pulling substrings of strings
* Pulling subsets of collections

#### Date and Time

### Collections

#### Array

#### Hash

#### Enumerable

#### Set

### Rails

### JavaScript

### Systems & Tooling

### Software Engineering

### Design

### Other Topics