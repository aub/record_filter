module RecordFilter
  class Query # :nodoc: all

    attr_reader :dsl_conjunction
    attr_reader :conjunction

    def initialize(clazz, named_filter, *args, &block)
      dsl = dsl_for_named_filter(clazz, named_filter)
      dsl.instance_eval(&block) if block
      dsl.send(named_filter, *args) if named_filter && dsl.respond_to?(named_filter)

      @table = RecordFilter::Table.new(clazz)
      @dsl_conjunction = dsl.conjunction
      @conjunction = RecordFilter::Conjunctions::Base.create_from(@dsl_conjunction, @table)
    end

    def to_find_params(count_query=false)
      @params_cache ||= {}
      @params_cache[count_query] ||= begin
        params = {}
        conditions = @conjunction.to_conditions
        params = { :conditions => conditions } if conditions
        add_joins(params, count_query)
        orders = @table.orders
        params[:order] = orders.map { |order| order.to_sql } * ', ' unless orders.empty?
        group_bys = @table.group_bys
        params[:group] = group_bys.map { |group_by| group_by.to_sql } * ', ' unless group_bys.empty?
        params[:limit] = @conjunction.limit if @conjunction.limit
        params[:offset] = @conjunction.offset if @conjunction.offset
        params
      end
    end

    protected

    def add_joins(params, count_query)
      joins = @table.all_joins
      params[:joins] = joins.map { |join| join.to_sql } unless joins.empty?
      if (joins.any? { |j| j.requires_distinct_select? })
        if count_query
          params[:select] = "DISTINCT #{@table.table_name}.#{@table.model_class.primary_key}"
        else
          params[:select] = "DISTINCT #{@table.table_name}.*"
        end
      end
    end

    def dsl_for_named_filter(clazz, named_filter)
      return DSL::DSLFactory.create(clazz) if named_filter.blank?
      while (clazz)
        dsl = DSL::DSLFactory.get_subclass(clazz)
        if dsl && dsl.instance_methods(false).map { |m| m.to_sym }.include?(named_filter.to_sym)
          return DSL::DSLFactory.create(clazz) 
        end
        clazz = clazz.superclass
      end
    end
  end
end
