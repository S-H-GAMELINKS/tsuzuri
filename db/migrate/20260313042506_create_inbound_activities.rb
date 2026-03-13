class CreateInboundActivities < ActiveRecord::Migration[8.1]
  def change
    create_table :inbound_activities do |t|
      t.references :remote_actor, foreign_key: true
      t.string :activity_id
      t.string :activity_type, null: false
      t.text :raw_json, null: false
      t.boolean :signature_verified, null: false, default: false
      t.string :status, null: false, default: "pending"
      t.text :error_message
      t.timestamps
    end

    add_index :inbound_activities, :status
    add_index :inbound_activities, :activity_type
  end
end
