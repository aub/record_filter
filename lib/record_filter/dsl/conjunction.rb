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
        dsl = DSL.new(Conjunction.new(type))
        dsl.instance_eval(&block) if block
        @steps << dsl.conjunction
      end

      def add_join(column, &block)
        dsl = DSL.new
        dsl.instance_eval(&block) if block
        @steps << (join = Join.new(column, dsl.conjunction))
        join
      end
    end
  end
end
