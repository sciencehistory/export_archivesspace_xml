require 'bundler/setup'
require 'rubygems'
load 'config/config.rb'

load 'export_archivesspace_xml/export_archivesspace_xml.rb'
ExportArchivesspaceXml::Exporter.new.export