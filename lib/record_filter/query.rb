module RecordFilter
  class Query
    attr_reader :base_restriction, :table

    def initialize(table)
      @table = table
      @base_restriction = RecordFilter::Conjunctions::AllOf.new(table)
    end

    def dup
      copy = self.class.new(@table)
      copy.instance_variable_set('@base_restriction', @base_restriction.dup)
      copy
    end

    def to_find_params
      params = { :conditions => @base_restriction.to_conditions }
      joins = table.all_joins
      params[:joins] = joins.map { |join| join.to_sql } * ' ' unless joins.empty?
      params
    end
  end
end
