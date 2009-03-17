module RecordFilter
  module DSL
    class Conjunction
      def initialize(conjunction)
        @conjunction = conjunction
      end

      def model_class
        @conjunction.model_class
      end

      def with(column_name, value = nil)
        unless value
          DSL::Restriction.new(column_name.to_sym, @conjunction)
        else
          @conjunction.add(column_name, Restrictions::EqualTo, value)
        end
      end
    end
  end
end
