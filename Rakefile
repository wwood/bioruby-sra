# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "bio-sra"
  gem.homepage = "http://github.com/wwood/bioruby-sra"
  gem.license = "MIT"
  gem.summary = %Q{TODO: one-line summary of your gem}
  gem.description = %Q{TODO: longer description of your gem}
  gem.email = "donttrustben near gmail.com"
  gem.authors = ["Ben J. Woodcroft"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "bio-sra #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end# encoding: utf-8
Encoding.default_external = Encoding::UTF_8

$LOAD_PATH.unshift File.join(File.dirname(__FILE__),'lib')
require 'active_support'
require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/module/delegation'
require 'active_record'

namespace :db do
  namespace :schema do
    desc 'Dump out the schema in markdown format suitable for inclusion at https://github.com/wwood/bioruby-sra/wiki/MetadatabaseSchema' 
    task :dump_wiki_format do
      require 'bio-sra'
      include Bio::SRA::Tables
      Bio::SRA.connect
      
      # grep 'class ' lib/bio/sra/tables.rb |awk '{print $2}'
      tables = [SRA,
        Submission,
        Experiment,
        Run,
        Sample,
        Study,
        SRAFt,
        SRAFtContent,
        SRAFtSegDir,
        SRAFtSegments,
        MetaInfo,
        ColDesc]
      tables.each do |table|
        puts "### #{table}"
        puts "table name in database: #{table.table_name}"
        ColDesc.where(:table_name => table.table_name).limit(3).all.each do |c|
          puts c.field_name
          f = c.field_name
          unless table.first.respond_to?(f.to_sym) #e.g. ID => submission_ID
            f = "#{c.table_name}_#{f}"
          end
          if table.first.respond_to?(f.to_sym)
            puts "* **#{c.field_name}** #{c.description} "+
              "e.g. #{table.limit(2).where("#{f} not null").all.collect{|e| e.send(f.to_sym)}.join(', or ')}"
          else
            puts "* **#{c.field_name}** undocumented in the col_desc table"
          end
        end
      end
    end
  end
end

#This code is coming from activerecord-3.0.7/lib/active_record/railties/databases.rake
namespace :db do
  task :load_config do
    require 'active_record'
    ActiveRecord::Base.configurations = YAML.load_file("config/database.yml")
  end

  task :environment => :load_config do
    ActiveRecord::Base.establish_connection('default')
  end

  namespace :create do
    # desc 'Create all the local databases defined in config/database.yml'
    task :all => :load_config do
      ActiveRecord::Base.configurations.each_value do |config|
        # Skip entries that don't have a database key, such as the first entry here:
        #
        #  defaults: &defaults
        #    adapter: mysql
        #    username: root
        #    password:
        #    host: localhost
        #
        #  development:
        #    database: blog_development
        #    <<: *defaults
        next unless config['database']
        # Only connect to local databases
        local_database?(config) { create_database(config) }
      end
    end
  end

  desc 'Create the database from config/database.yml for the current default (use db:create:all to create all dbs in the config)'
  task :create => :load_config do
    # Make the test database at the same time as the development one, if it exists
#    if 'default'.development? && ActiveRecord::Base.configurations['test']
      create_database(ActiveRecord::Base.configurations['default'])
#    end
#    create_database(ActiveRecord::Base.configurations['default'])
  end

  def create_database(config)
    begin
      if config['adapter'] =~ /sqlite/
        if File.exist?(config['database'])
          $stderr.puts "#{config['database']} already exists"
        else
          begin
            # Create the SQLite database
            ActiveRecord::Base.establish_connection(config)
            ActiveRecord::Base.connection
          rescue Exception => e
            $stderr.puts e, *(e.backtrace)
            $stderr.puts "Couldn't create database for #{config.inspect}"
          end
        end
        return # Skip the else clause of begin/rescue
      else
        ActiveRecord::Base.establish_connection(config)
        ActiveRecord::Base.connection
      end
    rescue
      case config['adapter']
      when /mysql/
        @charset   = ENV['CHARSET']   || 'utf8'
        @collation = ENV['COLLATION'] || 'utf8_unicode_ci'
        creation_options = {:charset => (config['charset'] || @charset), :collation => (config['collation'] || @collation)}
        error_class = config['adapter'] =~ /mysql2/ ? Mysql2::Error : Mysql::Error
        access_denied_error = 1045
        begin
          ActiveRecord::Base.establish_connection(config.merge('database' => nil))
          ActiveRecord::Base.connection.create_database(config['database'], creation_options)
          ActiveRecord::Base.establish_connection(config)
        rescue error_class => sqlerr
          if sqlerr.errno == access_denied_error
            print "#{sqlerr.error}. \nPlease provide the root password for your mysql installation\n>"
            root_password = $stdin.gets.strip
            grant_statement = "GRANT ALL PRIVILEGES ON #{config['database']}.* " \
              "TO '#{config['username']}'@'localhost' " \
              "IDENTIFIED BY '#{config['password']}' WITH GRANT OPTION;"
            ActiveRecord::Base.establish_connection(config.merge(
                'database' => nil, 'username' => 'root', 'password' => root_password))
            ActiveRecord::Base.connection.create_database(config['database'], creation_options)
            ActiveRecord::Base.connection.execute grant_statement
            ActiveRecord::Base.establish_connection(config)
          else
            $stderr.puts sqlerr.error
            $stderr.puts "Couldn't create database for #{config.inspect}, charset: #{config['charset'] || @charset}, collation: #{config['collation'] || @collation}"
            $stderr.puts "(if you set the charset manually, make sure you have a matching collation)" if config['charset']
          end
        end
      when 'postgresql'
        @encoding = config['encoding'] || ENV['CHARSET'] || 'utf8'
        begin
          ActiveRecord::Base.establish_connection(config.merge('database' => 'postgres', 'schema_search_path' => 'public'))
          ActiveRecord::Base.connection.create_database(config['database'], config.merge('encoding' => @encoding))
          ActiveRecord::Base.establish_connection(config)
        rescue Exception => e
          $stderr.puts e, *(e.backtrace)
          $stderr.puts "Couldn't create database for #{config.inspect}"
        end
      end
    else
      $stderr.puts "#{config['database']} already exists"
    end
  end

  namespace :drop do
    # desc 'Drops all the local databases defined in config/database.yml'
    task :all => :load_config do
      ActiveRecord::Base.configurations.each_value do |config|
        # Skip entries that don't have a database key
        next unless config['database']
        begin
          # Only connect to local databases
          local_database?(config) { drop_database(config) }
        rescue Exception => e
          $stderr.puts "Couldn't drop #{config['database']} : #{e.inspect}"
        end
      end
    end
  end

  desc 'Drops the database for the current default (use db:drop:all to drop all databases)'
  task :drop => :load_config do
    config = ActiveRecord::Base.configurations['default' || 'development']
    begin
      drop_database(config)
    rescue Exception => e
      $stderr.puts "Couldn't drop #{config['database']} : #{e.inspect}"
    end
  end

  def local_database?(config, &block)
    if %w( 127.0.0.1 localhost ).include?(config['host']) || config['host'].blank?
      yield
    else
      $stderr.puts "This task only modifies local databases. #{config['database']} is on a remote host."
    end
  end

  desc "Migrate the database (options: VERSION=x, VERBOSE=false)."
  task :migrate => :environment do
    ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
    ActiveRecord::Migrator.migrate("db/migrate/", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
    Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
  end

  namespace :migrate do
    # desc  'Rollbacks the database one migration and re migrate up (options: STEP=x, VERSION=x).'
    task :redo => :environment do
      if ENV["VERSION"]
        Rake::Task["db:migrate:down"].invoke
        Rake::Task["db:migrate:up"].invoke
      else
        Rake::Task["db:rollback"].invoke
        Rake::Task["db:migrate"].invoke
      end
    end

    # desc 'Resets your database using your migrations for the current environment'
    task :reset => ["db:drop", "db:create", "db:migrate"]

    # desc 'Runs the "up" for a given migration VERSION.'
    task :up => :environment do
      version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
      raise "VERSION is required" unless version
      ActiveRecord::Migrator.run(:up, "db/migrate/", version)
      Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
    end

    # desc 'Runs the "down" for a given migration VERSION.'
    task :down => :environment do
      version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
      raise "VERSION is required" unless version
      ActiveRecord::Migrator.run(:down, "db/migrate/", version)
      Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
    end

    desc "Display status of migrations"
    task :status => :environment do
      config = ActiveRecord::Base.configurations['default']
      ActiveRecord::Base.establish_connection(config)
      unless ActiveRecord::Base.connection.table_exists?(ActiveRecord::Migrator.schema_migrations_table_name)
        puts 'Schema migrations table does not exist yet.'
        next  # means "return" for rake task
      end
      db_list = ActiveRecord::Base.connection.select_values("SELECT version FROM #{ActiveRecord::Migrator.schema_migrations_table_name}")
      file_list = []
      Dir.foreach(File.join('db', 'migrate')) do |file|
        # only files matching "20091231235959_some_name.rb" pattern
        if match_data = /(\d{14})_(.+)\.rb/.match(file)
          status = db_list.delete(match_data[1]) ? 'up' : 'down'
          file_list << [status, match_data[1], match_data[2]]
        end
      end
      # output
      puts "\ndatabase: #{config['database']}\n\n"
      puts "#{"Status".center(8)}  #{"Migration ID".ljust(14)}  Migration Name"
      puts "-" * 50
      file_list.each do |file|
        puts "#{file[0].center(8)}  #{file[1].ljust(14)}  #{file[2].humanize}"
      end
      db_list.each do |version|
        puts "#{'up'.center(8)}  #{version.ljust(14)}  *** NO FILE ***"
      end
      puts
    end
  end

  desc 'Rolls the schema back to the previous version (specify steps w/ STEP=n).'
  task :rollback => :environment do
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1
    ActiveRecord::Migrator.rollback('db/migrate/', step)
    Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
  end

  # desc 'Pushes the schema to the next version (specify steps w/ STEP=n).'
  task :forward => :environment do
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1
    ActiveRecord::Migrator.forward('db/migrate/', step)
    Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
  end

  # desc 'Drops and recreates the database from db/schema.rb for the current environment and loads the seeds.'
  task :reset => [ 'db:drop', 'db:setup' ]

  # desc "Retrieves the charset for the current environment's database"
  task :charset => :environment do
    config = ActiveRecord::Base.configurations['default' || 'development']
    case config['adapter']
    when /mysql/
      ActiveRecord::Base.establish_connection(config)
      puts ActiveRecord::Base.connection.charset
    when 'postgresql'
      ActiveRecord::Base.establish_connection(config)
      puts ActiveRecord::Base.connection.encoding
    when 'sqlite3'
      ActiveRecord::Base.establish_connection(config)
      puts ActiveRecord::Base.connection.encoding
    else
      $stderr.puts 'sorry, your database adapter is not supported yet, feel free to submit a patch'
    end
  end

  # desc "Retrieves the collation for the current environment's database"
  task :collation => :environment do
    config = ActiveRecord::Base.configurations['default']
    case config['adapter']
    when /mysql/
      ActiveRecord::Base.establish_connection(config)
      puts ActiveRecord::Base.connection.collation
    else
      $stderr.puts 'sorry, your database adapter is not supported yet, feel free to submit a patch'
    end
  end

  desc "Retrieves the current schema version number"
  task :version => :environment do
    puts "Current version: #{ActiveRecord::Migrator.current_version}"
  end

  # desc "Raises an error if there are pending migrations"
  task :abort_if_pending_migrations => :environment do
    if defined? ActiveRecord
      pending_migrations = ActiveRecord::Migrator.new(:up, 'db/migrate').pending_migrations

      if pending_migrations.any?
        puts "You have #{pending_migrations.size} pending migrations:"
        pending_migrations.each do |pending_migration|
          puts '  %4d %s' % [pending_migration.version, pending_migration.name]
        end
        abort %{Run "rake db:migrate" to update your database then try again.}
      end
    end
  end

  desc 'Create the database, load the schema, and initialize with the seed data (use db:reset to also drop the db first)'
  task :setup => [ 'db:create', 'db:schema:load', 'db:seed' ]

  desc 'Load the seed data from db/seeds.rb'
  task :seed => 'db:abort_if_pending_migrations' do
    seed_file = File.join('db', 'seeds.rb')
    load(seed_file) if File.exist?(seed_file)
  end

  namespace :fixtures do
    desc "Load fixtures into the current environment's database.  Load specific fixtures using FIXTURES=x,y. Load from subdirectory in test/fixtures using FIXTURES_DIR=z. Specify an alternative path (eg. spec/fixtures) using FIXTURES_PATH=spec/fixtures."
    task :load => :environment do
      require 'active_record/fixtures'

      ActiveRecord::Base.establish_connection('default')
      base_dir = ENV['FIXTURES_PATH'] ? File.join(ENV['FIXTURES_PATH']) : File.join('test', 'fixtures')
      fixtures_dir = ENV['FIXTURES_DIR'] ? File.join(base_dir, ENV['FIXTURES_DIR']) : base_dir

      (ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/).map {|f| File.join(fixtures_dir, f) } : Dir["#{fixtures_dir}/**/*.{yml,csv}"]).each do |fixture_file|
        ActiveRecord::Fixtures.create_fixtures(fixtures_dir, fixture_file[(fixtures_dir.size + 1)..-5])
      end
    end

    # desc "Search for a fixture given a LABEL or ID. Specify an alternative path (eg. spec/fixtures) using FIXTURES_PATH=spec/fixtures."
    task :identify => :environment do
      require 'active_record/fixtures'

      label, id = ENV["LABEL"], ENV["ID"]
      raise "LABEL or ID required" if label.blank? && id.blank?

      puts %Q(The fixture ID for "#{label}" is #{Fixtures.identify(label)}.) if label

      base_dir = ENV['FIXTURES_PATH'] ? File.join(ENV['FIXTURES_PATH']) : File.join('test', 'fixtures')
      Dir["#{base_dir}/**/*.yml"].each do |file|
        if data = YAML::load(ERB.new(IO.read(file)).result)
          data.keys.each do |key|
            key_id = Fixtures.identify(key)

            if key == label || key_id == id.to_i
              puts "#{file}: #{key} (#{key_id})"
            end
          end
        end
      end
    end
  end

  namespace :schema do
    desc "Create a db/schema.rb file that can be portably used against any DB supported by AR"
    task :dump => :environment do
      require 'active_record/schema_dumper'
      File.open(ENV['SCHEMA'] || "db/schema.rb", "w") do |file|
        ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
      end
      Rake::Task["db:schema:dump"].reenable
    end

    desc "Load a schema.rb file into the database"
    task :load => :environment do
      file = ENV['SCHEMA'] || "db/schema.rb"
      if File.exists?(file)
        load(file)
      else
        abort %{#{file} doesn't exist yet. Run "rake db:migrate" to create it then try again. If you do not intend to use a database, you should instead alter config/application.rb to limit the frameworks that will be loaded}
      end
    end
  end

  namespace :structure do
    desc "Dump the database structure to an SQL file"
    task :dump => :environment do
      abcs = ActiveRecord::Base.configurations
      case abcs['default']["adapter"]
      when /mysql/, "oci", "oracle"
        ActiveRecord::Base.establish_connection(abcs['default'])
        File.open("db/#{'default'}_structure.sql", "w+") { |f| f << ActiveRecord::Base.connection.structure_dump }
      when "postgresql"
        ENV['PGHOST']     = abcs['default']["host"] if abcs['default']["host"]
        ENV['PGPORT']     = abcs['default']["port"].to_s if abcs['default']["port"]
        ENV['PGPASSWORD'] = abcs['default']["password"].to_s if abcs['default']["password"]
        search_path = abcs['default']["schema_search_path"]
        unless search_path.blank?
          search_path = search_path.split(",").map{|search_path| "--schema=#{search_path.strip}" }.join(" ")
        end
        `pg_dump -i -U "#{abcs['default']["username"]}" -s -x -O -f db/default_structure.sql #{search_path} #{abcs['default']["database"]}`
        raise "Error dumping database" if $?.exitstatus == 1
      when "sqlite", "sqlite3"
        dbfile = abcs['default']["database"] || abcs['default']["dbfile"]
        `#{abcs['default']["adapter"]} #{dbfile} .schema > db/#{'default'}_structure.sql`
      when "sqlserver"
        `scptxfr /s #{abcs['default']["host"]} /d #{abcs['default']["database"]} /I /f db\\#{'default'}_structure.sql /q /A /r`
        `scptxfr /s #{abcs['default']["host"]} /d #{abcs['default']["database"]} /I /F db\ /q /A /r`
      when "firebird"
        set_firebird_env(abcs['default'])
        db_string = firebird_db_string(abcs['default'])
        sh "isql -a #{db_string} > db/#{'default'}_structure.sql"
      else
        raise "Task not supported by '#{abcs['default']["adapter"]}'"
      end

      if ActiveRecord::Base.connection.supports_migrations?
        File.open("db/#{'default'}_structure.sql", "a") { |f| f << ActiveRecord::Base.connection.dump_schema_information }
      end
    end
  end

  namespace :test do
    # desc "Recreate the test database from the current schema.rb"
    task :load => 'db:test:purge' do
      ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['test'])
      ActiveRecord::Schema.verbose = false
      Rake::Task["db:schema:load"].invoke
    end

    # desc "Recreate the test database from the current environment's database schema"
    task :clone => %w(db:schema:dump db:test:load)

    # desc "Recreate the test databases from the development structure"
    task :clone_structure => [ "db:structure:dump", "db:test:purge" ] do
      abcs = ActiveRecord::Base.configurations
      case abcs["test"]["adapter"]
      when /mysql/
        ActiveRecord::Base.establish_connection(:test)
        ActiveRecord::Base.connection.execute('SET foreign_key_checks = 0')
        IO.readlines("db/#{'default'}_structure.sql").join.split("\n\n").each do |table|
          ActiveRecord::Base.connection.execute(table)
        end
      when "postgresql"
        ENV['PGHOST']     = abcs["test"]["host"] if abcs["test"]["host"]
        ENV['PGPORT']     = abcs["test"]["port"].to_s if abcs["test"]["port"]
        ENV['PGPASSWORD'] = abcs["test"]["password"].to_s if abcs["test"]["password"]
        `psql -U "#{abcs["test"]["username"]}" -f db/#{'default'}_structure.sql #{abcs["test"]["database"]}`
      when "sqlite", "sqlite3"
        dbfile = abcs["test"]["database"] || abcs["test"]["dbfile"]
        `#{abcs["test"]["adapter"]} #{dbfile} < db/#{'default'}_structure.sql`
      when "sqlserver"
        `osql -E -S #{abcs["test"]["host"]} -d #{abcs["test"]["database"]} -i db\\#{'default'}_structure.sql`
      when "oci", "oracle"
        ActiveRecord::Base.establish_connection(:test)
        IO.readlines("db/#{'default'}_structure.sql").join.split(";\n\n").each do |ddl|
          ActiveRecord::Base.connection.execute(ddl)
        end
      when "firebird"
        set_firebird_env(abcs["test"])
        db_string = firebird_db_string(abcs["test"])
        sh "isql -i db/#{'default'}_structure.sql #{db_string}"
      else
        raise "Task not supported by '#{abcs["test"]["adapter"]}'"
      end
    end

    # desc "Empty the test database"
    task :purge => :environment do
      abcs = ActiveRecord::Base.configurations
      case abcs["test"]["adapter"]
      when /mysql/
        ActiveRecord::Base.establish_connection(:test)
        ActiveRecord::Base.connection.recreate_database(abcs["test"]["database"], abcs["test"])
      when "postgresql"
        ActiveRecord::Base.clear_active_connections!
        drop_database(abcs['test'])
        create_database(abcs['test'])
      when "sqlite","sqlite3"
        dbfile = abcs["test"]["database"] || abcs["test"]["dbfile"]
        File.delete(dbfile) if File.exist?(dbfile)
      when "sqlserver"
        dropfkscript = "#{abcs["test"]["host"]}.#{abcs["test"]["database"]}.DP1".gsub(/\\/,'-')
        `osql -E -S #{abcs["test"]["host"]} -d #{abcs["test"]["database"]} -i db\\#{dropfkscript}`
        `osql -E -S #{abcs["test"]["host"]} -d #{abcs["test"]["database"]} -i db\\#{'default'}_structure.sql`
      when "oci", "oracle"
        ActiveRecord::Base.establish_connection(:test)
        ActiveRecord::Base.connection.structure_drop.split(";\n\n").each do |ddl|
          ActiveRecord::Base.connection.execute(ddl)
        end
      when "firebird"
        ActiveRecord::Base.establish_connection(:test)
        ActiveRecord::Base.connection.recreate_database!
      else
        raise "Task not supported by '#{abcs["test"]["adapter"]}'"
      end
    end

    # desc 'Check for pending migrations and load the test schema'
    task :prepare => 'db:abort_if_pending_migrations' do
      if defined?(ActiveRecord) && !ActiveRecord::Base.configurations.blank?
        Rake::Task[{ :sql  => "db:test:clone_structure", :ruby => "db:test:load" }[ActiveRecord::Base.schema_format]].invoke
      end
    end
  end

  namespace :sessions do
    # desc "Creates a sessions migration for use with ActiveRecord::SessionStore"
    task :create => :environment do
      raise "Task unavailable to this database (no migration support)" unless ActiveRecord::Base.connection.supports_migrations?
      require 'rails/generators'
      Rails::Generators.configure!
      require 'rails/generators/rails/session_migration/session_migration_generator'
      Rails::Generators::SessionMigrationGenerator.start [ ENV["MIGRATION"] || "add_sessions_table" ]
    end

    # desc "Clear the sessions table"
    task :clear => :environment do
      ActiveRecord::Base.connection.execute "DELETE FROM #{session_table_name}"
    end
  end
end

task 'test:prepare' => 'db:test:prepare'

def drop_database(config)
  case config['adapter']
  when /mysql/
    ActiveRecord::Base.establish_connection(config)
    ActiveRecord::Base.connection.drop_database config['database']
  when /^sqlite/
    require 'pathname'
    path = Pathname.new(config['database'])
    file = path.absolute? ? path.to_s : File.join( path)

    FileUtils.rm(file)
  when 'postgresql'
    ActiveRecord::Base.establish_connection(config.merge('database' => 'postgres', 'schema_search_path' => 'public'))
    ActiveRecord::Base.connection.drop_database config['database']
  end
end

def session_table_name
  ActiveRecord::SessionStore::Session.table_name
end

def set_firebird_env(config)
  ENV["ISC_USER"]     = config["username"].to_s if config["username"]
  ENV["ISC_PASSWORD"] = config["password"].to_s if config["password"]
end

def firebird_db_string(config)
  FireRuby::Database.db_string_for(config.symbolize_keys)
end
