class CreateJingleMerges < ActiveRecord::Migration
  def change
    create_table :jingle_merges do |t|
      t.integer  :child_jingle_id
      t.integer  :parent_jingle_id
      t.string   :child_type
      t.string   :parent_type
      t.integer  :state, default: 0, null: false
      t.string   :reason
      t.float    :parent_offset, default: 0, null: false
      t.float    :child_offset, default: 0, null: false
      t.datetime :merged_at
      
      t.timestamps
    end
  end
end
