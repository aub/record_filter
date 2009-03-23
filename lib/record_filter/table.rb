module RecordFilter
  class Table
    attr_reader :table_alias

    def initialize(model_class, table_alias = nil)
      @model_class = model_class
      @table_alias = table_alias || model_class.table_name
      @joins_cache = {}
    end

    def table_name
      @model_class.table_name
    end

    def join_association(association_name)
      @joins_cache[association_name] ||=
        begin
          association = @model_class.reflect_on_association(association_name)
          join_table = Table.new(association, "#{table_alias.to_s}__#{association_name}")
          join_predicate =
            case association.macro
            when :belongs_to
              { association.primary_key_name.to_sym => :id }
            when :has_many
              { :id => association.primary_key_name.to_sym }
            end
          join = Join.new(self, join_table, join_predicate)
        end
    end

    def all_joins
      joins = @joins_cache.values
      joins + joins.inject([]) do |child_joins, join|
        child_joins.concat(join.right_table.all_joins)
        child_joins
      end
    end
  end
end
