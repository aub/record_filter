module RecordFilter
  module ColumnParser

    protected

    def parse_column_in_table(column, table, check_column_exists=true)
      while column.is_a?(Hash)
        table = table.join_association(column.keys[0]).right_table
        column = column.values[0]
      end

      if (check_column_exists && !table.has_column(column))
        raise ColumnNotFoundException.new("The column #{column} was not found in #{table.table_name}.")
      end
      [column, table]
    end
  end
end
