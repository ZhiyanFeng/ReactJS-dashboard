class AddApproverIdToScheduleElements < ActiveRecord::Migration
  def self.up
    add_column      :schedule_elements,   :approver_id,    :integer
  end

  def self.down
    remove_column   :schedule_elements,   :approver_id
  end
end
