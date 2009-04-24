module RecordFilter
  class Filter

    delegate :inspect, :to => :loaded_data

    def initialize(clazz, named_filter, combine_conjunction, *args, &block)
      @current_scoped_methods = clazz.send(:current_scoped_methods)
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
      if @clazz.named_filters.include?(method)
        Filter.new(@clazz, method, @dsl.conjunction, *args)
      else
        call_with_scope(method, *args, &block)
      end
    end

    def call_with_scope(method, *args, &block)
      params = find_params([:size, :length, :count].include?(method))
      @clazz.send(:with_scope, { :find => params, :create => params }, :reverse_merge) do
        if @current_scoped_methods
          @clazz.send(:with_scope, @current_scoped_methods) do
            @clazz.send(method, *args, &block)
          end
        else
          @clazz.send(method, *args, &block)
        end
      end
    end

    protected

    def find_params(for_count) 
      query = Query.new(@clazz, @dsl.conjunction)
      query.to_find_params(for_count)
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

    def loaded_data
      call_with_scope(:find, :all)
    end
  end
end
