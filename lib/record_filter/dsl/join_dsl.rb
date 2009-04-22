module RecordFilter
  module DSL
    class JoinDSL < ConjunctionDSL

      attr_reader :conditions

      def on(column, value=Restriction::DEFAULT_VALUE)
        @conditions ||= []
        @conditions << (condition = JoinCondition.new(column, value))
        return condition.restriction
      end
    end
  end
end
