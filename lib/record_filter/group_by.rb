module RecordFilter
  class GroupBy # :nodoc: all
    include ColumnParser

    attr_reader :column, :table

    def initialize(column, table)
      @column, @table = column, table
    end

    def to_sql
      column, table = parse_column_in_table(@column, @table)

      if (table.has_column(column))
        "#{table.table_alias}.#{column}"
      else
        column
      end
    end
  end
end
