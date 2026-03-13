class AddActivityPubFieldsToAccounts < ActiveRecord::Migration[8.1]
  def change
    change_table :accounts do |t|
      t.string :username
      t.string :display_name
      t.text :summary
      t.text :private_key_pem, null: false
      t.text :public_key_pem, null: false
      t.string :activity_pub_url, null: false
      t.timestamps null: false, default: -> { "CURRENT_TIMESTAMP" }
    end

    add_index :accounts, :username, unique: true
  end
end
