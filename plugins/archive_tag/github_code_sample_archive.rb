module Jekyll
  
  #
  # Generates a url that will grant access to an archive on github
  # based on the tag.
  #
  class GithubCodeSampleArchive

    attr_reader :user, :repo, :tag, :title

    def initialize(archive_information)
      @user, @repo, @tag, @title = convert_input(archive_information)
    end

    #
    # @example https://github.com/burtlo/eventmanager/zipball/iteration-alpha
    #
    def url
      "https://github.com/#{user}/#{repo}/zipball/#{tag}"
    end

    #
    # Converts input to the parameters
    #
    # @example input_string "burtlo@eventmanager tag title"
    #
    #     [ "burtlo", "eventmanager", "tag", "title" ]
    #
    def convert_input(input_string)
      result = /([^@]+)@([^\s+]+) ([^\s+]+) (.+)/.match(input_string)
      Array(result)[1..-1]
    end

  end

end