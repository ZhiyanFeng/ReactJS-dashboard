class CreateGratitudes < ActiveRecord::Migration
  def up
    create_table    :gratitudes do |t|
      t.integer  :owner_id,     null: false
      t.integer  :source,       null: false
      t.integer  :source_id,    null: false
      t.decimal  :amount
      t.boolean  :is_valid,     default: true

      t.timestamps
    end
  end

  def down
    drop_table :gratitudes
  end
end
