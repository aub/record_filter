module RecordFilter
  module DSL
    class JoinDSL < ConjunctionDSL

      attr_reader :predicates

      def on(column, value=Restriction::DEFAULT_VALUE)
        @predicates ||= []
        @predicates << (predicate = JoinPredicate.new(column, value))
        return predicate.restriction
      end
    end
  end
end
