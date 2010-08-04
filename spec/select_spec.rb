require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'with custom selects for cases where DISTINCT is required' do
  before do
    TestModel.extended_models.each { |model| model.last_find = {} }
  end 

  describe 'on a standard filter' do
    it 'should put nothing in the select by default' do
      Post.filter do
        having(:comments).with(:offensive, true)
      end.inspect
      Post.last_find[:select].should be_nil
    end

    it 'should use the columns specified in the select' do
      Post.filter do
        select(:id, :title)
        having(:comments).with(:offensive, true)
      end.inspect
      Post.last_find[:select].should == '"posts".id, "posts".title'
    end

    #XXX check bogus column names
  end

  [:left, :right].each do |join_type|
    describe "with #{join_type} join" do
      it 'should put the distinct clause in the select' do
        Post.filter do
          having(:comments, :join_type => join_type).with(:offensive, true)
        end.inspect rescue nil # required because sqlite doesn't support right joins
        Post.last_find[:select].should == %q(DISTINCT "posts".*)
      end

      it 'should put the distinct clause with the columns specified in the select' do
        Post.filter do
          select(:id, :title)
          having(:comments, :join_type => join_type).with(:offensive, true)
        end.inspect rescue nil # required because sqlite doesn't support right joins
        Post.last_find[:select].should == %q(DISTINCT "posts".id, "posts".title)
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

    it 'should create a distinct query on selected columns' do
      Blog.filter do
        with(:created_at).gt(1.day.ago)
        having(:posts).with(:permalink, nil)
        distinct
        select(:id, :name)
      end.inspect
      Blog.last_find[:select].should == %q(DISTINCT "blogs".id, "blogs".name)
    end

    it 'should create a distinct query on selected columns passed into distinct()' do
      Blog.filter do
        with(:created_at).gt(1.day.ago)
        having(:posts).with(:permalink, nil)
        distinct(:id, :name)
      end.inspect
      Blog.last_find[:select].should == %q(DISTINCT "blogs".id, "blogs".name)
    end
  end

  describe 'using the distinct method when chaining named scopes with joins that do not need it' do
    it 'should add distinct' do
      Comment.named_filter(:dirty) do
        with(:offensive, true)
        distinct
      end
      Blog.create
      Blog.first.comments.dirty.inspect
      Comment.last_find[:select].should == %q(DISTINCT "comments".*)
    end
  end
end
