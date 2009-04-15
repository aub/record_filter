module RecordFilter
  module DSL
    class Restriction

      attr_reader :column, :negated, :operator, :value

      def initialize(column, negated)
        @column, @negated, @operator = column, negated, nil
      end

      [:equal_to, :is_null, :less_than, :greater_than, :in, :between].each do |operator|
        define_method(operator) do |*args|
          @value = args[0] 
          @operator = operator
          self
        end
      end
    end
  end
end
