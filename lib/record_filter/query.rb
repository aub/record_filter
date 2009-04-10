module RecordFilter
  class Query
    attr_reader :base_restriction, :table

    def initialize(table)
      @table = table
      @base_restriction = RecordFilter::Conjunctions::AllOf.new(self, table)
    end

    def to_find_params
      params = { :conditions => @base_restriction.to_conditions }
      joins = table.all_joins
      params[:joins] = joins.map { |join| join.to_sql } * ' ' unless joins.empty?
      params
    end
  end
end
