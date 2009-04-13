require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'named filters' do
  describe 'defining a simple filter' do
    before do
      Blog.named_filter(:with_test_name) do
        with :name, 'Test Name'
      end
    end

    it 'should call the filter through the filter method' do
      Blog.with_test_name
      Blog.last_find[:conditions].should == ['blogs.name = ?', 'Test Name']
    end

    it 'should call the filter within the block' do
      Blog.filter do
        with_test_name
      end
      Blog.last_find[:conditions].should == ['blogs.name = ?', 'Test Name']
    end
  end

  describe 'defining a filter with arguments' do
    before do
      Blog.named_filter(:with_name) do |name|
        with :name, name
      end
    end

    it 'should call the filter with the passed argument' do
      Blog.with_name('nice name')
      Blog.last_find[:conditions].should == ['blogs.name = ?', 'nice name']
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
      Blog.with_name_and_post_with_permalink('booya', 'ftw')
      Blog.last_find[:conditions].should == ['(blogs.name = ?) AND (blogs__posts.permalink = ?)', 'booya', 'ftw'] 
    end
  end

  describe 'using filters in subclasses' do
    before do
      class NiceComment < Comment
        named_filter(:offensive) do
          with :offensive, true
        end
      end
      Comment.named_filter(:with_contents) do |*args|
        with :contents, args[0]
      end
    end

    it 'should have parent class filters in the subclass' do
      NiceComment.offensive.with_contents('something')
      NiceComment.last_find[:conditions].should == ['comments.offensive = ? AND comments.contents = ?', true, 'something']
    end
  end

  describe 'using compound filters' do
    before do
      Post.named_filter(:with_offensive_comments) do
        having(:comments).offensive(true)
      end
    end

    it 'should concatenate the filters correctly' do
      Post.with_offensive_comments
      Post.last_find[:conditions].should == ['posts__comments.offensive = ?', true] 
      Post.last_find[:joins].should == 'INNER JOIN comments AS posts__comments ON comments.post_id = posts__blog.id'
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
    end

    it 'should chain the filters into a single query' do
      Post.for_blog(1).with_offensive_comments
      Post.last_find[:conditions].should == ['posts__comments.offensive = ? AND posts__blogs.id = ?', true, 1] 
      Post.last_find[:joins].should == 'INNER JOIN comments AS posts__comments ON comments.post_id = posts__blog.id INNER JOIN blogs AS posts__blogs ON posts.id = posts__blogs.id'
    end
  end
end
