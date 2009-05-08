module RecordFilter
  class Order # :nodoc: all
    include ColumnParser

    attr_reader :column, :direction, :table

    def initialize(column, direction, table)
      @column, @direction, @table = column, direction, table
    end

    def to_sql
      dir = case @direction
        when :asc then 'ASC'
        when :desc then 'DESC'
        else raise InvalidFilterException.new("An invalid order of #{@direction} was specified.") 
      end
      column, table = parse_column_in_table(@column, @table)
      "#{table.table_alias}.#{column} #{dir}"
    end
  end
end
