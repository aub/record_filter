module RecordFilter
  class Join
    attr_reader :left_table, :right_table

    def initialize(left_table, right_table, join_predicate)
      @left_table, @right_table, @join_predicate =
        left_table, right_table, join_predicate
    end

    def to_sql
      predicate_sql = @join_predicate.map do |left_column, right_column|
        "#{column_predicate(@left_table, left_column)} = #{column_predicate(@right_table, right_column)}"
      end * ' AND '
      "INNER JOIN #{@right_table.table_name} AS #{@right_table.table_alias} ON #{predicate_sql}"
    end

    protected

    def column_predicate(table, column)
      if (column.is_a?(Symbol) && !table.has_column(column))
        raise ColumnNotFoundException.new("The column #{column} was not found in the table #{table.table_name}")
      end
      case(column)
        when Symbol then "#{table.table_alias}.#{column}"
        when String then "'#{column}'"
        else column
      end     
    end
  end
end
