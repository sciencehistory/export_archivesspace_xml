module ExportArchivesspaceXml
  ##  http://science-history-institute-archives-ead.s3-website-us-east-1.amazonaws.com/
  class Exporter
    def export()
      collection_ids = []

      list_of_eads_to_export = CONFIG[:export_only].nil? ? nil : CONFIG[:export_only].split(',')

      resources(recent: CONFIG[:export_only_recent_eads]).each do |resource|
        next unless  resource['publish']

        id   = resource['uri'].split('/')[-1]

        unless list_of_eads_to_export.nil?
          next unless list_of_eads_to_export.include? id
        end


        puts "Starting collection #{id}."
        collection_ids << id
        new_filename ="#{id}.ead.xml"
        file = Tempfile.new(new_filename)
        begin
          file << get_ead(id)
          file.rewind
          file.flush
          save_file(file, new_filename)
        ensure
          file.close
          file.unlink
        end
      end

      unless CONFIG[:skip_index] == 'true'
        puts "Uploading index page"
        all_resources = resources(recent: nil)
        all_collection_ids = all_resources.select {|r| r['publish'] }.map { |r| r['uri'].split('/')[-1]}.to_a
        save_file(IndexPage.new.html(all_collection_ids), 'index.html')
      end
    end

    def get_ead(id)
      opts = { include_unpublished: false, include_daos: true }
      archivesspace_client.get("resource_descriptions/#{id}.xml", opts).body
    end

    # A list of resource ids in the repository.
    # If an integer `recent` is specified, then
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
      @archivesspace_client ||= begin
        puts "Connecting to ArchivesSpace."
        if API_CONFIG.username.empty? || API_CONFIG.password.empty?
          raise "Could not find a username or a password for the ArchivesSpace API."
        end
        if API_CONFIG.base_uri.empty?
          raise "Could not find a URL for the ArchivesSpace API."
        end
        cli = ArchivesSpace::Client.new(ExportArchivesspaceXml::API_CONFIG).login
        if cli.is_a? ArchivesSpace::Client
          puts "Connected to ArchivesSpace."
        end
        cli
      end
    end

    def aws_client
      @aws_client ||= begin
        if CONFIG[:aws_access_key_id].nil? ||  CONFIG[:aws_secret_access_key].nil? ||  CONFIG[:aws_region].nil?
          raise "Could not find AWS credentials."
        end
        Aws::S3::Client.new(
          access_key_id:     CONFIG[:aws_access_key_id],
          secret_access_key: CONFIG[:aws_secret_access_key],
          region:            CONFIG[:aws_region]
        )
      end
    end

    def save_file(body, filename)
      if CONFIG[:debug_export_path].nil?
        # upload to S3
        aws_client.put_object({
          body: body,
          bucket: CONFIG[:aws_bucket],
          key: filename,
          server_side_encryption: "AES256",
          storage_class: "STANDARD_IA",
          content_type: "text/html",
          content_disposition: "inline"
        })
      else
        # Save file locally.
        File.open("#{CONFIG[:debug_export_path]}/#{filename}", "w") { |f| f.write body.read }
      end
    end
  end
end