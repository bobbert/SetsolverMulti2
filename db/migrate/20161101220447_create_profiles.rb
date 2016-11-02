class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.integer :user_id
      t.integer :games_played, :default => 0
      t.integer :wins, :default => 0
      t.integer :losses, :default => 0

      t.timestamps null: false
    end
  end
end
