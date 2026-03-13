class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.references :account, null: false, foreign_key: true
      t.string :title, null: false
      t.string :slug, null: false
      t.text :plaintext_body, null: false
      t.text :html_body, null: false
      t.string :state, null: false, default: "draft"
      t.datetime :published_at
      t.string :activity_pub_object_uri
      t.string :activity_pub_create_activity_uri
      t.string :activity_pub_delete_activity_uri
      t.timestamps
    end

    add_index :posts, :slug, unique: true
    add_index :posts, :state
  end
end
