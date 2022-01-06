module ExportArchivesspaceXml
  def index_page_html(collection_ids)
    list = collection_ids.map do |id|
      "<li><a href =\"http://#{ENV["AWS_BUCKET"]}/#{id}.ead.xml\" >#{id}</a></li>"
    end.join

    index = "<html xmlns=\"http://www.w3.org/1999/xhtml\" >
    <head>
        <title>Science History Institute EADs</title>
    </head>
    <body>
      <h1>Encoded archival descriptions (EAD)s</h1>
      <ul>
      #{list}
      </ul>
    </body>
    </html>"
    
    index
  end
end