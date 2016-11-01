class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer :selection_count
      t.string :name
      t.datetime :last_played_at
      t.datetime :started_at
      t.datetime :finished_at

      t.timestamps null: false
    end
  end
end
