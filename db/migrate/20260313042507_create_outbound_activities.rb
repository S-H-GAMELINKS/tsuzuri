class CreateOutboundActivities < ActiveRecord::Migration[8.1]
  def change
    create_table :outbound_activities do |t|
      t.references :post, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.string :activity_type, null: false
      t.string :activity_uri, null: false
      t.text :payload_json, null: false
      t.string :status, null: false, default: "pending"
      t.timestamps
    end

    add_index :outbound_activities, :activity_uri, unique: true
    add_index :outbound_activities, :status
  end
end
