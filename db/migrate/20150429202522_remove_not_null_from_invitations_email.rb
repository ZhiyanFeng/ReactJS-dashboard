class RemoveNotNullFromInvitationsEmail < ActiveRecord::Migration
  def change
  	change_column :invitations, :email, :string, :null => true
  	change_column :users, :email, :string, :null => true
  end
end
