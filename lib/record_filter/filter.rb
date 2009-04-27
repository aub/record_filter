module RecordFilter
  class Filter

    NON_DELEGATE_METHODS = %w(nil? send object_id class extend find size count sum average maximum minimum paginate first last empty? any? respond_to?)
    [].methods.each do |m|
      unless m =~ /^__/ || NON_DELEGATE_METHODS.include?(m.to_s)
        delegate m, :to => :loaded_data
      end
    end

    def initialize(clazz, named_filter, *args, &block)
      @current_scoped_methods = clazz.send(:current_scoped_methods)
      @clazz = clazz

      @dsl = dsl_for_named_filter(@clazz, named_filter)
      @dsl.instance_eval(&block) if block
      @dsl.send(named_filter, *args) if named_filter && @dsl.respond_to?(named_filter)
      @query = Query.new(@clazz, @dsl.conjunction)
    end

    def first(*args)
      if args.first.kind_of?(Integer)
        loaded_data.first(*args)
      else
        do_with_scope do
          @clazz.find(:first, *args)
        end
      end
    end

    def last(*args)
      if args.first.kind_of?(Integer)
        loaded_data.last(*args)
      else
        do_with_scope do
          @clazz.find(:last, *args)
        end
      end
    end

    def size
      @loaded_data ? @loaded_data.length : count
    end

    def empty?
      @loaded_data ? @loaded_data.empty? : count.zero?
    end

    def any?
      if block_given?
        loaded_data.any? { |*block_args| yield(*block_args) }
      else
        !empty?
      end
    end

    def filter(&block)
      do_with_scope do
        Filter.new(@clazz, nil, &block)
      end
    end

    def proxy_options(count_query=false)
      @query.to_find_params(count_query)
    end

    protected

    def method_missing(method, *args, &block)
      if @clazz.named_filters.include?(method)
        do_with_scope do
          Filter.new(@clazz, method, *args)
        end
      else
        do_with_scope(method == :count) do
          @clazz.send(method, *args, &block)
        end
      end
    end

    def do_with_scope(count_query=false, &block)
      @clazz.send(:with_scope, { :find => proxy_options(count_query), :create => proxy_options(count_query) }, :reverse_merge) do
        if @current_scoped_methods
          @clazz.send(:with_scope, @current_scoped_methods) do
            block.call
          end
        else
          block.call
        end
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

    def loaded_data
      @loaded_data ||= do_with_scope do
        @clazz.find(:all)
      end
    end
  end
end
