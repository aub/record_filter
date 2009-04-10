class Comment < ActiveRecord::Base
  extend TestModel

  belongs_to :post
end
