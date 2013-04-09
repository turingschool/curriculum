require 'open-uri'
require 'certified'
require './plugins/pygments_code'
require './plugins/raw'

require './plugins/code_sample/github_code_sample_commit'
require './plugins/code_sample/filepath_code_sample_commit'
require './plugins/code_sample/gist_code_sample_commit'
require './plugins/code_sample/unknown_code_sample'

module Jekyll

  #
  # The following tag allows an author to link a file in a public github
  # repository at it's particular commit. The purpose is allow for easier
  # integration of tutorial content as it would be presented from the source
  # and no longer copy and pasted into the page or post.
  #
  # {% codesample github user@repository file:commit %}
  # {% codesample file filepath file:commit }
  #
  class CodeSampleTag < Liquid::Tag
    include HighlightCode
    include TemplateWrapper

    attr_reader :sample

    def samplers
      [ GithubCodeSampleCommit,
        FilepathCodeSampleCommit,
        GistCodeSampleCommit,
        UnknownCodeSample
       ]
    end

    def initialize(tag_name, markup, tokens)
      super
      sampler = samplers.find {|sampler| sampler.match(markup) }
      @sample = sampler.new(markup)
    end

    def render(context)
      source = "<figure class='code'>#{highlight(sample.code,sample.language)}</figure>"
      source = safe_wrap(source)

      pygments_prefix = context['pygments_prefix']
      source = pygments_prefix + source if pygments_prefix
      source = source + pygments_prefix if pygments_prefix

      source
    end

  end
end

Liquid::Template.register_tag('codesample', Jekyll::CodeSampleTag)
