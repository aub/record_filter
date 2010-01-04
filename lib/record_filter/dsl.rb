%w(class_join conjunction conjunction_dsl dsl dsl_factory group_by join join_dsl join_condition limit named_filter offset order restriction).each { |file| require File.join(File.dirname(__FILE__), 'dsl', file) }

module RecordFilter
  # The DSL module defines the structure of the criteria API used in calls to
  # filter and named_filter. The API is defined by its four submodules, which
  # define context-specific hooks for the API as well as defining a list of
  # available restrictions. At the top level of a filter definition, all of the
  # methods in DSL and ConjunctionDSL are available. In inner blocks, the methods
  # in ConjunctionDSL are available, and within explicit joins defined using 'join'
  # the methods in JoinDSL are added. The API provides access to:
  #
  # * Restrictions, using ConjunctionDSL.with and the methods in Restriction.
  # * Conjunctions, such as all_of, any_of, etc. in ConjunctionDSL.
  # * Implicit joins on associations, using ConjunctionDSL.having
  # * Explicit joins, using ConjunctionDSL.join and JoinDSL.on
  # * Ordering, using DSL.order
  # * Grouping, using DSL.group_by
  # * Limits and offsets, using DSL.limit
  module DSL
  end
end
