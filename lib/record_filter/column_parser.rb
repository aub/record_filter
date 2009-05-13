module RecordFilter
  module ColumnParser # :nodoc: all

    protected

    def parse_column_in_table(column, table)
      while column.is_a?(Hash)
        table = table.find_join!(column.keys[0]).right_table
        column = column.values[0]
      end
      [column, table]
    end
  end
end
