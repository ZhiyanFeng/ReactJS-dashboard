class CreateSources < ActiveRecord::Migration
  def self.up
  	create_table :sources do |t|
  		t.string    :table_name
      t.boolean   :is_valid,     default: true

      t.timestamps
    end
  end

  def self.down
  	drop_table :sources
  end
end
