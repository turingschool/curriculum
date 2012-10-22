module Jekyll

  class GistCodeSampleCommit

    attr_reader :gist, :commit, :file

    #
    # {% codesample gist gistref commit:filepath }
    #
    def self.match(commit_information)
      not convert_input(commit_information).empty?
    end

    def initialize(commit_information)
      @gist, @commit, @file = self.class.convert_input(commit_information)
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
      
      content = open(url).read
      puts content
      
      content
    rescue
      puts "Error retrieving gist code from the URL: #{url}"
      ""
    end

    #
    # Generate a url to the raw file in the Github gist library
    #
    # @example 
    #
    #     https://raw.github.com/gist/3788048/572b38659fc0d4d372d953ea4ac7f7ca5c1bcdcc/readme.md
    #
    def url
      "https://raw.github.com/gist/#{gist}/#{commit}/#{file}"
    end

    #
    # Converts input to the parameters
    #
    # @example input string "gist 3788048 572b38659fc0d4d372d953ea4ac7f7ca5c1bcdcc:readme.md"
    #
    #     [ "3788048", "572b38659fc0d4d372d953ea4ac7f7ca5c1bcdcc", "readme.md" ]
    #
    # @see http://rubular.com/r/7XVPT2fZ3y
    #
    def self.convert_input(input_string)
      result = /gist ([^\s+]+) ([a-fA-F0-9]+):([^\s+]+)/.match(input_string)
      Array(Array(result)[1..-1])
    end

  end

end