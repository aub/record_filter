require File.join(File.dirname(__FILE__), 'spec_helper')

require 'ruby-debug'

@blog = Class.new(Blog)
@blog.named_filter :somethings do
  having(:ads) do
    with(:content, nil)
  end
  join(Post, :left) do
    on(:id => :blog_id)
    join(Comment, :inner) do
      on(:id => :post_id)
      on(:offensive, true)
    end
  end
  group_by(:id)
end

10000.times do
  @blog.somethings
end

