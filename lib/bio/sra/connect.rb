module Bio
  module SRA
    class DummyConn < ActiveRecord::Base
      self.abstract_class = true
      root_path = File.join(File.dirname(__FILE__),"../../../")
      configurations =  YAML.load_file(File.join(root_path,"config/database.yml"))
      configurations.each_pair do |key, db_info|
        db_info["database"] = File.join(root_path, db_info["database"]) if db_info["adapter"]=='sqlite3'
      end
      establish_connection(configurations["default"])
    end
  end
end