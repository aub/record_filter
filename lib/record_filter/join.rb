module RecordFilter
  class Join
    attr_reader :left_table, :right_table

    def initialize(left_table, right_table, join_predicate)
      @left_table, @right_table, @join_predicate =
        left_table, right_table, join_predicate
    end

    def to_sql
      predicate_sql = @join_predicate.map do |left_column, right_column|
        "#{@left_table.table_alias}.#{left_column} = #{@right_table.table_alias}.#{right_column}"
      end * ' AND '
      "INNER JOIN #{@right_table.table_name} AS #{@right_table.table_alias} ON #{predicate_sql}"
    end
  end
end
