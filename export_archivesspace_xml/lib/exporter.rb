module ExportArchivesspaceXml
    ##  http://science-history-institute-archives-ead.s3-website-us-east-1.amazonaws.com/
  class Exporter
    def export()
      collection_ids = []
      resources.each do |resource|
        id   = resource['uri'].split('/')[-1]
        puts "Starting #{id}."
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
      upload_file(index_page_html(collection_ids), 'index.html')
    end

    def get_ead(id)
      opts = { include_unpublished: false, include_daos: true}
      archivesspace_client.get("resource_descriptions/#{id}.xml", opts).body
    end

    def resources
      # TODO -- consider a `modified_since: '1612166400' ` date.
      archivesspace_client.resources(query: {'all_ids': 'true'})       
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
        bucket: "science-history-institute-archives-ead",
        key: key,
        server_side_encryption: "AES256",
        storage_class: "STANDARD_IA",
        content_type: "text/html",
        content_disposition: "inline"
      })
    end
  end
end