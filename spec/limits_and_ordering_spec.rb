require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'filter qualifiers' do
  before do
    TestModel.extended_models.each { |model| model.last_find = {} }
  end

  describe 'limits' do
    describe 'simple limit setting' do
      before do
        Post.filter do
          with :published, true
          limit 10
        end.inspect
      end

      it 'should add the limit to the parameters' do
        Post.last_find[:limit].should == 10
      end
    end

    describe 'with multiple calls to limit' do
      before do
       Post.filter do
          limit 5
          with :published, true
          limit 6
        end.inspect
      end

      it 'should add the limit to the parameters' do
        Post.last_find[:limit].should == 6 
      end
    end

    describe 'limiting named scopes' do
      before do
        @post = Class.new(Post)
        @post.named_filter(:published_ones) do
          limit(2)
          with(:published, false)
        end
      end

      it 'should limit the query' do
        @post.published_ones.inspect
        @post.last_find[:limit].should == 2
      end
    end

    describe 'with a limit that includes an offset' do
      before do
        Post.filter do
          with :published, true
          limit(20, 10)
        end.inspect
      end

      it 'should provide an offset and a limit' do
        Post.last_find[:limit].should == 10
        Post.last_find[:offset].should == 20
      end
    end
  end

  describe 'ordering' do
    describe 'with a simple order supplied' do
      before do
        Post.filter do
          with :published, true
          order(:permalink)
        end.inspect
      end

      it 'should add the order to the query' do
        Post.last_find[:order].should == %q("posts".permalink ASC)
      end
    end

    describe 'with an explicit direction' do
      before do
        Post.filter do
          with :published, true
          order(:permalink, :desc)
        end.inspect
      end

      it 'should add the order and direction to the query' do
        Post.last_find[:order].should == %q("posts".permalink DESC)
      end
    end

    describe 'with multiple order clauses' do
      before do
        Post.filter do
          with :published, true
          order(:permalink, :desc)
          order(:id)
        end.inspect
      end

      it 'should add both orders and directions to the query' do
        Post.last_find[:order].should == %q("posts".permalink DESC, "posts".id ASC)
      end
    end

    describe 'with joins' do
      before do
        Post.filter do
          having(:photo) do
            with :format, 'jpg'
          end
          order({ :photo => :path }, :desc)
          order :permalink
        end.inspect
      end

      it 'should add the limit to the parameters' do
        Post.last_find[:order].should == %q(posts__photo.path DESC, "posts".permalink ASC)
      end
    end
  end

  describe 'group_by' do
    it 'should add the group for a simple column' do
      Post.filter do
        group_by(:created_at)
      end.inspect
      Post.last_find[:group].should == %q("posts".created_at)
    end

    it 'should add the group for multiple column' do
      Post.filter do
        group_by(:created_at)
        group_by(:published)
      end.inspect
      Post.last_find[:group].should == %q("posts".created_at, "posts".published)
    end

    it 'should add the group for joined columns' do
      Post.filter do
        having(:photo)
        group_by(:created_at)
        group_by(:photo => :format)
      end.inspect
      Post.last_find[:group].should == %q("posts".created_at, posts__photo.format)
    end

    it 'should accept random strings as the column name' do
      Post.filter do
        group_by("abcdef")
      end.find(:all, :select => 'posts.id as abcdef').inspect
      Post.last_find[:group].should == 'abcdef'
    end
  end
end
