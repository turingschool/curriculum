require './plugins/archive_tag/github_code_sample_archive'

module Jekyll

  class ArchiveTag < Liquid::Block

    attr_reader :archive

    #
    # The following tag allows you to create a link to a tagged repository
    #
    # {% archive repository tag-name %}
    # {% archive burtlo@eventmanager iteration-alpha Source Code for Iteration 0 %}
    # This contains all the source code for all the steps up to this point.
    # {% endarchive}
    #
    def initialize(tag_name, markup, tokens)
      super
      @archive = GithubCodeSampleArchive.new(markup)
    end

    def render(context)
      description = super(context)
      
      "<div class='download'>
        <img src='/images/download_tag.png'/>
        <div class='title'>
          <a href='#{archive.url}'>#{archive.title}</a>
        </div>
        <div class='description'>
        #{description}
        </div>
       </div>"
    end

  end

end

Liquid::Template.register_tag('archive', Jekyll::ArchiveTag)