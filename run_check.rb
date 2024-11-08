module ExportArchivesspaceXml
  require 'rubygems'
  require 'byebug'
  require 'json'
  require 'aws-sdk'
  require_relative 'config/config'
  require_relative 'export_archivesspace_xml/lib/check_ead_files_for_fatal_errors'
  CheckEadFilesForFatalErrors.new.check
end