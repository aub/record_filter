require 'rubygems'
gem 'activerecord', '~> 2.2'
require 'active_record'

%w(active_record query table conjunctions restrictions filter join order group_by dsl).each do |file|
  require File.join(File.dirname(__FILE__), 'record_filter', file)
end

module RecordFilter
  AssociationNotFoundException = Class.new(StandardError)
  ColumnNotFoundException = Class.new(StandardError)
  InvalidJoinException = Class.new(StandardError)
end
