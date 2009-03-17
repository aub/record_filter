module RecordFilter
  class Query
    attr_reader :base_restriction, :model_class

    def initialize(model_class)
      @model_class = model_class
      @base_restriction = RecordFilter::Conjunctions::AllOf.new(model_class.table_name)
    end

    def to_find_params
      { :conditions => @base_restriction.to_conditions }
    end
  end
end
