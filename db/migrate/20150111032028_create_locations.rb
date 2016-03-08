class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
    	t.integer 	:org_id, 							null: false
      t.integer 	:owner_id, 						null: false, default: 0
    	t.integer  	:member_count,				default: 0
      t.string  	:location_name
      t.string  	:unit_number,					limit: 20
      t.string  	:street_number, 			limit: 20
      t.string 		:address, 				    null: false #rename to street_address
      t.string 		:city, 								limit: 155
      t.string	 	:province,						limit: 155
      t.string		:postal,							limit: 64
      t.string		:country,							limit: 64
      t.string  	:formatted_address
      t.string		:lng,									limit: 50
      t.string		:lat,									limit: 50
			t.boolean 	:is_valid, 						default: true

			t.timestamps
    end
  end

  def self.down
  	drop_table :locations
  end
end
