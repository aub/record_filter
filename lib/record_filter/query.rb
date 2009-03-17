module RecordFilter
  class Query
    attr_reader :base_restriction, :model_class

    def initialize(model_class)
      @model_class = model_class
      @joins = []
      @base_restriction = RecordFilter::Conjunctions::AllOf.new(self, model_class)
    end

    def add_join(join)
      @joins << join
    end

    def to_find_params
      params = { :conditions => @base_restriction.to_conditions }
      params[:joins] = @joins.map { |join| join.to_sql } * ' AND ' unless @joins.empty?
      params
    end
  end
end
