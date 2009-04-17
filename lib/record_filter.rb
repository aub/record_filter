require 'rubygems'
gem 'activerecord', '~> 2.2'
require 'active_record'

%w(active_record query table conjunctions restrictions filter join order dsl).each do |file|
  require File.join(File.dirname(__FILE__), 'record_filter', file)
end

module RecordFilter
  class AssociationNotFoundException < Exception; end
  class ColumnNotFoundException < Exception; end
end
