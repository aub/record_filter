module RecordFilter
  module ColumnParser

    protected

    def parse_column_in_table(column, table)
      while column.is_a?(Hash)
        table = table.join_association(column.keys[0]).right_table
        column = column.values[0]
      end
      [column, table]
    end
  end
end
