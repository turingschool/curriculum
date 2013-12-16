require 'pdfkit'
require './plugins/post_filters'
require './plugins/page_url'

module Jekyll

  class PDFGenerator < PostFilter

    def post_write(content)
      generate_pdf(content) if content.data['pdf']
    end

    def generate_pdf(content)
      return true
      # filepath = "public#{content.dir}#{content.url}"
      # pdf_filepath = "#{filepath[0..-5]}pdf"
      # puts "Converting #{filepath} into #{pdf_filepath}"
      # pdf = PDFKit.new content.content, "print-media-type" => true
      # pdf.stylesheets << "source/stylesheets/screen.css"
      # pdf.to_file pdf_filepath
    end

  end

end
