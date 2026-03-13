class CreateFollowers < ActiveRecord::Migration[8.1]
  def change
    create_table :followers do |t|
      t.references :remote_actor, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.string :follow_activity_id, null: false
      t.string :state, null: false, default: "active"
      t.datetime :undone_at
      t.timestamps
    end

    add_index :followers, :follow_activity_id, unique: true
    add_index :followers, :state
  end
end
