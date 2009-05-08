require 'rubygems'
gem 'activerecord', '~> 2.2'
require 'active_record'

%w(active_record column_parser query table conjunctions restrictions restriction_factory filter join order group_by dsl).each do |file|
  require File.join(File.dirname(__FILE__), 'record_filter', file)
end

# The base-level namespace for the record_filter code. See RecordFilter::ActiveRecordExtension::ClassMethods
# for a description of the public API.
module RecordFilter

  # An exception that is raised when an implicit join is attempted on an association 
  # that does not exist.
  class AssociationNotFoundException < StandardError; end
  
  # An exception that is raised when attempting to place restrictions or specify an
  # explicit join on a column that doesn't exist.
  class ColumnNotFoundException < StandardError; end

  # An exception that is raised when operations such as limit, order, group_by, or
  # on are called out of context.
  class InvalidFilterException < StandardError; end

  # An exception that is raised when attempting to create a named filter with a name that
  # already exists in the class it is created on or one of its superclasses.
  class InvalidFilterNameException < StandardError; end

  # An exception that is raised when no columns are privided to specify an explicit join. 
  class InvalidJoinException < StandardError; end

  # An exception raised in the case where a named filter is called from within a filter
  # and the named filter does not exist.
  class NamedFilterNotFoundException < StandardError; end
end

