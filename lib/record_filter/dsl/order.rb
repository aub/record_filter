module RecordFilter
  module DSL
    class Order

      attr_reader :column, :direction

      def initialize(column, direction)
        @column, @direction = column, direction
      end
    end
  end
end
