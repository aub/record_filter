module RecordFilter
  module DSL
    class ConjunctionDSL

      attr_reader :conjunction

      def initialize(conjunction=Conjunction.new(:all_of))
        @conjunction = conjunction
      end

      # restriction
      def with(column, value=Conjunction::DEFAULT_VALUE)
        return @conjunction.add_restriction(column, value, false) # using return just to make it explicit
      end

      # restriction
      def without(column, value=Conjunction::DEFAULT_VALUE)
        return @conjunction.add_restriction(column, value, true) # using return just to make it explicit
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
      def having(association, &block)
        @conjunction.add_join(association, &block)
      end

      def left_join(class_name, table_alias, columns, &block)
        @conjunction.add_class_join(class_name, table_alias, columns, &block)
      end
    end
  end
end
