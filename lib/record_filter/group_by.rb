module RecordFilter
  class GroupBy # :nodoc: all
    attr_reader :column, :table

    def initialize(column, table)
      @column, @table = column, table
    end

    def to_sql
      table, column = @table, @column
      while column.is_a?(Hash)
        table = table.join_association(column.keys[0]).right_table
        column = column.values[0]
      end

      if (!table.has_column(column))
        raise ColumnNotFoundException.new("The column #{column} was not found in #{table.table_name}.")
      end

      "#{table.table_alias}.#{column}"
    end
  end
end
