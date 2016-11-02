class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer :selection_count
      t.string :name
      t.datetime :started_at
      t.datetime :paused_at
      t.datetime :resumed_at
      t.datetime :finished_at

      t.timestamps null: false
    end
  end
end
