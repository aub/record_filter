module RecordFilter
  module DSL
    class TableJoin
      attr_reader :table_name, :table_alias, :columns, :conjunction

      def initialize(table_name, table_alias, columns, conjunction)
        @table_name, @table_alias, @columns, @conjunction = table_name, table_alias, columns, conjunction
      end
    end
  end
end
