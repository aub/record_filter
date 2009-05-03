module RecordFilter
  module DSL
    class ClassJoin # :nodoc: all
      attr_reader :join_class, :join_type, :table_alias, :conjunction

      def initialize(join_class, join_type, table_alias, conjunction, join_conditions)
        @join_class, @join_type, @table_alias, @conjunction, @join_conditions = 
          join_class, join_type, table_alias, conjunction, join_conditions
      end

      def conditions
        @join_conditions ? @join_conditions.map { |c| c.condition } : nil
      end
    end
  end
end
