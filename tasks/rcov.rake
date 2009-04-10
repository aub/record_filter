require 'spec/rake/spectask'

desc 'run specs with rcov'
Spec::Rake::SpecTask.new('rcov') do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.rcov = true
  t.rcov_dir = File.join('coverage', 'all')
  t.rcov_opts.concat(['--exclude', 'spec', '--sort', 'coverage', '--only-uncovered'])
end
