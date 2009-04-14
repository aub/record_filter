module RecordFilter
  class Filter

    delegate :inspect, :to => :loaded_data

    def initialize(clazz, named_filter, combine_query, *args, &block)
      @clazz = clazz

      # combine the query with the one from the parent
      @query = (combine_query ? combine_query.dup : nil) || RecordFilter::Query.new(RecordFilter::Table.new(@clazz))
      dsl = DSL::Conjunction.create(@clazz, @query.base_restriction)
      dsl.instance_eval(&block) if block
      dsl.send(named_filter, *args) if named_filter && dsl.respond_to?(named_filter)
    end

    def filter(&block)
      Filter.new(@clazz, nil, @query, &block)
    end

    def method_missing(method, *args, &block)
      if DSL::Conjunction::SUBCLASSES[@clazz.name.to_sym].instance_methods(false).include?(method.to_s)
        Filter.new(@clazz, method, @query, *args)
      else
        loaded_data.send(method, *args, &block)
      end
    end

    protected

    def loaded_data
      @clazz.scoped(@query.to_find_params)
    end
  end
end
