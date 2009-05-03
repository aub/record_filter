module RecordFilter
  module DSL
    class DSLFactory # :nodoc: all
      SUBCLASSES = Hash.new do |h, k|
        h[k] = Class.new(RecordFilter::DSL::DSL)
      end

      class << self
        def create(clazz)
          subclass(clazz).new(clazz, Conjunction.new(clazz, :all_of))
        end

        def subclass(clazz)
          SUBCLASSES[clazz.object_id]
        end
      end
    end
  end
end
