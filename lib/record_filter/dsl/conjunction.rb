module RecordFilter
  module DSL
    class Conjunction

      attr_reader :type, :steps

      DEFAULT_VALUE = Object.new

      def initialize(type=:all_of)
        @type, @steps = type, []
      end

      def add_restriction(column, value, negated)
        @steps << (restriction = Restriction.new(column, negated))
        if value == DEFAULT_VALUE
          return restriction
        elsif value.nil?
          restriction.is_null
        else
          restriction.equal_to(value)
        end
        nil
      end

      def add_conjunction(type, &block)
        dsl = ConjunctionDSL.new(Conjunction.new(type))
        dsl.instance_eval(&block) if block
        @steps << dsl.conjunction
      end

      def add_join(association, &block)
        dsl = ConjunctionDSL.new
        dsl.instance_eval(&block) if block
        @steps << Join.new(association, dsl.conjunction)
        dsl
      end

      def add_class_join(class_name, table_alias, columns, &block)
        dsl = ConjunctionDSL.new
        dsl.instance_eval(&block) if block
        @steps << ClassJoin.new(class_name, table_alias, columns, dsl.conjunction)
        dsl
      end

      def add_limit(limit, offset)
        @steps << Limit.new(limit, offset)
      end

      def add_order(column, direction)
        @steps << Order.new(column, direction)
      end

      def add_group_by(column)
        @steps << GroupBy.new(column)
      end
    end
  end
end
