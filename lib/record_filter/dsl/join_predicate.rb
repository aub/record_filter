module RecordFilter
  module DSL
    class JoinPredicate

      attr_reader :restriction

      def initialize(column, value)
        @column = column
        if column.is_a?(Hash) && value == Restriction::DEFAULT_VALUE
          @predicate = column
        else
          @restriction = Restriction.new(column, value)
        end
      end

      def predicate
        @predicate || { @column => converted_restriction }
      end

      protected

      def converted_restriction
        restriction_class = RecordFilter::Restrictions::Base.class_from_operator(@restriction.operator)
        restriction = restriction_class.new(@column, @restriction.value, :negated => @restriction.negated)
      end
    end
  end
end
