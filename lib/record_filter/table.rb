module RecordFilter
  class Table
    attr_reader :table_alias, :orders, :group_bys, :model_class

    def initialize(model_class, table_alias = nil)
      @model_class = model_class
      @aliased = !table_alias.nil?
      @table_alias = table_alias || model_class.quoted_table_name
      @joins_cache = {}
      @joins = []
      @orders = []
      @group_bys = []
    end

    def table_name
      @model_class.quoted_table_name
    end

    def join_association(association_name, join_type=nil, source_type=nil)
      @joins_cache[association_name] ||=
        begin
          association = @model_class.reflect_on_association(association_name)
          if association.nil?
            raise AssociationNotFoundException.new("The association #{association_name} was not found on #{@model_class.name}.")
          end
          if (association.options[:through])
            through_association = @model_class.reflect_on_association(association.options[:through])
            through_join = join_association(association.options[:through], join_type)
            through_join.right_table.join_association(
              association.options[:source] || association_name, join_type, association.options[:source_type])
          else
            case association.macro
            when :belongs_to, :has_many, :has_one
              simple_join(association, join_type, source_type)
            when :has_and_belongs_to_many
              compound_join(association, join_type)
            end
          end
        end
    end

    def join_class(clazz, join_type, table_alias, conditions)
      @joins_cache[clazz] ||= 
        begin
          join_table = Table.new(clazz, table_alias || alias_for_class(clazz))
          @joins << (join = Join.new(self, join_table, conditions, join_type))
          join
        end
    end

    def all_joins
      @joins + @joins.inject([]) do |child_joins, join|
        child_joins.concat(join.right_table.all_joins)
        child_joins
      end
    end

    def order_column(column, direction)
      @orders << Order.new(column, direction, self)
    end

    def group_by_column(column)
      @group_bys << GroupBy.new(column, self)
    end

    def has_column(column_name)
      @model_class.column_names.include?(column_name.to_s)
    end

    private

    def simple_join(association, join_type, source_type)
      join_predicate =
        case association.macro
        when :belongs_to
          [{ association.options[:foreign_key] || association.association_foreign_key.to_sym => :id }]
        when :has_many, :has_one
          [{ association.options[:primary_key] || :id => association.primary_key_name.to_sym }]
        end

      if association.options[:as]
        join_predicate << DSL::Restriction.new(association.options[:as].to_s + '_type').equal_to(association.active_record.base_class.name)
      end

      clazz = source_type.nil? ? association.klass : source_type.constantize

      join_table = Table.new(clazz, alias_for_association(association))
      @joins << join = Join.new(self, join_table, join_predicate, join_type)
      join
    end

    def compound_join(association, join_type)
      pivot_join_predicate = [{ :id => association.primary_key_name.to_sym }]
      table_name = @model_class.connection.quote_table_name(association.options[:join_table])
      pivot_table = PivotTable.new(table_name, association, "__#{alias_for_association(association)}")
      pivot_join = Join.new(self, pivot_table, pivot_join_predicate, join_type)
      join_predicate = [{ association.association_foreign_key.to_sym => :id }]
      join_table = Table.new(association.klass, alias_for_association(association))
      pivot_table.joins << join = Join.new(pivot_table, join_table, join_predicate, join_type)
      @joins << pivot_join
      join
    end

    protected

    def alias_for_association(association)
      "#{@aliased ? @table_alias.to_s : @model_class.table_name}__#{association.name}"
    end

    alias_method :alias_for_class, :alias_for_association
  end

  class PivotTable < Table
    attr_reader :table_name, :joins

    def initialize(table_name, association, table_alias = table_name)
      @table_name, @table_alias = table_name, table_alias
      @joins_cache = {}
      @joins = []
      @orders = []
      @group_bys = []
      @primary_key = association.primary_key_name.to_sym
      @foreign_key = association.association_foreign_key.to_sym
    end

    def has_column(column_name)
      [@primary_key, @foreign_key].include?(column_name.to_sym)
    end
  end
end
