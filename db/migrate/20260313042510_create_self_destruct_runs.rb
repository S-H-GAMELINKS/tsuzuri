class CreateSelfDestructRuns < ActiveRecord::Migration[8.1]
  def change
    create_table :self_destruct_runs do |t|
      t.string :state, null: false, default: "pending"
      t.datetime :read_only_at
      t.datetime :started_at
      t.datetime :completed_at
      t.integer :total_activities, null: false, default: 0
      t.integer :delivered_activities, null: false, default: 0
      t.integer :failed_activities, null: false, default: 0
      t.string :confirmation_token
      t.timestamps
    end
  end
end
