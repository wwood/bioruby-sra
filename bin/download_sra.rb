#!/usr/bin/env ruby

require 'optparse'
require 'bio-logger'
require 'csv'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'bio-sra'

SCRIPT_NAME = File.basename(__FILE__); LOG_NAME = SCRIPT_NAME.gsub('.rb','')

# Parse command line options into the options hash
options = {
  :logger => 'stderr',
  :format => :sralite,
  :accessions_file => nil,
  :download_all_from_study => false,
}
o = OptionParser.new do |opts|
  opts.banner = "
    Usage: #{SCRIPT_NAME} <SRA_ACCESSION>
    
    Download data from SRA \n"
    
  opts.on('-f', "--file FILENAME", "Provide a file of accession numbers, separated by whitespace or commas [default: not used, use the first argument <SRA_ACCESSION>]") do |f|
    options[:accessions_file] = f
  end
  opts.on("--format FORMAT", "format for download [default: 'sralite']") do |f|
    format_string_to_sym = [
      'sralite' => :sralite,
      'sra' => :sra
    ]
    options[:format] = format_string_to_sym[f]
    
    if options[:format].nil?
      raise "Unexpected file format specified '#{f}'. I require one of #{format_string_to_sym.keys.join(', ')}"
    end
  end
  opts.on('-s', "--study", "Download all data from the study, not just the runs/experiment accessions provided [default: false]") do
    options[:download_all_from_study] = true
  end
  
  # logger options
  opts.on("-q", "--quiet", "Run quietly, set logging to ERROR level [default INFO]") do |q|
    Bio::Log::CLI.trace('error')
  end
  opts.on("--logger filename",String,"Log to file [default #{options[:logger]}]") do | name |
    options[:logger] = name
  end
  opts.on("--trace options",String,"Set log level [default INFO]. e.g. '--trace debug' to set logging level to DEBUG") do | s |
    Bio::Log::CLI.trace(s)
  end
end
o.parse!

if options[:accessions_file].nil? and ARGV.length == 0
  $stderr.puts o
  exit 1
end

# Setup logging
Bio::Log::CLI.logger(options[:logger]) #bio-logger defaults to STDERR not STDOUT, I disagree
log = Bio::Log::LoggerPlus.new(LOG_NAME)
Bio::Log::CLI.configure(LOG_NAME)

accessions = nil
if options[:accessions_file]
  log.debug "Reading SRA accessions from file #{options[:accessions_file]}"
  accessions = File.open(options[:accessions_file]).read.split(/[\s,]+/).reject{|a| a==''}
else
  accessions = ARGV.collect{|r| r.split(/[\s,]+/)}.flatten.reject{|a| a==''}
end

# Connect to the database
Bio::SRA::Connection.connect



accessions.each do |acc|
  runs = []
  if options[:download_all_from_study]
    study_accessions = runs.collect{|r| r.study_accession}.uniq
    unless study_accessions.length == 1
      log.warn "Unexpectedly found #{study_accessions.length} different studies associated with accession number #{acc}, skipping"
      next
    end
    study_acc = study_accessions[0]
    # Can't see why this would happen unless the ruby code is out of date or the 
    unless Bio::SRA::Accession.classify_accession_type(study_acc) == Bio::SRA::Study
      log.warn "Unexpected form of study accession found, for study accession #{study_acc} found from the given accession #{acc}, skipping"
      next
    end
    runs = Bio::SRA::Tables::SRA.find_all_by_study_accession(study_acc)
  else
    runs = Bio::SRA::Tables::SRA.find_all_by_accession(acc)
  end
  # Convert Run ActiveRecords into simple accessions
  runs = runs.collect do |r|
    r.run_accession
  end
  
  if runs.empty?
    log.warn "Unable to find accession number #{acc} in the metadata database, skipping"
    next
  end
  
  log.info "Found #{runs.length} runs to download for accession number #{acc}"
  runs.each_with_index do |run, index|
    download_path = "#{run}.lite.sra" 
    if File.exist?(download_path)
      log.debug "Skipping download of run #{download_path} since a file of that accession already exists"
      next
    end
    log.info "Downloading run #{index+1}/#{runs.length} for accession number #{acc}.."
    
    url = Bio::SRA::Accession.run_download_url(run)
    `wget '#{url}'`
  end
end
