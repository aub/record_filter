require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'raising exceptions' do
  before do
    TestModel.extended_models.each { |model| model.last_find = {} }
  end 

  describe 'on missing associations' do
    it 'should get AssociationNotFoundException' do
      lambda {
        Post.filter do
          having(:something_that_does_not_exist) do
            with(:something_bad)
          end
        end.inspect
      }.should raise_error(RecordFilter::AssociationNotFoundException)
    end
  end

  describe 'on missing columns' do
    it 'should get ColumnNotFoundException for with' do
      lambda {
        Post.filter do
          with(:this_is_not_there, 2)
        end.inspect
      }.should raise_error(RecordFilter::ColumnNotFoundException)
    end

    it 'should get ColumnNotFoundException for with.not' do
      lambda {
        Post.filter do
          with(:this_is_not_there).not.equal_to(2)
        end.inspect
      }.should raise_error(RecordFilter::ColumnNotFoundException)
    end

    it 'should not get ColumnNotFoundException for order' do
      lambda {
        Post.filter do
          order('this_is_not_there', :asc)
        end.inspect
      }.should_not raise_error(RecordFilter::ColumnNotFoundException)
    end

    it 'should not get ColumnNotFoundException for group_by' do
      lambda {
        Post.filter do
          group_by(:this_is_not_there)
        end.inspect
      }.should_not raise_error(RecordFilter::ColumnNotFoundException)
    end

    it 'should get AssociationNotFoundException for orders on bad associations' do
      lambda {
        Post.filter do
          order({ :this_is_not_there => :eh }, :asc)
        end.inspect
      }.should raise_error(RecordFilter::AssociationNotFoundException)
    end

    it 'should raise ColumnNotFoundException for explicit joins on bad column names for the right table' do
      lambda {
        Review.filter do
          join(Feature, :left) do
            on(:reviewable_id => :ftrable_id)
            on(:reviewable_type => :ftrable_type)
            with(:priority, 5)
          end
        end.inspect
      }.should raise_error(RecordFilter::ColumnNotFoundException)
    end

    it 'should raise ColumnNotFoundException for explicit joins on bad column names for the left table' do
      lambda {
        Review.filter do
          join(Feature, :inner) do
            on(:rvwable_id => :featurable_id)
            on(:rvwable_type => :featurable_type)
            with(:priority, 5)
          end
        end.inspect
      }.should raise_error(RecordFilter::ColumnNotFoundException)
    end

    it 'should raise ColumnNotFoundException for explicit joins on bad column names in conditions' do
      lambda {
        Review.filter do
          join(Feature, :inner) do
            on(:reviewable_id).gt(12)
          end
        end.inspect
      }.should raise_error(RecordFilter::ColumnNotFoundException)
    end

    it 'should raise an ArgumentError if an invalid join type is specified' do
      lambda {
        Review.filter do
          join(Feature, :crazy) do
            on(:reviewable_type => :featurable_type)
          end
        end.inspect
      }.should raise_error(ArgumentError)
    end

    it 'should raise an InvalidJoinException if no columns are specified for the join' do
      lambda {
        Review.filter do
          join(Feature, :inner)
        end.inspect
      }.should raise_error(RecordFilter::InvalidJoinException)
    end
  end

  describe 'limiting methods within joins and conjunctions' do
    it 'should not allow calls to limit within joins' do
      lambda {
        Post.filter do
          having(:photo) do
            limit 2
          end
        end
      }.should raise_error(RecordFilter::InvalidFilterException)
    end

    it 'should not allow calls to group_by within joins' do
      lambda {
        Post.filter do
          having(:photo) do
            group_by(:id)
          end
        end
      }.should raise_error(RecordFilter::InvalidFilterException)
    end

    it 'should not allow calls to order within joins' do
      lambda {
        Post.filter do
          having(:photo) do
            order :id
          end
        end
      }.should raise_error(RecordFilter::InvalidFilterException)
    end

    it 'should not allow calls to limit within conjunctions' do
      lambda {
        Post.filter do
          all_of do
            limit 2
          end
        end
      }.should raise_error(RecordFilter::InvalidFilterException)
    end

    it 'should not allow calls to order within joins' do
      lambda {
        Post.filter do
          all_of do
            order :id
          end
        end
      }.should raise_error(RecordFilter::InvalidFilterException)
    end
  end

  describe 'limiting calls to on' do
    it 'should not allow calls to on in the outer scope' do
      lambda  {
        Post.filter do
          on(:a => :b)
        end
      }.should raise_error(RecordFilter::InvalidFilterException)
    end
  end

  describe 'calling order with an invalid direction' do
    it 'should raise an InvalidFilterException' do
      lambda {
        Post.filter do
          order(:id, :oops)
        end
      }.should raise_error(RecordFilter::InvalidFilterException)
    end
  end

  describe 'calling named filters within filters' do
    it 'should raise an excpetion if the named filter does not exist' do
      lambda {
        Post.filter do
          having(:comments).does_not_exist
        end
      }.should raise_error(RecordFilter::NamedFilterNotFoundException)
    end
  end

  describe 'creating named filters with the same name as an existing one' do
    it 'should raise an InvalidFilterNameException' do
      Post.named_filter(:original) do
        with(:permalink, 'abc')
      end
      lambda {
        Post.named_filter(:original) do
          with(:permalink, 'def')
        end
      }.should raise_error(RecordFilter::InvalidFilterNameException)
    end
  end
end
