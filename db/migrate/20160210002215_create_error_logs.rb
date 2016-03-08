class CreateErrorLogs < ActiveRecord::Migration
  def up
    create_table 		:error_logs do |t|
    	t.string					:file
    	t.string					:function
    	t.string					:error

    	t.timestamps
    end
  end

  def down
  	drop_table :error_logs
  end
end
