class ViralityAnalytic < ActiveRecord::Base
  attr_accessible	:sender_id,
    :sender_ccode,
    :phone_number,
    :first_name,
    :last_name,
    :send_method,
    :is_accepted,
    :last_contacted_at,
    :is_valid

end