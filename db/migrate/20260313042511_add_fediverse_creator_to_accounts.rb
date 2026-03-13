class AddFediverseCreatorToAccounts < ActiveRecord::Migration[8.1]
  def change
    add_column :accounts, :fediverse_creator, :string
  end
end
