class CreateRemoteActors < ActiveRecord::Migration[8.1]
  def change
    create_table :remote_actors do |t|
      t.string :actor_uri, null: false
      t.string :inbox_url, null: false
      t.string :shared_inbox_url
      t.string :preferred_username
      t.string :display_name
      t.text :public_key_pem
      t.string :public_key_id
      t.string :domain, null: false
      t.timestamps
    end

    add_index :remote_actors, :actor_uri, unique: true
    add_index :remote_actors, :domain
  end
end
