class AddSwiftCodeToLocations < ActiveRecord::Migration
  def self.up
    add_column        :locations,  :swift_code,   :string
  end

  def self.down
    remove_column     :locations,  :swift_code
  end
end
