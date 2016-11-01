class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.integer :cardface_id
      t.integer :deck_id
      t.integer :facedown_position
      t.integer :faceup_position
      t.integer :threecardset_id

      t.timestamps null: false
    end
  end
end
