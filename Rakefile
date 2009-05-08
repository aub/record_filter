require 'rubygems'
require 'rake'
require 'rake/testtask'

FileList['tasks/**/*.rake'].each { |file| load file }

task :default => ["db:spec:prepare", :spec]

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = 'record_filter'
    gemspec.summary = 'An ActiveRecord query API for replacing SQL with awesome'
    gemspec.email = 'aubreyholland@gmail.com'
    gemspec.homepage = 'http://github.com/aub/record_filter/tree/master'
    gemspec.description = 'RecordFilter is a Pure-ruby criteria API for building complex queries in ActiveRecord. It supports queries that are built on the fly as well as named filters that can be added to objects and chained to create complex queries. It also gets rid of the nasty hard-coded SQL that shows up in most ActiveRecord code with a clean API that makes queries simple and intuitive to build.'
    gemspec.authors = ['Aubrey Holland', 'Mat Brown']
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
  rdoc.options << '--webcvs=http://github.com/aub/record_filter/tree/master/'
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

begin
  require 'metric_fu'
  MetricFu::Configuration.run do |config|
    #define which metrics you want to use
    config.metrics  = [:churn, :flog, :flay, :reek, :roodi, :rcov] # :saikuro, :stats
    config.flay     = { :dirs_to_flay => ['lib']  } 
    config.flog     = { :dirs_to_flog => ['lib']  }
    config.reek     = { :dirs_to_reek => ['lib']  }
    config.roodi    = { :dirs_to_roodi => ['lib'] }
    config.saikuro  = { :output_directory => 'scratch_directory/saikuro', 
                        :input_directory => ['lib'],
                        :cyclo => "",
                        :filter_cyclo => "0",
                        :warn_cyclo => "5",
                        :error_cyclo => "7",
                        :formater => "text"} #this needs to be set to "text"
    config.churn    = { :start_date => "1 year ago", :minimum_churn_count => 10}
    config.rcov     = { :test_files => ['spec/**/*_spec.rb'],
                        :rcov_opts => ["--sort coverage", 
                                       "--no-html", 
                                       "--text-coverage",
                                       "--no-color",
                                       "--profile",
                                       "--exclude spec"]}
  end
rescue LoadError
  puts 'Install metric_fu for code quality metric tests.'
end

