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

  def encrypt_file(filename, rotation)
    # 1. Create the file handle to the input file
    input = File.open(filename, "r")

    # 2. Read the text of the input file
    input_text = input.read

    # 3. Encrypt the text
    encrypted_text = encrypt(input_text, rotation)

    # 4. Create a name for the output file
    output_filename = filename + ".encrypted"

    # 5. Create an output file handle
    output = File.open(output_filename, "w")

    # 6. Write out the text
    output.write(encrypted_text)

    # 7. Close the file
    output.close
  end

  def decrypt_file(filename, rotation)
    input = File.open(filename, "r:ASCII-8BIT")
    input_text = input.read
    decrypted_text = decrypt(input_text, rotation)
    output_filename = filename.gsub("encrypted", "decrypted")
    output = File.open(output_filename, "w")
    output.write(decrypted_text)
    output.close
  end

end