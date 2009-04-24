module RecordFilter
  class Filter

    delegate :inspect, :to => :loaded_data

    NON_DELEGATE_METHODS = %w(nil? send object_id class extend find respond_to? first last)
    [].methods.each do |m|
      unless m =~ /^__/ || NON_DELEGATE_METHODS.include?(m.to_s)
        delegate m, :to => :loaded_data
      end
    end

    def initialize(clazz, named_filter, combine_conjunction, *args, &block)
      @current_scoped_methods = clazz.send(:current_scoped_methods)
      @clazz = clazz

      @dsl = dsl_for_named_filter(@clazz, named_filter)
      @dsl.instance_eval(&block) if block
      @dsl.send(named_filter, *args) if named_filter && @dsl.respond_to?(named_filter)
      @dsl.conjunction.steps.unshift(combine_conjunction.steps).flatten! if combine_conjunction
    end

    def first(*args)
      if args.first.kind_of?(Integer)
        loaded_data.first(*args)
      else
        call_with_scope(:find, :first, *args)
      end
    end

    def last(*args)
      if args.first.kind_of?(Integer)
        loaded_data.last(*args)
      else
        call_with_scope(:find, :last, *args)
      end
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
      params = proxy_options([:size, :length, :count].include?(method))
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

    def proxy_options(for_count=false) 
      query = Query.new(@clazz, @dsl.conjunction)
      query.to_find_params(for_count)
    end

    protected

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
