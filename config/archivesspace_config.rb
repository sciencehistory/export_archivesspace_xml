require 'archivesspace/client'
module ExportArchivesspaceXml
  ExportArchivesspaceXml::CONFIG = ArchivesSpace::Configuration.new({
    base_uri: "#{ENV['ARCHIVESSPACE_URL']}",
    base_repo: "repositories/3",
    username: "#{ENV['ARCHIVESSPACE_EXPORT_USERNAME']}",
    password: "#{ENV['ARCHIVESSPACE_EXPORT_PASSWORD']}",
    debug: false,
    page_size: 50,
    throttle: 0.5,
    verify_ssl: false
  })
end