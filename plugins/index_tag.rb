require_relative 'page_url'

module Jekyll

  class PageNode
    
    attr_accessor :name, :directories, :pages
    
    def initialize(options = {})
      @directories = []
      @pages = []
      options.each do |key,value|
        send("#{key}=",value) if respond_to? "#{key}="
      end
    end
    
    def [](value)
      subdirectory = directories.find {|dir| dir.name == value }
      unless subdirectory
        newdirectory = PageNode.new :name => value
        directories << newdirectory
        subdirectory = newdirectory
      end
      subdirectory
    end
    
    def page_markdown_url(page)
      "[#{page.data["title"]}](#{File.join(page.dir,page.url)})"
    end
    
    def sorted_directories
      @directories.sort do |a,b|
        a.name.gsub(/\D/,'').to_i <=> b.name.gsub(/\D/,'').to_i
      end
    end
    
    def to_markdown(depth)
      sub_directory_markdown = sorted_directories.map {|d| d.to_markdown(depth + 1)}.join("\n")
      
      pages_markdown = pages.map {|page| "* #{page_markdown_url(page)}" }.join("\n")
      
      # "\n#{"#" * depth} #{name}\n#{sub_directory_markdown}\n#{pages_markdown}"
      "\n### #{name.to_s.capitalize}\n#{sub_directory_markdown}\n#{pages_markdown}"
    end
  end

  class IndexTag < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      super
      @path, @recursive = markup.split(" ")
    end

    def current_page(context)
      current_page_url = context.environments.first["page"]["url"]
      current_page_content = context.environments.first["page"]["content"]
      context.registers[:site].pages.find do |page| 
        page.content == current_page_content
      end
    end
    
    def render(context)
      site = context.registers[:site]
      this_page = current_page(context)
      
      pages_to_index = site.pages.find_all do |page|
        page.dir.start_with? File.join(this_page.dir,@path)
      end
      
      # convert all the files that are found here in a tree based on their path components
      
      tree_of_pages = PageNode.new
      
      pages_to_index.each do |page|
        
        path_to_work_with = page.dir.sub(this_page.dir,"")
        
        current_node = tree_of_pages
        
        path_to_work_with.split("/").each do |path_component|
          current_node = current_node[path_component]
        end
        
        current_node.pages << page
      end
      
      converter = context.registers[:site].converters.find do |converter| 
        converter.is_a? MarkdownConverter 
      end
      
      converter.convert tree_of_pages.to_markdown(0)
      
    end
  end
end

Liquid::Template.register_tag('index', Jekyll::IndexTag)