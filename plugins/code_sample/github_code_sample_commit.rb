module Jekyll

  class GithubCodeSampleCommit

    attr_reader :user, :repo, :file, :commit

    #
    # {% codesample github name@repo commit:filepath }
    #
    def self.match(commit_information)
      not convert_input(commit_information).empty?
    end

    def initialize(commit_information)
      @user, @repo, @commit, @file = self.class.convert_input(commit_information)
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
      open(url).read
    rescue Exception => exception
      puts "Error retrieving code from the URL: #{url}\n\n#{exception}"
      ""
    end

    #
    # Generate a url to the raw file in the Github repository
    #
    # @example
    #
    #     https://raw.github.com/burtlo/eventmanager/b13e4e56b5455f2446d95ec38ba21f673d1c3d25/event_manager.rb
    #     https://raw.github.com/burtlo/eventmanager/7851/event_manager.rb
    #
    def url
      "https://raw.github.com/#{user}/#{repo}/#{commit}/#{file}"
    end

    #
    # Converts input to the parameters
    #
    # @example input string "github burtlo@eventmanager 7851:event_manager.rb"
    #
    #     [ "burtlo", "eventmanager", "7851", "event_manager.rb" ]
    #
    # @see http://rubular.com/r/VA18Rg92vB
    #
    def self.convert_input(input_string)
      result = /github ([^@\s]+)@([^\s+]+) ([a-fA-F0-9]+):([^\s+]+)/.match(input_string)
      Array(Array(result)[1..-1])
    end

  end

end