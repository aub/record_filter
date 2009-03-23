require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'implicit joins' do
  describe 'on belongs_to' do
    describe 'with single condition inline' do
      before do
        Post.filter do
          having(:blog).with :title, 'Test Title'
        end
      end

      it 'should add correct join' do
        Post.last_find[:joins].should == 'INNER JOIN blogs AS posts__blog ON posts.blog_id = posts__blog.id'
      end

      it 'should query against condition on join table' do
        Post.last_find[:conditions].should == ['posts__blog.title = ?', 'Test Title']
      end
    end

    shared_examples_for 'multiple conditions on single join' do
      it 'should add join once' do
        Post.last_find[:joins].should == 'INNER JOIN blogs AS posts__blog ON posts.blog_id = posts__blog.id'
      end

      it 'should query against conditions on join table' do
        Post.last_find[:conditions].should == ['(posts__blog.title = ?) AND (posts__blog.published = ?)', 'Test Title', true]
      end
    end

    describe 'with multiple conditions on single join inline' do
      before do
        Post.filter do
          having(:blog).with :title, 'Test Title'
          having(:blog).with :published, true
        end
      end

      it_should_behave_like 'multiple conditions on single join'
    end

    describe 'with multiple conditions on a single join in a block' do
      before do
        Post.filter do
          having :blog do
            with :title, 'Test Title'
            with :published, true
          end
        end
      end

      it_should_behave_like 'multiple conditions on single join'
    end
  end

  describe 'on has_many' do
    before do
      Blog.filter do
        having(:posts).with :permalink, 'test-post'
      end
    end

    it 'should add correct join' do
      Blog.last_find[:joins].should == 'INNER JOIN posts AS blogs__posts ON blogs.id = blogs__posts.blog_id'
    end

    it 'should query against condition on join table' do
      Blog.last_find[:conditions].should == ['blogs__posts.permalink = ?', 'test-post']
    end
  end
end
