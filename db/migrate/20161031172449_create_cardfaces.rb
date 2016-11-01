class CreateCardfaces < ActiveRecord::Migration
  def change
    create_table :cardfaces do |t|
      t.integer :number
      t.text :color, :limit => 10
      t.text :shading, :limit => 10
      t.text :shape, :limit => 10

      t.timestamps null: false
    end
  end
end
