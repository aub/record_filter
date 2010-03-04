module RecordFilter
  module ColumnParser # :nodoc: all

    protected

    def parse_column_in_table(column, table)
      while column.is_a?(Hash)
        join = table.find_join(column.keys[0])
        if join
          table = join.right_table
        else
          table.join_association(column.keys[0])
          table = table.find_join(column.keys[0]).right_table
        end
        column = column.values[0]
      end
      [column, table]
    end
  end
end
