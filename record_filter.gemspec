# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{record_filter}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mat Brown", "Aubrey Holland"]
  s.date = %q{2009-04-16}
  s.description = %q{Pure-ruby criteria API for building complex queries in ActiveRecord}
  s.email = %q{mat@patch.com}
  s.files = [
    "Rakefile",
    "VERSION.yml",
    "lib/record_filter.rb",
    "lib/record_filter/active_record.rb",
    "lib/record_filter/conjunctions.rb",
    "lib/record_filter/dsl.rb",
    "lib/record_filter/dsl/conjunction.rb",
    "lib/record_filter/dsl/conjunction_dsl.rb",
    "lib/record_filter/dsl/dsl.rb",
    "lib/record_filter/dsl/join.rb",
    "lib/record_filter/dsl/limit.rb",
    "lib/record_filter/dsl/order.rb",
    "lib/record_filter/dsl/restriction.rb",
    "lib/record_filter/filter.rb",
    "lib/record_filter/join.rb",
    "lib/record_filter/join_table.rb",
    "lib/record_filter/order.rb",
    "lib/record_filter/query.rb",
    "lib/record_filter/restrictions.rb",
    "lib/record_filter/table.rb",
    "spec/implicit_join_spec.rb",
    "spec/limits_and_ordering_spec.rb",
    "spec/models/blog.rb",
    "spec/models/comment.rb",
    "spec/models/photo.rb",
    "spec/models/post.rb",
    "spec/models/tag.rb",
    "spec/named_filter_spec.rb",
    "spec/restrictions_spec.rb",
    "spec/spec_helper.rb",
    "spec/test.db"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/outoftime/record_filter/tree/master}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.2}
  s.summary = %q{Pure-ruby criteria API for building complex queries in ActiveRecord}
  s.test_files = [
    "spec/implicit_join_spec.rb",
    "spec/limits_and_ordering_spec.rb",
    "spec/models/blog.rb",
    "spec/models/comment.rb",
    "spec/models/photo.rb",
    "spec/models/post.rb",
    "spec/models/tag.rb",
    "spec/named_filter_spec.rb",
    "spec/restrictions_spec.rb",
    "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
