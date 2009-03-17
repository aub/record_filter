require File.join(File.dirname(__FILE__), 'spec_helper')

describe RecordFilter do
  it 'should filter for equality' do
    Post.filter do
      with :permalink, 'blog-post'
    end
    Post.last_find.should == { :conditions => [%q{posts.permalink = ?}, 'blog-post'] }
  end

  it 'should filter for equality with multiple conditions' do
    Post.filter do
      with :permalink, 'blog-post'
      with :blog_id, 3
    end
    Post.last_find.should == { :conditions => [%q{(posts.permalink = ?) AND (posts.blog_id = ?)}, 'blog-post', 3] }
  end

  it 'should filter for less than' do
    Post.filter do
      with(:created_at).less_than Time.parse('2009-01-03 23:02:00')
    end
    Post.last_find.should == { :conditions => [%q{posts.created_at < ?}, Time.parse('2009-01-03 23:02:00')] }
  end

  it 'should filter for greater than' do
    Post.filter do
      with(:created_at).greater_than Time.parse('2008-01-03 23:23:00')
    end
    Post.last_find.should == { :conditions => [%q{posts.created_at > ?}, Time.parse('2008-01-03 23:23:00')] }
  end

  it 'should filter for in' do
    Post.filter do
      with(:blog_id).in [1, 3, 5]
    end
    Post.last_find.should == { :conditions => [%q{posts.blog_id IN (?)}, [1, 3, 5]] }
  end

  it 'should filter for between' do
    time1 = Time.parse('2008-01-03 23:23:00')
    time2 = Time.parse('2008-01-03 23:36:00')
    Post.filter do
      with(:created_at).between time1..time2
    end
    Post.last_find.should == { :conditions => [%q{posts.created_at BETWEEN ? AND ?}, time1, time2] }
  end

#   it 'should filter by disjunction' do
#     Post.filter do
#       any_of do
#         with.blog_id.equal_to 1
#         with.permalink.equal_to 'my-post'
#       end
#     end
#     Post.last_find.should == { :conditions => [%q{(posts.blog_id = ?) OR (permalink = ?)}, 1, 'my-post'] }
#   end
end
