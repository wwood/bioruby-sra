module Bio
  module SRA
    class Connection < ActiveRecord::Base
      self.abstract_class = true
      
      # Connect to a metadata database.
      #
      # * sra_metadb_path: a path to the gunzipped SRAmetadb.sqlite file which is the database. By default this is in the db/ directory of this gem, but that probably isn't where the db file is.
      #
      # You can download the file like so:
      #
      #    $ wget http://watson.nci.nih.gov/~zhujack/SRAmetadb.sqlite.gz
      #    # gunzip SRAmetadb.sqlite.gz
      def self.connect(sra_metadb_path=File.join(File.dirname(__FILE__),'..','..','..','db','SRAmetadb.sqlite'))
        log = Bio::Log::LoggerPlus['bio-sra']
        log.info "Attempting to connect to database #{sra_metadb_path}"
        
        # default:
          # adapter: sqlite3
          # database: db/SRAmetadb.sqlite
          # pool: 5
          # timeout: 5000
          
        options = {
          :adapter => 'sqlite3',
          :database => sra_metadb_path,
          :pool => 5,
          :timeout => 5000,
        }
        
        establish_connection(options)
      end
    end
  end
end