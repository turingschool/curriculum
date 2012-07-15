class Encryptor
  def cipher
    {"a" => "n", "b" => "o", "c" => "p", "d" => "q",
     "e" => "r", "f" => "s", "g" => "t", "h" => "u",
     "i" => "v", "j" => "w", "k" => "x", "l" => "y",
     "m" => "z", "n" => "a", "o" => "b", "p" => "c",
     "q" => "d", "r" => "e", "s" => "f", "t" => "g",
     "u" => "h", "v" => "i", "w" => "j", "x" => "k",
     "y" => "l", "z" => "m"}  
  end

  def encrypt(string, rotation)
    letters = string.split("")

    results = letters.collect do |letter|
      encrypt_letter(letter, rotation)
    end

    results.join
  end

  def decrypt(string, rotation)
    encrypt(string, -rotation)
  end

  def encrypt_letter(letter, rotation)
    letter_code = letter.ord
    result = letter_code + rotation
    result.chr
  end
end