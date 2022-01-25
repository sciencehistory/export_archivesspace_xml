module ExportArchivesspaceXml
  require 'rubygems'
  require 'byebug'
  require 'json'
  require 'aws-sdk'
  require_relative 'config/config'
  require_relative 'export_archivesspace_xml/lib/exporter'
  require_relative 'export_archivesspace_xml/lib/index_page'
  Exporter.new.export
end