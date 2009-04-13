module RecordFilter
  class Scope

    delegate :inspect, :to => :loaded_data

    def initialize(clazz, scope_name, combine_query, *args)
      @clazz, @scope_name, @combine_query = clazz, scope_name, combine_query

      # combine the query with the one from the parent
      @query = combine_query || RecordFilter::Query.new(RecordFilter::Table.new(@clazz))
      dsl = DSL::Conjunction.create(@clazz, @query.base_restriction)
      dsl.send(@scope_name, *args)
    end

    def filter(&block)
    end

    def method_missing(method, *args, &block)
      if DSL::Conjunction::SUBCLASSES[@clazz.name.to_sym].instance_methods(false).include?(method.to_s)
        Scope.new(@clazz, method, @query, *args)
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
