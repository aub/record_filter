require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'with custom selects for cases where DISTINCT is required' do
  
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
      [:left, :outer, :left_outer].each do |join_type|
        Post.filter do
          having(join_type, :comments).with(:offensive, true)
        end.inspect
        Post.last_find[:select].should == %q(DISTINCT "posts".*)
      end
    end
  end

  describe 'with join types that do not require distinct' do
    it 'should not put the distinct clause in the select' do
      [:inner].each do |join_type|
        Post.filter do
          having(join_type, :comments).with(:offensive, true)
        end.inspect
        Post.last_find[:select].should be_nil
      end
    end
  end

  describe 'on a filter with nested joins that require distinct' do
    it 'should put the distinct clause in the select' do
      Blog.filter do
        having(:posts) do
          having(:left_outer, :comments).with(:offensive, true)
        end
      end.inspect
      Blog.last_find[:select].should == %q(DISTINCT "blogs".*)
    end
  end

  describe 'on a filter that requires distinct with a count call' do
    it 'should put the distinct clause in the select' do
      Post.filter do
        having(:left_outer, :comments).with(:offensive, true)
      end.count
      Post.last_find[:select].should == %q(DISTINCT "posts".id)
    end
  end
end
