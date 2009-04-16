module RecordFilter
  class Order
    attr_reader :column, :direction, :table

    def initialize(column, direction, table)
      @column, @direction, @table = column, direction, table
    end

    def to_sql
      dir = case @direction
        when :asc then 'ASC'
        when :desc then 'DESC'
      end
      
      table, column = @table, @column
      while column.is_a?(Hash)
        table = table.join_association(column.keys[0]).right_table
        column = column.values[0]
      end

      "#{table.table_name}.#{column} #{dir}"
    end
  end
end
