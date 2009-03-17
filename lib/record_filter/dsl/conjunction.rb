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
          @conjunction.add_restriction(column_name, Restrictions::EqualTo, value)
        end
      end

      def any_of(&block)
        DSL::Conjunction.new(@conjunction.add_conjunction(Conjunctions::AnyOf)).instance_eval(&block)
      end

      def all_of(&block)
        DSL::Conjunction.new(@conjunction.add_conjunction(Conjunctions::AllOf)).instance_eval(&block)
      end

      def having(association_name, &block)
        join = @conjunction.add_join_on_association(association_name)
        conjunction = DSL::Conjunction.new(@conjunction.add_conjunction(Conjunctions::AllOf, join.right_table))
        conjunction.instance_eval(&block) if block
        conjunction
      end
    end
  end
end
