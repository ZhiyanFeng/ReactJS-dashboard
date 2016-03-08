class AddRequireApprovalToChannels < ActiveRecord::Migration
  def self.up
    add_column        :channels,  :shift_trade_require_approval, :boolean, :default => false
  end

  def self.down
    remove_column     :channels,  :shift_trade_require_approval
  end
end
