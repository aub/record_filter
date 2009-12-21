require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'RecordFilter restrictions' do
  before do
    TestModel.extended_models.each { |model| model.last_find = {} }
  end

  it 'should filter for equality' do
    Post.filter do
      with :permalink, 'blog-post'
    end.inspect
    Post.last_find.should == { :readonly => false, :conditions => [%q{"posts".permalink = ?}, 'blog-post'] }
  end

  it 'should filter for equality with multiple conditions' do
    Post.filter do
      with :permalink, 'blog-post'
      with :blog_id, 3
    end.inspect
    Post.last_find.should == { :readonly => false, :conditions => [%q{("posts".permalink = ?) AND ("posts".blog_id = ?)}, 'blog-post', 3] }
  end

  it 'should filter by comparison operators' do
    [[:greater_than, :gt, '>'], [:less_than, :lt, '<'], 
     [:less_than_or_equal_to, :lte, '<='], [:greater_than_or_equal_to, :gte, '>=']].each do |set|
       Post.filter do
         with(:created_at).send(set[0], Time.parse('2009-01-03 23:02:00'))
       end.inspect
       Post.last_find.should == { :readonly => false, :conditions => ["\"posts\".created_at #{set[2]} ?", Time.parse('2009-01-03 23:02:00')] }

       Post.filter do
         with(:id).send(set[0], nil)
       end.inspect
       Post.last_find.should == { :readonly => false, :conditions => ["\"posts\".id #{set[2]} NULL"] }

       Post.filter do
         with(:created_at).send(set[1], Time.parse('2009-01-03 23:02:00'))
       end.inspect
       Post.last_find.should == { :readonly => false, :conditions => ["\"posts\".created_at #{set[2]} ?", Time.parse('2009-01-03 23:02:00')] }

       Post.filter do
         with(:created_at).not.send(set[0], Time.parse('2009-02-02 02:22:22'))
       end.inspect
       Post.last_find.should == { :readonly => false, :conditions => ["NOT (\"posts\".created_at #{set[2]} ?)", Time.parse('2009-02-02 02:22:22')] }
     end
  end

  it 'should create an IS NULL restriction when passing nil as the value to equal_to' do
    Post.filter do
      with(:blog_id).equal_to(nil)
    end.inspect
    Post.last_find.should == { :readonly => false, :conditions => [%q("posts".blog_id IS NULL)] }
  end

  it 'should filter for in' do
    Post.filter do
      with(:blog_id).in [1, 3, 5]
    end.inspect
    Post.last_find.should == { :readonly => false, :conditions => [%q{"posts".blog_id IN (?)}, [1, 3, 5]] }
  end

  it 'should negate IN filters correctly' do
    Post.filter do
      with(:blog_id).not.in [1, 3, 5]
    end.inspect
    Post.last_find.should == { :readonly => false, :conditions => [%q{"posts".blog_id NOT IN (?)}, [1, 3, 5]] }
  end

  it 'should work correctly for NOT IN' do
    Post.filter do
      with(:blog_id).not_in [1, 3, 5]
    end.inspect
    Post.last_find.should == { :readonly => false, :conditions => [%q{"posts".blog_id NOT IN (?)}, [1, 3, 5]] }
  end

  it 'should do the right thing for IN filters with empty arrays' do
    Post.filter do
      with(:blog_id).in([])
    end.inspect
    Post.last_find.should == { :readonly => false, :conditions => [%q("posts".blog_id IN (?)), []] }
  end

  it 'should do the right thing for IN filters with single values' do
    Post.filter do
      with(:blog_id).in(1)
    end.inspect
    Post.last_find.should == { :readonly => false, :conditions => [%q("posts".blog_id IN (?)), 1] }
  end

  it 'should do the right thing for IN filters with nil' do
    Post.filter do
      with(:blog_id).in(nil)
    end.inspect
    Post.last_find.should == { :readonly => false, :conditions => [%q("posts".blog_id IN (?)), nil] }
  end

  it 'should do the right thing for IN filters with a range' do
    Post.filter do
      with(:blog_id).in(1..5)
    end.inspect
    Post.last_find.should == { :readonly => false, :conditions => [%q("posts".blog_id IN (?)), 1..5] }
  end

  it 'should negate is_not_null conditions correctly' do
    Post.filter do
      with(:blog_id).is_not_null.not
    end.inspect
    Post.last_find.should == { :readonly => false, :conditions => [%q("posts".blog_id IS NULL)] }
  end 
  
  it 'should double-negate correctly' do
    Post.filter do
      with(:blog_id, 3).not.not
    end.inspect
    Post.last_find.should == { :readonly => false, :conditions => [%q("posts".blog_id = ?), 3] }
  end

  it 'should filter for between' do
    time1 = Time.parse('2008-01-03 23:23:00')
    time2 = Time.parse('2008-01-03 23:36:00')
    Post.filter do
      with(:created_at).between time1..time2
    end.inspect
    Post.last_find.should == { :readonly => false, :conditions => [%q{"posts".created_at BETWEEN ? AND ?}, time1, time2] }
  end

  it 'should filter for between with two arguments passed' do
    Post.filter do
      with(:id).between(1, 5)
    end.inspect
    Post.last_find.should == { :readonly => false, :conditions => [%q("posts".id BETWEEN ? AND ?), 1, 5] }
  end

  it 'should filter for between with an array passed' do
    Post.filter do
      with(:id).between([2, 6])
    end.inspect
    Post.last_find.should == { :readonly => false, :conditions => [%q("posts".id BETWEEN ? AND ?), 2, 6] }
  end

  it 'should filter by none_of' do
    Post.filter do
      none_of do
        with(:blog_id, 1)
        with(:permalink, 'eek')
      end
    end.inspect
    Post.last_find.should == { :readonly => false, :conditions => [%q{NOT (("posts".blog_id = ?) OR ("posts".permalink = ?))}, 1, 'eek'] }
  end

  it 'should filter by not_all_of' do
    Post.filter do
      not_all_of do
        with(:blog_id, 1)
        with(:permalink, 'eek')
      end
    end.inspect
    Post.last_find.should == { :readonly => false, :conditions => [%q{NOT (("posts".blog_id = ?) AND ("posts".permalink = ?))}, 1, 'eek'] }
  end

  it 'should filter by disjunction' do
    Post.filter do
      any_of do
        with(:blog_id).equal_to 1
        with(:permalink).equal_to 'my-post'
      end
    end.inspect
    Post.last_find.should == { :readonly => false, :conditions => [%q{("posts".blog_id = ?) OR ("posts".permalink = ?)}, 1, 'my-post'] }
  end

  it 'should filter by disjunction composed of conjunction' do
    Post.filter do
      any_of do
        all_of do
          with(:blog_id).equal_to 1
          with(:permalink).equal_to 'my-post'
        end
        with(:permalink).equal_to 'another-post'
      end
    end.inspect

    Post.last_find.should == { :readonly => false, :conditions => [%q{(("posts".blog_id = ?) AND ("posts".permalink = ?)) OR ("posts".permalink = ?)},
                                                                  1, 'my-post', 'another-post'] }
  end

  it 'should filter for nil' do
    [:is_null, :null, :nil].each do |method|
      Post.filter do
        with(:permalink).send(method)
      end.inspect
      Post.last_find.should == { :readonly => false, :conditions => [%q("posts".permalink IS NULL)] }
    end
  end

  it 'should filter for is_not_null' do
    Post.filter do
      with(:permalink).is_not_null
    end.inspect
    Post.last_find.should == { :readonly => false, :conditions => [%q("posts".permalink IS NOT NULL)] }
  end

  it 'should support like' do
    Post.filter do
      with(:permalink).like('%piglets%')
    end.inspect
    Post.last_find.should == { :readonly => false, :conditions => [%q("posts".permalink LIKE ?), '%piglets%'] }
  end

  it 'should support NOT LIKE' do
    Post.filter do
      with(:permalink).not.like('%ostriches%')
    end.inspect
    Post.last_find.should == { :readonly => false, :conditions => [%q("posts".permalink NOT LIKE ?), '%ostriches%'] }
  end

  it 'should provide access to the filter class in the filter' do
    Post.filter do
      with(:permalink).not.equal_to(filter_class.name)
    end.inspect
    Post.last_find.should == { :readonly => false, :conditions => [%q("posts".permalink <> ?), 'Post'] }
  end

  it 'should work correctly for one-line ORs with is_null' do
    Post.filter do
      with(:permalink, 'abc').or.is_null
    end.inspect
    Post.last_find.should == { :readonly => false, :conditions => [%q(("posts".permalink = ?) OR ("posts".permalink IS NULL)), 'abc'] }
  end

  it 'should work correctly for one-line ANDs with is_null' do
    Post.filter do
      with(:id).gt(56).and.lt(200)
    end.inspect
    Post.last_find.should == { :readonly => false, :conditions => [%q(("posts".id > ?) AND ("posts".id < ?)), 56, 200] }
  end

  it 'should work properly with multiple one-line conjunctions' do
    Post.filter do
      with(:id).gt(56).and.lt(200).or.gt(500).or.lt(15)
    end.inspect
    Post.last_find.should == { :readonly => false, :conditions => [%q(("posts".id > ?) AND (("posts".id < ?) OR (("posts".id > ?) OR ("posts".id < ?)))), 56, 200, 500, 15] } 
  end

  it 'should properly filter when filter is applied to an association' do
    Post.create
    Post.first.comments.filter do
      with(:offensive, true)
    end.inspect
    Comment.last_find.should == { :readonly => false, :conditions => "(\"comments\".offensive = 't') AND (\"comments\".post_id = #{Post.first.id})" }
  end

  it 'should allow a hash as the value for the restriction and use that as the name of a table' do
    Blog.filter do
      having(:comments)
      with(:created_at).gt(:comments => :created_at)
    end.inspect
    Blog.last_find[:conditions].should == [%q(("blogs".created_at > blogs__posts__comments.created_at))]
  end

  it 'should allow a hash as the value for the restriction and use that as the name of a table alias' do
    Blog.filter do
      having(:comments, :alias => 'cmts')
      with(:created_at).gt('cmts' => :created_at)
    end.inspect
    Blog.last_find[:conditions].should == [%q(("blogs".created_at > cmts.created_at))]
  end
end
