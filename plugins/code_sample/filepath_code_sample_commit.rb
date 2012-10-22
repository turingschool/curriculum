module Jekyll

  class FilepathCodeSampleCommit

    attr_reader :filepath, :file, :commit

    #
    # {% codesample file filepath commit:file }
    #
    def self.match(commit_information)
      not convert_input(commit_information).empty?
    end

    def initialize(commit_information)
      @filepath, @commit, @file = self.class.convert_input(commit_information)
    end

    # 
    # The programming language of the specified code. This is currently the
    # extension of the filename.
    #
    def language
      File.extname(@file)[1..-1] || "ru"
    end

    #
    # The code associated with the commit.
    # @return a string that contain the code from the specified file. If
    #   not found it will return an empty string
    #
    def code
      `cd #{filepath} && git show #{commit}:#{file}`
    rescue
      puts "Error retrieving code from the filepath: #{filepath}
            > git show #{commit}:#{file}"
      ""
    end

    #
    # Converts input to the parameters
    #
    # @example "file file/path 7851:event_manager.rb"
    #
    #     [ "file/path", "7851", "event_manager.rb" ]
    #
    # @see http://rubular.com/r/EN9YkitSOn
    #
    def self.convert_input(input_string)
      result = /file ([^\s+]+) ([a-fA-F0-9]+):([^\s+]+)/.match(input_string)
      Array(Array(result)[1..-1])
    end

  end

end