class CreateSmsStop < ActiveRecord::Migration
	def up
    create_table 		:sms_stops do |t|
    	t.string					:plivo_number
    	t.string					:stop_number

    	t.timestamps
    end
  end

  def down
  	drop_table :sms_stops
  end
end
