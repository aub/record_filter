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
    gemspec.email = 'aubreyholland@gmail.com'
    gemspec.homepage = 'http://github.com/aub/record_filter/tree/master'
    gemspec.description = 'Pure-ruby criteria API for building complex queries in ActiveRecord'
    gemspec.authors = ['Aubrey Holland', 'Mat Brown']
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

require 'rake/rdoctask'
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

