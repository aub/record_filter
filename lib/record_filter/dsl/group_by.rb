module RecordFilter
  module DSL
    class GroupBy # :nodoc: all
      attr_reader :column

      def initialize(column)
        @column = column
      end
    end
  end
end
