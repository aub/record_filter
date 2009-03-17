class Post < ActiveRecord::Base
  extend TestModel

  belongs_to :blog
end
