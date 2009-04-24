require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'named filters' do
  before do
    TestModel.extended_models.each { |model| model.last_find = {} }
  end

  describe 'defining a simple filter' do
    before do
      Blog.named_filter(:with_test_name) do
        with :name, 'Test Name'
      end
    end

    it 'should call the filter through the filter method' do
      Blog.with_test_name.inspect
      Blog.last_find[:conditions].should == [%q("blogs".name = ?), 'Test Name']
    end

    it 'should call the filter within the block' do
      Blog.filter do
        with_test_name
      end.inspect
      Blog.last_find[:conditions].should == [%q("blogs".name = ?), 'Test Name']
    end
  end

  describe 'defining a filter with arguments' do
    before do
      Blog.named_filter(:with_name) do |name|
        with :name, name
      end
    end

    it 'should call the filter with the passed argument' do
      Blog.with_name('nice name').inspect
      Blog.last_find[:conditions].should == [%q("blogs".name = ?), 'nice name']
    end
  end

  describe 'defining a filter that passes arguments down several levels' do
    before do
      Blog.named_filter(:with_name_and_post_with_permalink) do |name, permalink|
        with :name, name
        having :posts do
          with :permalink, permalink
        end
      end
    end

    it 'should call the filter passing all of the arguments' do
      Blog.with_name_and_post_with_permalink('booya', 'ftw').inspect
      Blog.last_find[:conditions].should == [%q(("blogs".name = ?) AND (blogs__posts.permalink = ?)), 'booya', 'ftw'] 
    end
  end

  describe 'taking active_record objects as arguments' do
    it 'should use the id of the object as the actual parameter' do
      Post.named_filter(:with_ar_arg) do |blog|
        with(:blog_id, blog)
      end
      blog = Blog.create
      Post.with_ar_arg(blog).inspect
      Post.last_find[:conditions].should == [%q("posts".blog_id = ?), blog.id]
    end
  end

  describe 'using filters in subclasses' do
    before do
      Comment.named_filter(:with_contents) do |*args|
        with :contents, args[0]
      end
      class NiceComment < Comment
        extend TestModel

        named_filter(:offensive) do
          with :offensive, true
        end
      end
    end

    it 'should execute the parent class filters correctly' do
      NiceComment.with_contents('test contents').inspect
      NiceComment.last_find[:conditions].should == [%q("comments".contents = ?), 'test contents']
    end

    it 'should not have the subclass filters in the parent class' do
      Comment.respond_to?(:offensive).should == false
    end

    it 'should have parent class filters in the subclass' do
      NiceComment.offensive.with_contents('something').inspect
      NiceComment.last_find[:conditions].should == [%q(("comments".offensive = ?) AND ("comments".contents = ?)), true, 'something']
    end

    it 'should provide access to the named filters' do
      Comment.named_filters.should == [:with_contents]
      NiceComment.named_filters.sort_by { |i| i.to_s }.should == [:offensive, :with_contents]
    end
  end

  describe 'using compound filters' do
    it 'should concatenate the filters correctly' do
      pending 'nested chaining'
      Post.named_filter(:with_offensive_comments) do
        having(:comments).offensive(true)
      end
      Post.with_offensive_comments.inspect
      Post.last_find[:conditions].should == [%q(posts__comments.offensive = ?), true] 
      Post.last_find[:joins].should == %q(INNER JOIN "comments" AS posts__comments ON "comments".post_id = posts__blog.id)
    end
  end

  describe 'chaining filters' do
    before do
      Post.named_filter(:for_blog) do |*args|
        having(:blog).with :id, args[0]
      end
      Post.named_filter(:with_offensive_comments) do
        having(:comments).with :offensive, true
      end
      Post.named_filter(:with_interesting_comments) do
        having(:comments).with :offensive, false
      end
    end

    it 'should chain the filters into a single query' do
      Post.for_blog(1).with_offensive_comments.inspect
      Post.last_find[:conditions].should == [%q((posts__blog.id = ?) AND (posts__comments.offensive = ?)), 1, true]
      Post.last_find[:joins].should == %q(INNER JOIN "blogs" AS posts__blog ON "posts".blog_id = posts__blog.id INNER JOIN "comments" AS posts__comments ON "posts".id = posts__comments.post_id)
    end

    it 'should remove duplicate joins' do
      Post.for_blog(1).with_offensive_comments.with_interesting_comments.inspect
      Post.last_find[:joins].should == %q(INNER JOIN "blogs" AS posts__blog ON "posts".blog_id = posts__blog.id INNER JOIN "comments" AS posts__comments ON "posts".id = posts__comments.post_id)
    end

    it 'should allow for filtering a named_filter' do
      Post.for_blog(1).filter { having(:comments).with :offensive, true }.inspect
      Post.last_find[:conditions].should == [%q((posts__blog.id = ?) AND (posts__comments.offensive = ?)), 1, true]
      Post.last_find[:joins].should == %q(INNER JOIN "blogs" AS posts__blog ON "posts".blog_id = posts__blog.id INNER JOIN "comments" AS posts__comments ON "posts".id = posts__comments.post_id)
    end

    it 'should allow for applying a named filter to a filter' do
      Post.filter { having(:comments).with :offensive, false }.for_blog(1).inspect
      Post.last_find[:conditions].should == [%q((posts__comments.offensive = ?) AND (posts__blog.id = ?)), false, 1]
      Post.last_find[:joins].should == %q(INNER JOIN "comments" AS posts__comments ON "posts".id = posts__comments.post_id INNER JOIN "blogs" AS posts__blog ON "posts".blog_id = posts__blog.id)  
    end

    it 'should not change the inner filter conditions when chaining filters' do
      base = Post.for_blog(1)
      base.with_offensive_comments
      base.inspect
      Post.last_find[:conditions].should == [%q(posts__blog.id = ?), 1]
    end

    it 'should not change the inner filter joins when chaining filters' do
      base = Post.for_blog(1)
      base.with_offensive_comments
      base.inspect
      Post.last_find[:joins].should == %q(INNER JOIN "blogs" AS posts__blog ON "posts".blog_id = posts__blog.id)
    end

    it 'should not change an original filter when reusing it' do
      base = Post.for_blog(1)
      level1 = base.with_offensive_comments
      level2 = base.with_interesting_comments
      level1.inspect
      Post.last_find[:conditions].should == [%q((posts__blog.id = ?) AND (posts__comments.offensive = ?)), 1, true]
      Post.last_find[:joins].should == %q(INNER JOIN "blogs" AS posts__blog ON "posts".blog_id = posts__blog.id INNER JOIN "comments" AS posts__comments ON "posts".id = posts__comments.post_id)
    end
  end

  describe 'chaining named filters with regular AR associations' do
    before do
      Post.named_filter(:published) do
        with(:published, true)
      end
      @blog = Blog.create
      @blog.posts.published.inspect
    end

    it 'should combine the conditions from the association with the named filter' do
      Post.last_find[:conditions].should == "(\"posts\".published = 't') AND (\"posts\".blog_id = #{@blog.id})"
    end
  end

  describe 'chaining named filters with AR associations that involve joins' do
    before do
      Comment.named_filter(:with_user_named) do |name|
        having(:user).with(:first_name, name)
      end
      @blog = Blog.create
      @blog.comments.with_user_named('Bob').inspect 
    end

    it 'should combine the joins from the association with the named filter' do
      Comment.last_find[:joins].should == [%q(INNER JOIN "users" AS comments__user ON "comments".user_id = comments__user.id), %q(INNER JOIN "posts" ON "comments".post_id = "posts".id)]
    end

    it 'should combine the conditions from the association with the named filter' do
      Comment.last_find[:conditions].should == "(comments__user.first_name = 'Bob') AND ((\"posts\".blog_id = #{@blog.id}))"
    end
  end
end
