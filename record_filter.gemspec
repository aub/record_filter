# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{record_filter}
  s.version = "1.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Aubrey Holland", "Mat Brown"]
  s.date = %q{2010-08-06}
  s.description = %q{RecordFilter is a Pure-ruby criteria API for building complex queries in ActiveRecord. It supports queries that are built on the fly as well as named filters that can be added to objects and chained to create complex queries. It also gets rid of the nasty hard-coded SQL that shows up in most ActiveRecord code with a clean API that makes queries simple and intuitive to build.}
  s.email = %q{aubreyholland@gmail.com}
  s.extra_rdoc_files = [
    "README.rdoc",
     "TODO"
  ]
  s.files = [
    ".gitignore",
     "CHANGELOG",
     "README.rdoc",
     "Rakefile",
     "TODO",
     "VERSION.yml",
     "config/roodi.yml",
     "lib/record_filter.rb",
     "lib/record_filter/active_record.rb",
     "lib/record_filter/column_parser.rb",
     "lib/record_filter/conjunctions.rb",
     "lib/record_filter/dsl.rb",
     "lib/record_filter/dsl/class_join.rb",
     "lib/record_filter/dsl/conjunction.rb",
     "lib/record_filter/dsl/conjunction_dsl.rb",
     "lib/record_filter/dsl/dsl.rb",
     "lib/record_filter/dsl/dsl_factory.rb",
     "lib/record_filter/dsl/group_by.rb",
     "lib/record_filter/dsl/join.rb",
     "lib/record_filter/dsl/join_condition.rb",
     "lib/record_filter/dsl/join_dsl.rb",
     "lib/record_filter/dsl/limit.rb",
     "lib/record_filter/dsl/named_filter.rb",
     "lib/record_filter/dsl/offset.rb",
     "lib/record_filter/dsl/order.rb",
     "lib/record_filter/dsl/restriction.rb",
     "lib/record_filter/filter.rb",
     "lib/record_filter/group_by.rb",
     "lib/record_filter/join.rb",
     "lib/record_filter/order.rb",
     "lib/record_filter/query.rb",
     "lib/record_filter/restriction_factory.rb",
     "lib/record_filter/restrictions.rb",
     "lib/record_filter/table.rb",
     "record_filter.gemspec",
     "script/console",
     "spec/active_record_spec.rb",
     "spec/exception_spec.rb",
     "spec/explicit_join_spec.rb",
     "spec/explicit_subquery_spec.rb",
     "spec/implicit_join_spec.rb",
     "spec/limits_and_ordering_spec.rb",
     "spec/models.rb",
     "spec/named_filter_spec.rb",
     "spec/proxying_spec.rb",
     "spec/restrictions_spec.rb",
     "spec/select_spec.rb",
     "spec/spec_helper.rb",
     "spec/test.db",
     "tasks/db.rake",
     "tasks/rcov.rake",
     "tasks/spec.rake",
     "test/performance_test.rb",
     "test/test.db"
  ]
  s.homepage = %q{http://github.com/aub/record_filter}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{record-filter}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{An ActiveRecord query API for replacing SQL with awesome}
  s.test_files = [
    "spec/active_record_spec.rb",
     "spec/exception_spec.rb",
     "spec/explicit_join_spec.rb",
     "spec/explicit_subquery_spec.rb",
     "spec/implicit_join_spec.rb",
     "spec/limits_and_ordering_spec.rb",
     "spec/models.rb",
     "spec/named_filter_spec.rb",
     "spec/proxying_spec.rb",
     "spec/restrictions_spec.rb",
     "spec/select_spec.rb",
     "spec/spec_helper.rb",
     "test/performance_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activerecord>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
    else
      s.add_dependency(%q<activerecord>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<activerecord>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
  end
end

