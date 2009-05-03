module RecordFilter
  module DSL
    class ConjunctionDSL

      attr_reader :conjunction

      def initialize(model_class, conjunction)
        @model_class = model_class
        @conjunction = conjunction
      end

      # restriction
      def with(column, value=Restriction::DEFAULT_VALUE)
        return @conjunction.add_restriction(column, value)
      end

      # conjunction
      def any_of(&block)
        @conjunction.add_conjunction(:any_of, &block)
        nil
      end

      # conjunction
      def all_of(&block)
        @conjunction.add_conjunction(:all_of, &block)
        nil
      end

      def none_of(&block)
        @conjunction.add_conjunction(:none_of, &block)
        nil
      end

      def not_all_of(&block)
        @conjunction.add_conjunction(:not_all_of, &block)
        nil
      end

      # join
      def having(join_type_or_association, association=nil, &block)
        if association.nil?
          association, join_type = join_type_or_association, nil
        else
          join_type = join_type_or_association
        end
        @conjunction.add_join(association, join_type, &block)
      end

      def join(clazz, join_type, table_alias=nil, &block)
        @conjunction.add_class_join(clazz, join_type, table_alias, &block)
      end

      def filter_class
        @model_class
      end

      def limit(offset_or_limit, limit=nil) # :nodoc:
        raise InvalidFilterException.new('Calls to limit can only be made in the outer block of a filter.')
      end

      def order(column, direction=:asc) # :nodoc:
        raise InvalidFilterException.new('Calls to order can only be made in the outer block of a filter.')
      end

      def group_by(column) # :nodoc:
        raise InvalidFilterException.new('Calls to group_by can only be made in the outer block of a filter.')
      end

      def on(column, value=Restriction::DEFAULT_VALUE) # :nodoc:
        raise InvalidFilterException.new('Calls to on can only be made in the block of a call to join.')
      end

      def method_missing(method, *args)
        @conjunction.add_named_filter(method, *args)
      end
    end
  end
end
