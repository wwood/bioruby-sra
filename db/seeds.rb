#require 'bio-sra'
# # NOTE: You must define your model somewhere in your library
# #       and you must keep in mind that if you decide to have
# #       MultilabelNamespace you must create the right directory
# #       structure for it:
# #       Suppose Bio::Project::Mymodel < ActiveRecord::Base or a dummy class with the connection.
# #       Checkout the documentation.
# #       bioruby-gem/lib/bio/project/mymodel.rb
# #Use this file to load a default dataset into your database
# %w(Raoul Toshiaki Francesco).each do |coder|
#  YourNameSpace Example.create(:name=>coder, :tag=>"bioruby", :type=>"developer")
# end