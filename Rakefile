ENV['RUBYOPT'] = '-W1'

require 'rubygems'
require 'rake'
require 'rake/testtask'

FileList['tasks/**/*.rake'].each { |file| load file }

task :default => :spec

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = 'record_filter'
    gemspec.summary = 'Pure-ruby criteria API for building complex queries in ActiveRecord'
    gemspec.email = 'mat@patch.com'
    gemspec.homepage = 'http://github.com/outoftime/record_filter/tree/master'
    gemspec.description = 'Pure-ruby criteria API for building complex queries in ActiveRecord'
    gemspec.authors = ['Mat Brown', 'Aubrey Holland']
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

