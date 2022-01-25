
# export_archivesspace_xml
This is a small Ruby (not Rails) project meant to run on Heroku, whose only purpose is to connect to our ArchivesSpace's API once a week and export .ead.xml files to a location on S3. They can be harvested there by various partners. All the important code can be found in `export_archivesspace_xml/lib/exporter.rb`.
More documentation can be found [in the wiki](https://chemheritage.atlassian.net/wiki/spaces/HDCSD/pages/2151514113/export+archivesspace+xml).
## Destination bucket
The files are uploaded to an s3 bucket; this is publicly accessible via a cname record at http://ead.sciencehistory.org/ .
## Index file
`index_page.rb` creates a very simple `index.html` file in the bucket. The file allows our partners to use a variation on the following command to download all our EAD files:
`wget -r http://ead.sciencehistory.org -A *.ead.xml` 
## Proxying
Because the Heroku dyno is assigned an arbitrary IP address when it spins up, we proxy outgoing traffic through a static address using the [Proximo Heroku add-on](https://elements.heroku.com/addons/proximo). This allows us to tell the ArchivesSpace API to accept connections only from the one whitelisted static IP address. See the Proximo docs for more details.
## Configuration
This is done via environment variables set on the Heroku project. Here are some of the important ones:
### ArchivesSpace API settings
These allow the code to contact ArchivesSpace and download the EADs.
  - `ARCHIVESSPACE_URL`
 - `ARCHIVESSPACE_EXPORT_USERNAME`
 - `ARCHIVESSPACE_EXPORT_PASSWORD`
### S3 settings
These are needed so the code knows where to put the files.
 - `AWS_BUCKET`
 - `AWS_REGION`
 - `AWS_ACCESS_KEY_ID`
 - `AWS_SECRET_ACCESS_KEY`
Note: The IAM permissions associated with this key pair in S3 are minimal: the code can only write files to the ead bucket.
### Settings set by Heroku
We don't manage these- they're set by Heroku for our add-ons.
- `PROXIMO_URL`
- `PAPERTRAIL_API_TOKEN`
## Scheduler add-on
The project does *not* include a web dyno, and relies on the Heroku Scheduler to spin up a nightly process, as follows:
    `$ bin/proximo bundle exec ruby run.rb`