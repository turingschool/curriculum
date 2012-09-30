module Jekyll
  
  #
  # This is the last resort Unknown Code Sample to ensure a decent error
  # message is displayed to an author.
  #
  class UnknownCodeSample

    def self.match(commit_information)
      warn "Unknown Code Sample: '#{commit_information}' could not be matched"
      true
    end

    def language
      ""
    end

    def code
      warn "An unknown use of the code sample tag has been used resulting in no code"
      ""
    end

  end

end