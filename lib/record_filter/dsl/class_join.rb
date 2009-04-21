module RecordFilter
  module DSL
    class ClassJoin
      attr_reader :join_class, :join_type, :table_alias, :conjunction

      def initialize(join_class, join_type, table_alias, conjunction, predicates)
        @join_class, @join_type, @table_alias, @conjunction, @predicates = 
          join_class, join_type, table_alias, conjunction, predicates
      end

      def predicates
        result = {}
        @predicates.each { |p| result.merge!(p.predicate) }
        result
      end
    end
  end
end
