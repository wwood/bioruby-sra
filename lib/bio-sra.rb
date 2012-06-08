# Please require your code below, respecting the naming conventions in the
# bioruby directory tree.
#
# For example, say you have a plugin named bio-plugin, the only uncommented
# line in this file would be 
#
#   require 'bio/bio-plugin/plugin'
#
# In this file only require other files. Avoid other source code.
require 'active_record'

require 'bio-logger'
Bio::Log::LoggerPlus.new('bio-sra')

require 'bio/sra/connect'
require 'bio/sra/sra'
require 'bio/sra/tables'


