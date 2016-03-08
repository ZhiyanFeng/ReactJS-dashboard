class AdminClaim < ActiveRecord::Base
  attr_accessible :user_id,
    :ref_type,
    :ref_id,
    :email,
    :activation_code,
    :is_active,
    :is_valid

end
