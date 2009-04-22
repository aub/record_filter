%w(class_join conjunction conjunction_dsl dsl group_by join join_dsl join_condition limit order restriction).each { |file| require File.join(File.dirname(__FILE__), 'dsl', file) }

module RecordFilter
  module DSL
  end
end
