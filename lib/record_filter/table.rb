module RecordFilter
  class Table # :nodoc: all
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

    def join_association(association_name, join_type=nil, options={})
      association_name = association_name.to_sym
      @joins_cache[association_name] ||=
        begin
          association = @model_class.reflect_on_association(association_name)
          if association.nil?
            raise AssociationNotFoundException.new("The association #{association_name} was not found on #{@model_class.name}.")
          end
          if (association.options[:through])
            through_association = @model_class.reflect_on_association(association.options[:through])

            through_join = join_association(
              association.options[:through], 
              join_type, 
              :type_restriction => association.options[:source_type], 
              :source => association.options[:source])

            through_join.right_table.join_association(
              association.options[:source] || association_name, join_type, :join_class => association.options[:source_type])
          else
            case association.macro
            when :belongs_to, :has_many, :has_one
              simple_join(association, join_type, options)
            when :has_and_belongs_to_many
              compound_join(association, join_type)
            else raise InvalidJoinException.new("I don't know how to join on an association of type #{association.macro}.")
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

    def simple_join(association, join_type, options)
      join_predicate =
        case association.macro
        when :belongs_to
          [{ association.options[:foreign_key] || association.primary_key_name.to_sym => @model_class.primary_key }]
        when :has_many, :has_one
          [{ association.options[:primary_key] || @model_class.primary_key => association.primary_key_name.to_sym }]
        else raise InvalidJoinException.new("I don't know how to do a simple join on an association of type #{association.macro}.")
        end

      if association.options[:as]
        join_predicate << DSL::Restriction.new(association.options[:as].to_s + '_type').equal_to(association.active_record.base_class.name)
      end

      if options[:type_restriction] && options[:source]
        foreign_type = association.klass.reflect_on_association(options[:source]).options[:foreign_type]
        join_predicate << DSL::Restriction.new(foreign_type).equal_to(options[:type_restriction])
      end

      clazz = options[:join_class].nil? ? association.klass : options[:join_class].constantize

      join_table = Table.new(clazz, alias_for_association(association))
      @joins << join = Join.new(self, join_table, join_predicate, join_type)
      join
    end

    def compound_join(association, join_type)
      pivot_join_predicate = [{ @model_class.primary_key => association.primary_key_name.to_sym }]
      table_name = @model_class.connection.quote_table_name(association.options[:join_table])
      pivot_table = PivotTable.new(table_name, association, "__#{alias_for_association(association)}")
      pivot_join = Join.new(self, pivot_table, pivot_join_predicate, join_type)
      join_predicate = [{ association.association_foreign_key.to_sym => @model_class.primary_key }]
      join_table = Table.new(association.klass, alias_for_association(association))
      pivot_table.joins << join = Join.new(pivot_table, join_table, join_predicate, join_type)
      @joins << pivot_join
      join
    end

    protected

    def alias_for_association(association)
      "#{@aliased ? @table_alias.to_s : @model_class.table_name}__#{association.name.to_s.downcase}"
    end

    alias_method :alias_for_class, :alias_for_association
  end

  class PivotTable < Table # :nodoc: all
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
