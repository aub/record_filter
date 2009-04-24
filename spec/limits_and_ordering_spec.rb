require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'filter qualifiers' do
  describe 'limits' do
    describe 'simple limit setting' do
      before do
        @params = Post.filter do
          with :published, true
          limit 10
        end.proxy_options
      end

      it 'should add the limit to the parameters' do
        @params[:limit].should == 10
      end
    end

    describe 'with multiple calls to limit' do
      before do
        @params = Post.filter do
          limit 5
          with :published, true
          limit 6
        end.proxy_options
      end

      it 'should add the limit to the parameters' do
        @params[:limit].should == 6 
      end
    end

    describe 'limiting named scopes' do
      before do
        Post.named_filter(:published) do
          with :published, true
          limit 6
        end
      end

      it 'should limit the query' do
        Post.published.proxy_options[:limit].should == 6
      end
    end

    describe 'with a limit that includes an offset' do
      before do
        @params = Post.filter do
          with :published, true
          limit(20, 10)
        end.proxy_options
      end

      it 'should provide an offset and a limit' do
        @params[:limit].should == 10
        @params[:offset].should == 20
      end
    end
  end

  describe 'ordering' do
    describe 'with a simple order supplied' do
      before do
        @params = Post.filter do
          with :published, true
          order(:permalink)
        end.proxy_options
      end

      it 'should add the order to the query' do
        @params[:order].should == %q("posts".permalink ASC)
      end
    end

    describe 'with an explicit direction' do
      before do
        @params = Post.filter do
          with :published, true
          order(:permalink, :desc)
        end.proxy_options
      end

      it 'should add the order and direction to the query' do
        @params[:order].should == %q("posts".permalink DESC)
      end
    end

    describe 'with multiple order clauses' do
      before do
        @params = Post.filter do
          with :published, true
          order(:permalink, :desc)
          order(:id)
        end.proxy_options
      end

      it 'should add both orders and directions to the query' do
        @params[:order].should == %q("posts".permalink DESC, "posts".id ASC)
      end
    end

    describe 'with joins' do
      before do
        @params = Post.filter do
          having(:photo) do
            with :format, 'jpg'
          end
          order({ :photo => :path }, :desc)
          order :permalink
        end.proxy_options
      end

      it 'should add the limit to the parameters' do
        @params[:order].should == %q(posts__photo.path DESC, "posts".permalink ASC)
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
        }.should raise_error(NoMethodError)
      end

      it 'should not allow calls to order within joins' do
        lambda {
          Post.filter do
            having(:photo) do
              order :id
            end
          end
        }.should raise_error(NoMethodError)
      end

      it 'should not allow calls to limit within conjunctions' do
        lambda {
          Post.filter do
            all_of do
              limit 2
            end
          end
        }.should raise_error(NoMethodError)
      end

      it 'should not allow calls to order within joins' do
        lambda {
          Post.filter do
            all_of do
              order :id
            end
          end
        }.should raise_error(NoMethodError)
      end
    end
  end

  describe 'group_by' do
    it 'should add the group for a simple column' do
      @params = Post.filter do
        group_by(:created_at)
      end.proxy_options
      @params[:group].should == %q("posts".created_at)
    end

    it 'should add the group for multiple column' do
      @params = Post.filter do
        group_by(:created_at)
        group_by(:published)
      end.proxy_options
      @params[:group].should == %q("posts".created_at, "posts".published)
    end

    it 'should add the group for joined columns' do
      @params = Post.filter do
        having(:photo)
        group_by(:created_at)
        group_by(:photo => :format)
      end.proxy_options
      @params[:group].should == %q("posts".created_at, posts__photo.format)
    end
  end
end
