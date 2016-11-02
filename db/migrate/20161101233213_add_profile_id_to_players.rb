class AddProfileIdToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :profile_id, :integer
  end
end
