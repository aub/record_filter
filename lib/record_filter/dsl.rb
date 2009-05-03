%w(class_join conjunction conjunction_dsl dsl dsl_factory group_by join join_dsl join_condition limit named_filter order restriction).each { |file| require File.join(File.dirname(__FILE__), 'dsl', file) }

module RecordFilter
  module DSL
  end
end
