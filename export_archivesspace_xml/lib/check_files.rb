module ExportArchivesspaceXml
  class CheckFiles
    def check      
      require 'open-uri'
      require 'nokogiri'
      url = "https://#{CONFIG[:aws_bucket]}"
      schema = Nokogiri::XML::RelaxNG(File.open('ead.rng'))
      html = URI.open(url)
      doc = Nokogiri::HTML(html)
      ead_links = doc.css('a').select { |link| link['href'] && link['href'].include?('ead') }.map { |link| link['href'] }
      all_errors = []
      ead_links[0..10].each do |ead_link|
        puts ead_link
        ead_xml = URI.open(ead_link)
        xml_doc = Nokogiri::XML(ead_xml)
        errors = schema.validate(xml_doc)
        unless errors.empty?
          puts "    The file at #{ead_link} has schema validation errors:"
          errors.each do |error|
            puts error.message
            all_errors << errors
          end
        end
      end
    end
  end
end