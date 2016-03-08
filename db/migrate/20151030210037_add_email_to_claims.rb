class AddEmailToClaims < ActiveRecord::Migration
  def self.up
    add_column        :claims,  :claim_id,            :string
    add_column 				:claims,	:email,								:string
    add_column 				:claims,	:verification_code,		:string
    add_column 				:claims,	:verified,						:boolean
  end

  def self.down
    remove_column     :claims,  :claim_id
  	remove_column 		:claims,	:email
  	remove_column 		:claims,	:verification_code
  	remove_column 		:claims,	:verified
  end
end
