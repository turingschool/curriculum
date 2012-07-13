class Encryptor
  def encrypt(message)
    # I0:
    # message

    # I1:
    # message.upcase

    # I2:
    # message.chars.to_a.reverse.join

    # I3:
    message.upcase.chars.to_a.collect do |c|
      13.times{c.next!}
      c
    end.join
  end

end