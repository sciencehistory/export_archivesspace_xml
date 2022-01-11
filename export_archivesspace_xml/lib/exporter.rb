module ExportArchivesspaceXml
    ##  http://science-history-institute-archives-ead.s3-website-us-east-1.amazonaws.com/
  class Exporter
    def export()
      collection_ids = []
      resources(recent: ENV['EXPORT_ONLY_RECENT_EADS']).each do |resource|
        id   = resource['uri'].split('/')[-1]
        puts "Starting collection #{id}."
        collection_ids << id
        new_filename ="#{id}.ead.xml"
        file = Tempfile.new(new_filename)
        begin
          file << get_ead(id)
          file.rewind
          file.flush
          upload_file(file, new_filename)
        ensure
           file.close
           file.unlink
        end
      end
      puts "Uploading index page"
      all_resources = resources(recent: nil)
      all_collection_ids = all_resources.map { |r| r['uri'].split('/')[-1]}.to_a
      upload_file(index_page_html(all_collection_ids), 'index.html')
    end

    def get_ead(id)
      opts = { include_unpublished: false, include_daos: true }
      archivesspace_client.get("resource_descriptions/#{id}.xml", opts).body
    end

    # A list of resource ids in the repository.
    # If an integer `recent` is specisfied, then
    # only export items modified in the past `recent` days.
    def resources(recent: nil)
      options = {include_unpublished: false, all_ids: true }
      unless recent.nil?
        unix_date = Time.now.to_i - recent.to_i * 24 * 60 * 60
        options.merge!({ modified_since: unix_date })
      end
      archivesspace_client.resources(query: options)
    end

    def archivesspace_client
      if ExportArchivesspaceXml::CONFIG.username.empty? || ExportArchivesspaceXml::CONFIG.password.empty?
        raise "Could not find a username or a password for the ArchivesSpace API."
      end
      if ExportArchivesspaceXml::CONFIG.base_uri.empty?
        raise "Could not find a URL for the ArchivesSpace API."
      end
      @archivesspace_client = ArchivesSpace::Client.new(ExportArchivesspaceXml::CONFIG).login
    end

    def aws_client
      @aws_client ||= begin
        if ENV['AWS_ACCESS_KEY_ID'].nil? ||  ENV['AWS_SECRET_ACCESS_KEY'].nil? ||  ENV['AWS_REGION'].nil?
          raise "Could not find AWS credentials."
        end
        Aws::S3::Client.new(
          access_key_id:     ENV["AWS_ACCESS_KEY_ID"],
          secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
          region:            ENV["AWS_REGION"]
        )
      end
    end


    def upload_file(body, key)
      aws_client.put_object({
        body: body,
        bucket: ENV["AWS_BUCKET"],
        key: key,
        server_side_encryption: "AES256",
        storage_class: "STANDARD_IA",
        content_type: "text/html",
        content_disposition: "inline"
      })
    end
  end
end