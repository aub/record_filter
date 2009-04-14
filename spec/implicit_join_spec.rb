require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'implicit joins' do
  before do
    TestModel.extended_models.each { |model| model.last_find = {} }
  end

  describe 'on belongs_to' do
    describe 'with single condition inline' do
      before do
        Post.filter do
          having(:blog).with :title, 'Test Title'
        end.inspect
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
        end.inspect
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
        end.inspect
      end

      it_should_behave_like 'multiple conditions on single join'
    end
  end

  describe 'on has_many' do
    before do
      Blog.filter do
        having(:posts).with :permalink, 'test-post'
      end.inspect
    end

    it 'should add correct join' do
      Blog.last_find[:joins].should == 'INNER JOIN posts AS blogs__posts ON blogs.id = blogs__posts.blog_id'
    end

    it 'should query against condition on join table' do
      Blog.last_find[:conditions].should == ['blogs__posts.permalink = ?', 'test-post']
    end
  end

  describe 'with multiple joins' do
    before do
      Blog.filter do
        having(:posts) do
          with :permalink, 'test-post'
          having(:comments).with :offensive, true
        end
      end.inspect
    end

    it 'should add both joins' do
      Blog.last_find[:joins].should == 'INNER JOIN posts AS blogs__posts ON blogs.id = blogs__posts.blog_id ' +
                                       'INNER JOIN comments AS blogs__posts__comments ON blogs__posts.id = blogs__posts__comments.post_id'
    end

    it 'should query against both conditions' do
      Blog.last_find[:conditions].should == ['(blogs__posts.permalink = ?) AND (blogs__posts__comments.offensive = ?)', 'test-post', true] 
    end
  end

  describe 'on has_one' do
    before do
      Post.filter do
        having(:photo).with :format, 'jpg'
      end.inspect
    end

    it 'should add correct join' do
      Post.last_find[:joins].should == 'INNER JOIN photos AS posts__photo ON posts.id = posts__photo.post_id'
    end

    it 'should query against condition on join table' do
      Post.last_find[:conditions].should == ['posts__photo.format = ?', 'jpg']
    end
  end

  describe 'with nested joins' do
    before do
      Blog.filter do
        having(:posts).having(:photo).with :format, 'png'
      end.inspect
    end

    it 'should add correct join' do
      Blog.last_find[:joins].should == 'INNER JOIN posts AS blogs__posts ON blogs.id = blogs__posts.blog_id ' +
                                       'INNER JOIN photos AS blogs__posts__photo ON blogs__posts.id = blogs__posts__photo.post_id'
    end

    it 'should query against condition on join table' do
      Blog.last_find[:conditions].should == ['blogs__posts__photo.format = ?', 'png']
    end
  end

  describe 'with has and belongs to many joins' do
    before do
      Post.filter do
        having(:tags).with :name, 'activerecord'
      end.inspect
    end

    it 'should add correct join' do
      Post.last_find[:joins].should == 'INNER JOIN posts_tags AS __posts__tags ON posts.id = __posts__tags.post_id ' +
                                       'INNER JOIN tags AS posts__tags ON __posts__tags.tag_id = posts__tags.id'
    end
  end

  describe 'with negative conditions' do
    before do
      Comment.filter do
        with :offensive, false
      end.inspect
    end

    it 'should create the correct condition' do
      Comment.last_find[:conditions].should == ['comments.offensive = ?', false]
    end
  end

  describe 'with nil conditions' do
    before do
      Comment.filter do
        with :content, nil
        with :offensive, true
      end.inspect
    end

    it 'should create the correct IS NULL condition' do
      Comment.last_find[:conditions].should == ['(comments.content IS NULL) AND (comments.offensive = ?)', true]
    end
  end

  describe 'with negated conditions' do
    before do
      Comment.filter do
        without :offensive, false
      end.inspect
    end

    it 'should create the correct condition' do
      Comment.last_find[:conditions].should == ['comments.offensive != ?', false]
    end
  end

  describe 'with negated nil conditions' do
    before do
      Comment.filter do
        without :content, nil
        with :offensive, true
      end.inspect
    end

    it 'should create the correct IS NOT NULL condition' do
      Comment.last_find[:conditions].should == ['(comments.content IS NOT NULL) AND (comments.offensive = ?)', true]
    end
  end
end
