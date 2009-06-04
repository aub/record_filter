require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'with custom selects for cases where DISTINCT is required' do
  before do
    TestModel.extended_models.each { |model| model.last_find = {} }
  end 

  describe 'on a standard filter' do
    it 'should put nothing in the select' do
      Post.filter do
        having(:comments).with(:offensive, true)
      end.inspect
      Post.last_find[:select].should be_nil
    end
  end

  describe 'with join types that require distinct' do
    it 'should put the distinct clause in the select' do
      [:left, :right].each do |join_type|
        Post.filter do
          having(:comments, :join_type => join_type).with(:offensive, true)
        end.inspect rescue nil # required because sqlite doesn't support right joins
        Post.last_find[:select].should == %q(DISTINCT "posts".*)
      end
    end
  end

  describe 'with join types that do not require distinct' do
    it 'should not put the distinct clause in the select' do
      Post.filter do
        having(:comments, :join_type => :inner).with(:offensive, true)
      end.inspect
      Post.last_find[:select].should be_nil
    end
  end

  describe 'on a filter with nested joins that require distinct' do
    it 'should put the distinct clause in the select' do
      Blog.filter do
        having(:posts) do
          having(:comments, :join_type => :left).with(:offensive, true)
        end
      end.inspect
      Blog.last_find[:select].should == %q(DISTINCT "blogs".*)
    end
  end

  describe 'on a filter that requires distinct with a count call' do
    it 'should put the distinct clause in the select' do
      Post.filter do
        having(:comments, :join_type => :left).with(:offensive, true)
      end.count
      Post.last_find[:select].should == %q(DISTINCT "posts".id)
    end
  end

  describe 'using the distinct method' do
    it 'should always create a distinct query' do
      Blog.filter do
        with(:created_at).gt(1.day.ago)
        having(:posts).with(:permalink, nil)
        distinct
      end.inspect
      Blog.last_find[:select].should == %q(DISTINCT "blogs".*)
    end
  end
end
