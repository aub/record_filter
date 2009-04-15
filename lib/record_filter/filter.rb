module RecordFilter
  class Filter

    delegate :inspect, :to => :loaded_data

    def initialize(clazz, named_filter, combine_conjunction, *args, &block)
      @clazz = clazz

      @dsl = dsl_for_named_filter(@clazz, named_filter)
      @dsl.instance_eval(&block) if block
      @dsl.send(named_filter, *args) if named_filter && @dsl.respond_to?(named_filter)
      @dsl.conjunction.steps.unshift(combine_conjunction.steps).flatten! if combine_conjunction
    end

    def filter(&block)
      Filter.new(@clazz, nil, @dsl.conjunction, &block)
    end

    def method_missing(method, *args, &block)
      if @clazz.respond_to?(method) # UGLY, we need to only pass through things that are named filters.
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

    def dsl_for_named_filter(clazz, named_filter)
      return DSL::DSL.create(clazz) if named_filter.blank?
      while (clazz)
        dsl = DSL::DSL::SUBCLASSES.has_key?(clazz.name.to_sym) ? DSL::DSL::SUBCLASSES[clazz.name.to_sym] : nil
        return DSL::DSL.create(clazz) if dsl && dsl.instance_methods(false).include?(named_filter.to_s)
        clazz = clazz.superclass
      end
      nil
    end
  end
end
