module RecordFilter
  class Query

    def initialize(clazz, dsl_conjunction)
      @table = RecordFilter::Table.new(clazz)
      @conjunction = RecordFilter::Conjunctions::Base.create_from(dsl_conjunction, @table)
    end

    def to_find_params(count_query=false)
      params = { :conditions => @conjunction.to_conditions }
      joins = @table.all_joins
      params[:joins] = joins.map { |join| join.to_sql } * ' ' unless joins.empty?
      if (joins.any? { |j| j.requires_distinct_select? })
        if count_query
          params[:select] = "DISTINCT #{@table.model_class.quoted_table_name}.#{@table.model_class.primary_key}"
        else
          params[:select] = "DISTINCT #{@table.model_class.quoted_table_name}.*"
        end
      end
      orders = @table.orders
      params[:order] = orders.map { |order| order.to_sql } * ', ' unless orders.empty?
      group_bys = @table.group_bys
      params[:group] = group_bys.map { |group_by| group_by.to_sql } * ', ' unless group_bys.empty?
      params[:limit] = @conjunction.limit if @conjunction.limit
      params[:offset] = @conjunction.offset if @conjunction.offset
      params
    end
  end
end
