module RecordFilter
  module DSL
    class ClassJoin
      attr_reader :class_name, :table_alias, :columns, :conjunction

      def initialize(class_name, table_alias, columns, conjunction)
        @class_name, @table_alias, @columns, @conjunction = class_name, table_alias, columns, conjunction
      end
    end
  end
end
