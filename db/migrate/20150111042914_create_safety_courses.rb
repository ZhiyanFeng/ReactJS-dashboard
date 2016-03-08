class CreateSafetyCourses < ActiveRecord::Migration
  def self.up
  	create_table :safety_courses do |t|
  		t.string   :title,      null: false
      t.string   :url,        null: false
      t.string   :icon,       null: false
      t.string   :size,       null: false
      t.string   :folder,     null: false
      t.string   :version,    null: false, limit: 10

      t.timestamps
    end
  end

  def self.down
  	drop_table :safety_courses
  end
end
