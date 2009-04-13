module RecordFilter
  module DSL
    class Conjunction
      SUBCLASSES = Hash.new do |h, k|
        h[k] = Class.new(Conjunction)
      end

      DEFAULT_VALUE = Object.new

      class <<self
        # protected :new

        def create(clazz, conjunction)
          subclass(clazz).new(conjunction)
        end

        def subclass(clazz)
          SUBCLASSES[clazz.name.to_sym]
        end
      end

      def initialize(conjunction)
        @conjunction = conjunction
      end

      def with(column_name, value = DEFAULT_VALUE)
        with_or_without(column_name, value, false)
      end
      
      def without(column_name, value = DEFAULT_VALUE)
        with_or_without(column_name, value, true)
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

      protected

      def with_or_without(column_name, value, negated)
        if value == DEFAULT_VALUE
          DSL::Restriction.new(column_name.to_sym, @conjunction)
        elsif value.nil?
          @conjunction.add_restriction(column_name, Restrictions::IsNull, value, :negated => negated)
        else
          @conjunction.add_restriction(column_name, Restrictions::EqualTo, value, :negated => negated)
        end
      end
    end
  end
end
