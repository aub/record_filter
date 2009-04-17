%w(conjunction conjunction_dsl dsl group_by join limit order restriction).each { |file| require File.join(File.dirname(__FILE__), 'dsl', file) }

module RecordFilter
  module DSL
  end
end
