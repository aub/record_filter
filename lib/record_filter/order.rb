module RecordFilter
  class Order # :nodoc: all
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

      if (!table.has_column(column))
        raise ColumnNotFoundException.new("The column #{column} was not found in #{table.table_name}.")
      end

      "#{table.table_alias}.#{column} #{dir}"
    end
  end
end
