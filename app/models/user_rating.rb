class UserRating < ActiveRecord::Base
  has_one :rater, :class_name => "User", :foreign_key => "rater_id"
  has_one :ratee, :class_name => "User", :foreign_key => "ratee_id"

  attr_accessible :rater_id,
  :ratee_id,
  :rate_type,
  :rating,
  :comment,
  :is_valid

end
