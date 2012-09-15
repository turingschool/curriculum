module Jekyll

  class Page
    
    # Monkey-patching to gain access to the instance variable directory
    # value which is not the value that is returned when calling `#dir`.
    # The original value that is returned is based on the `#url` and 
    # that seems to believe that all of the files are located in the
    # root directory `/`.
    def dir
      @dir
    end
    
  end


  class PageComparer
    attr_reader :slug

    def initialize(name)
      extension = File.extname(name)
      @basename = File.basename(name)[0..-extension.length-1]
      
      @dirname = File.dirname(name)
      @dirname = "" if @dirname == "."
      
    end
    
    def matches?(page)
      page.basename == @basename and page.dir.include? @dirname 
    end
  end

  class PageUrl < Liquid::Tag
    def initialize(tag_name, page, tokens)
      super
      @original_page = page.strip
      @page = PageComparer.new(@original_page)
    end

    def render(context)
      site = context.registers[:site]
      
      site.pages.each do |page|
        return "#{page.dir}#{page.url}" if @page.matches? page
      end

      puts "ERROR: page_url: \"#{@original_page}\" could not be found"

      return "#"
    end
  end
end

Liquid::Template.register_tag('page_url', Jekyll::PageUrl)