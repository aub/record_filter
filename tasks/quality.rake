begin
  require 'reek/rake_task'
  Reek::RakeTask.new do |t|
    t.fail_on_error = false
  end
rescue LoadError
  puts 'So sorry, you don\'t have reek. Is that a good thing or a bad thing?'
end

begin
  require 'flog'

  desc 'Analyze for code complexity'
  task :flog do
    flog = Flog.new
    flog.flog_files(['lib'])
    threshold = 30

    bad_methods = flog.totals.select do |name, score|
      score > threshold
    end
    bad_methods.sort { |a,b| a[1] <=> b[1] }.each do |name, score|
      puts "%8.1f: %s" % [score, name]
    end

    raise "#{bad_methods.size} methods have a flog complexity > #{threshold}" unless bad_methods.empty?
  end
rescue LoadError
  puts 'Will you go ahead and install flog?'
end

begin
  require 'flay'

  desc 'Analyze for code duplication'
  task :flay do
    threshold = 25
    flay = Flay.new({:fuzzy => false, :verbose => false, :mass => threshold})
    flay.process(*Flay.expand_dirs_to_files(['lib']))
    flay.report

    raise "#{flay.masses.size} chunks of code have a duplicate mass > #{threshold}" unless flay.masses.empty?
  end
rescue LoadError
  puts 'Will you go ahead and install flay?'
end

begin
  require 'roodi'
  require 'roodi_task'
  RoodiTask.new 'roodi', ['lib/**/*.rb'], 'config/roodi.yml'
rescue LoadError
  puts 'Will you go ahead and install roodi already?'
end
