require 'archivesspace/client'
module ExportArchivesspaceXml
  API_CONFIG = ArchivesSpace::Configuration.new({
    base_repo: 'repositories/3',
    base_uri: ENV['ARCHIVESSPACE_URL'],
    username: ENV['ARCHIVESSPACE_EXPORT_USERNAME'],
    password: ENV['ARCHIVESSPACE_EXPORT_PASSWORD'],
    debug: false,
    page_size: 50,
    throttle: 0.5,
    timeout: ENV['TIMEOUT'],
    verify_ssl: false
  })
  CONFIG = {
    debug_export_path:       ENV['DEBUG_EXPORT_PATH'],
    export_only_recent_eads: ENV['EXPORT_ONLY_RECENT_EADS'],
    aws_access_key_id:       ENV['AWS_ACCESS_KEY_ID'],
    aws_secret_access_key:   ENV['AWS_SECRET_ACCESS_KEY'],
    aws_region:              ENV['AWS_REGION'],
    aws_bucket:              ENV['AWS_BUCKET'],
    skip_index:              ENV['SKIP_INDEX'],
    export_only:             ENV['EXPORT_ONLY'],
  }
end