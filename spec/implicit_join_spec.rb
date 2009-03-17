require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'implicit joins' do
  describe 'on belongs_to' do
    before do
      Post.filter do
        having(:blog).with :title, 'Test Title'
      end
    end

    it 'should add correct join' do
      Post.last_find[:joins].should == 'INNER JOIN blogs ON posts.blog_id = blogs.id'
    end
  end
end
