module RecordFilter
  class Query

    def initialize(clazz, dsl_conjunction)
      @table = RecordFilter::Table.new(clazz)
      @conjunction = RecordFilter::Conjunctions::Base.create_from(dsl_conjunction, @table)
    end

    def to_find_params
      params = { :conditions => @conjunction.to_conditions }
      joins = @table.all_joins
      params[:joins] = joins.map { |join| join.to_sql } * ' ' unless joins.empty?
      params
    end
  end
end
