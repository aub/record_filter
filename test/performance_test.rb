require 'rubygems'
gem 'sqlite3-ruby'

require 'ruby-debug'

require File.join(File.dirname(__FILE__), '..', 'lib', 'record_filter')

module TestModel
end

require File.join(File.dirname(__FILE__), '..', 'spec', 'models')

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => File.join(File.dirname(__FILE__), '..', 'spec', 'test.db')
)

@blog = Class.new(Blog)
@blog.named_filter :somethings do
  having(:ads) do
    with(:content, nil)
    with(:id).greater_than(25)
  end
  join(Post, :left) do
    on(:id => :blog_id)
    join(Comment, :inner) do
      on(:id => :post_id)
      on(:offensive, true)
    end
  end
  group_by(:id)
  limit(10, 100)
  order(:ads => :id)
end

10000.times do
  @blog.somethings
end

