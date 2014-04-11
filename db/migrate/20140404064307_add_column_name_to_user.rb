class AddColumnNameToUser < ActiveRecord::Migration
  def change
    add_column :users, :roomid, :integer
  end
end
