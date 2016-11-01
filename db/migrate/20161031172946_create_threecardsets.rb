class CreateThreecardsets < ActiveRecord::Migration
  def change
    create_table :threecardsets do |t|
      t.integer :player_id
      t.integer :seconds_to_find

      t.timestamps null: false
    end
  end
end
