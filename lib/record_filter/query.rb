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
      orders = @table.all_orders
      params[:order] = orders.map { |order| order.to_sql } * ', ' unless orders.empty?
      params[:limit] = @conjunction.limit if @conjunction.limit
      params[:offset] = @conjunction.offset if @conjunction.offset
      params
    end
  end
end
