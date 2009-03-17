module RecordFilter
  module DSL
    class Conjunction
      def initialize(conjunction)
        @conjunction = conjunction
      end

      def with(column_name, value = nil)
        unless value
          DSL::Restriction.new(column_name.to_sym, @conjunction)
        else
          @conjunction.add(column_name, Restrictions::EqualTo, value)
        end
      end

      def any_of(&block)
        conjunction = Conjunctions::AnyOf.new(@conjunction.table_name)
        DSL::Conjunction.new(conjunction).instance_eval(&block)
        @conjunction << conjunction
      end

      def all_of(&block)
        conjunction = Conjunctions::AllOf.new(@conjunction.table_name)
        DSL::Conjunction.new(conjunction).instance_eval(&block)
        @conjunction << conjunction
      end
    end
  end
end
