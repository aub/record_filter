module RecordFilter
  class Filter

    delegate :inspect, :to => :loaded_data

    def initialize(clazz, named_filter, combine_conjunction, *args, &block)
      @clazz = clazz

      @dsl = DSL::DSL.create(@clazz)
      @dsl.instance_eval(&block) if block
      @dsl.send(named_filter, *args) if named_filter && @dsl.respond_to?(named_filter)
      @dsl.conjunction.steps.unshift(combine_conjunction.steps).flatten! if combine_conjunction
    end

    def filter(&block)
      Filter.new(@clazz, nil, @dsl.conjunction, &block)
    end

    def method_missing(method, *args, &block)
      if DSL::DSL::SUBCLASSES[@clazz.name.to_sym].instance_methods(false).include?(method.to_s)
        Filter.new(@clazz, method, @dsl.conjunction, *args)
      else
        loaded_data.send(method, *args, &block)
      end
    end

    protected

    def loaded_data
      @loaded_data ||= begin
        query = Query.new(@clazz, @dsl.conjunction)
        @clazz.scoped(query.to_find_params)
      end
    end
  end
end
