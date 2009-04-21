class Review < ActiveRecord::Base
  extend TestModel

  belongs_to :reviewable, :polymorphic => true
end
