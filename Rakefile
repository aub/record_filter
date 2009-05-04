# ENV['RUBYOPT'] = '-W1'

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

# Try to use hanna to create spiffier docs.
begin
  require 'hanna/rdoctask'
rescue LoadError
  require 'rake/rdoctask'
end

Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION.yml')
    config = YAML.load(File.read('VERSION.yml'))
    version = "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "record_filter #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require 'ruby-prof/task'

  RubyProf::ProfileTask.new do |t|
    t.test_files = FileList['test/performance_test.rb']
    t.output_dir = 'perf'
    t.printer = :graph_html
    t.min_percent = 5
  end
rescue LoadError
  puts 'Ruby-prof not available. Profiling tests are disabled.'
end

