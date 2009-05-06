module RecordFilter
  module DSL
    # The Restriction class is used to specify conditions in your filters. It is accessed through
    # the use of ConjunctionDSL.with, which can be chained with further methods below
    # in order to create many types of conditions. 
    #
    #   Blog.filter do
    #     with(:id, 2)          # :conditions => { ['id = ?', 2] }
    #     with(:id).is_null     # :conditions => { ['id IS NULL'] }
    #     with(:id).in([2,3,4]) # :conditions => { ['id IN (?)', [2,3,4]] }
    #     ...
    #   end
    #
    # The following restriction types are supported:
    # * Between
    # * Equality
    # * Comparisons (>, >=, <, <=)
    # * In
    # * Is Null and Is Not Null
    # * Like
    # * Negation of any restriction through not
    #
    class Restriction

      attr_reader :column, :negated, :operator, :value # :nodoc:

      DEFAULT_VALUE = Object.new

      # Create a restriction, given a column to restrict and an optional value.
      #
      # ==== Parameters
      # column<Symbol>:: 
      #   The name of the column to be restricted.
      # value<String, Symbol, number, Time, nil, etc.>:: 
      #   The value of the column to use for equality restriction.
      #
      # ==== Returns
      # Restriction:: self
      #
      # ==== Alternatives
      # If a second argument is passed, an equality restriction of the form ['column = ?', value]
      # will be created. If the second argument is nil, an is_null restriction of the form
      # ['column IS NULL'] will be created. If no value is provided, the type of the restriction
      # will be unset and one of the restriction type methods should be called on the object in
      # order to fully specify its type and value.
      #
      # @public
      def initialize(column, value=DEFAULT_VALUE) # :nodoc:
        @column, @negated, @operator = column, false, nil
        take_value(value)
      end

      # Negate the restriction, taking an optional value for inequality restrictions.
      #
      # ==== Parameters
      # value<String, number, Time, nil, etc>::
      #   A value to be used when specifying inequality restrictions.
      #
      # ==== Returns
      # Restriction:: self
      #
      # ==== Alternatives
      # The value option works in the same way as in the initializer, as a shortcut for inequality
      # or is_null restrictions if it is provided. This allows restrictions to be specified like:
      # with(:permalink).not(nil)
      # If no value is specified, it will simply negate the restriction.
      #
      # @public
      def not(value=DEFAULT_VALUE)
        @negated = !@negated
        take_value(value)
        self
      end

      # Make the restriction into an equality test of the form ['column = ?', value]
      #
      # ==== Parameters
      # value<String, Symbol, number, nil, etc>::
      #   The value to use in the restriction.
      #
      # ==== Returns
      # Restriction:: self
      #
      # ==== Alternatives
      # If nil is passed as the value, this will create an is_null restriction.
      #
      # @public
      def equal_to(value)
        @value, @operator = value, :equal_to
        @value, @operator = nil, :is_null if value.nil?
        self
      end

      # Change the restriction into a test for null in the form ['column IS NULL']
      #
      # ==== Parameters
      # none
      #
      # ==== Returns
      # Restriction:: self
      #
      # @public
      def is_null
        @value, @operator = nil, :is_null
        self
      end
      alias_method :null, :is_null
      alias_method :nil, :is_null

      # Change the restriction into a negated test for null of the form ['column IS NOT NULL']
      #
      # ==== Parameters
      # none
      #
      # ==== Returns
      # Restriction:: self
      #
      # @public
      def is_not_null
        @operator = :is_null
        @negated = true
        self
      end

      # Create a less_than condition of the form ['column < ?', value]
      #
      # ==== Parameters
      # value<String, number, time, etc.>::
      #   The value to be compared.
      #
      # ==== Returns
      # Restriction:: self
      #
      # @public
      def less_than(value)
        @value, @operator = value, :less_than
        self
      end
      alias_method :lt, :less_than

      # Create a comparison restriction of the form ['column <= ?', value]
      #
      # ==== Parameters
      # value::
      #   The value to be used in the comparison.
      #
      # ==== Returns
      # Restriction:: self
      #
      # @public
      def less_than_or_equal_to(value)
        @value, @operator = value, :less_than_or_equal_to
        self
      end
      alias_method :lte, :less_than_or_equal_to

      # Create a comparison restriction of the form ['column > ?', value]
      #
      # ==== Parameters
      # value::
      #   The value to be used for comparison.
      #
      # ==== Returns
      # Restriction:: self
      #
      # @public
      def greater_than(value)
        @value, @operator = value, :greater_than
        self
      end
      alias_method :gt, :greater_than

      # Create a comparison restriction of the form ['column >= ?', value]
      #
      # ==== Parameters
      # value::
      #   The value to be used in the comparison.
      #
      # ==== Returns
      # Restriction:: self
      #
      # @public
      def greater_than_or_equal_to(value)
        @value, @operator = value, :greater_than_or_equal_to
        self
      end
      alias_method :gte, :greater_than_or_equal_to

      # Create an IN restriction of the form ['column IN (?)', value]
      #
      # ==== Parameters
      # value::
      #   Either a single item or an array of values to form the values to be tested for inclusion.
      #
      # ==== Returns
      # Restriction:: self
      #
      # @public
      def in(value)
        @value, @operator = value, :in
        self
      end

      # Create a negated IN restriction of the form ['column NOT IN (?)', value]
      #
      # ==== Parameters
      # value::
      #   Either a single item or an array of values to form the inclusion test.
      #
      # ==== Returns
      # Restriction:: self
      #
      # @public
      def not_in(value)
        @value, @operator, @negated = value, :in, true
        self
      end

      # Create a LIKE restriction of the form ['column LIKE ?', value]
      #
      # ==== Parameters
      # value::
      #   The value to be tested against the column.
      #
      # ==== Returns
      # Restriction:: self
      #
      # @public
      def like(value)
        @value, @operator = value, :like
        self
      end

      # Create a between filter of the form ['column BETWEEN ? AND ?', start, finish]
      #
      # ==== Parameters
      # start::
      #   The starting limit for the between test.
      # finish::
      #   The ending limit for the between test.
      #
      # ==== Returns
      # Restriction:: self
      #
      # ==== Alternatives
      # With the second argument omitted, the method can also accept either a tuple (Array) or a
      # range as the first argument. If a tuple is given, it will be used as [start, finish]. If
      # a range is given, its beginning and ending values will be used.
      #
      # @public
      def between(start, finish=nil)
        @operator = :between
        if !finish.nil?
          @value = [start, finish]
        else
          @value = start
        end
        self
      end

      protected

      def take_value(value) # :nodoc:
        if value.nil?
          is_null
        elsif value != DEFAULT_VALUE
          equal_to(value)
        end
      end
    end
  end
end
