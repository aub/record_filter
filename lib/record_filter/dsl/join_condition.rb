module RecordFilter
  module DSL
    class JoinCondition # :nodoc: all

      attr_reader :restriction

      def initialize(column, value)
        @column = column
        if column.is_a?(Hash) && value == Restriction::DEFAULT_VALUE
          @condition = column
        else
          @restriction = Restriction.new(column, value)
        end
      end

      def condition
        @condition || restriction
      end
    end
  end
end
