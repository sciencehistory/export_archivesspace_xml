require 'open-uri'
require 'nokogiri'

module ExportArchivesspaceXml
  class CheckEadFilesForFatalErrors
    def check      
      schema = Nokogiri::XML::RelaxNG(File.open('ead.rng'))

      ead_links = Nokogiri::HTML(URI.open("https://#{CONFIG[:aws_bucket]}")).
        css('a').select { |link| link['href'] && link['href'].
        include?('ead') }.map { |link| link['href'] }
      
      all_errors = []
      ead_links.each do |ead_link|
        puts "Checking #{ead_link}"
        fatal_errors = schema.validate(Nokogiri::XML(URI.open(ead_link))).select {|e| e.fatal?  }
        unless fatal_errors.empty?
          fatal_errors.each do |error|
            puts "#{ead_link}: #{error.message}"
            all_errors << "#{ead_link}: #{error.message}"
          end
        end
      end

      if all_errors.empty?
        puts "No fatal errors found."
      end

    end
  end
end