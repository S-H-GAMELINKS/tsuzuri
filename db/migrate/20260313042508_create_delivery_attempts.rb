class CreateDeliveryAttempts < ActiveRecord::Migration[8.1]
  def change
    create_table :delivery_attempts do |t|
      t.references :outbound_activity, null: false, foreign_key: true
      t.string :inbox_url, null: false
      t.integer :response_status
      t.text :response_body
      t.boolean :success, null: false, default: false
      t.text :error_message
      t.timestamps
    end
  end
end
