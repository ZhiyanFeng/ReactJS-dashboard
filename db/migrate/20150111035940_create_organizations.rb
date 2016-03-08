class CreateOrganizations < ActiveRecord::Migration
  def self.up
  	create_table :organizations do |t|
      t.string  	:name, 								null: false
      t.string  	:unit_number,					limit: 20
      t.string  	:street_number, 			limit: 20
      t.string 		:address               #rename to street_address
      t.string 		:city, 								limit: 155
      t.string	 	:province,						limit: 155
      t.string		:postal,							limit: 64
      t.string		:country,							limit: 64
      t.string  	:status
      t.string  	:description
      t.integer 	:profile_id
      t.integer 	:cover_id
      t.boolean 	:secure_network, 			default: false
      t.boolean 	:validated, 					default: false
      t.string  	:validation_hash, 		null: false
			t.boolean 	:is_valid, 						default: true
			
      t.timestamps
    end
  end

  def self.down
  	drop_table :organizations
  end
end
