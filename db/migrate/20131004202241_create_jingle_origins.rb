class CreateJingleOrigins < ActiveRecord::Migration
  def change
    create_table :jingle_origins do |t|
      t.integer  :parent_id
      t.integer  :jingle_id
      t.float    :offset, default: 0, null: false
      t.timestamps
    end
  end
end
