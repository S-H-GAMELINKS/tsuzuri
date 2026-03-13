class CreateKnownServers < ActiveRecord::Migration[8.1]
  def change
    create_table :known_servers do |t|
      t.string :domain, null: false
      t.string :shared_inbox_url
      t.datetime :last_seen_at
      t.boolean :reachable, null: false, default: true
      t.timestamps
    end

    add_index :known_servers, :domain, unique: true
  end
end
