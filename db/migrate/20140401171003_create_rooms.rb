class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.string :name
      t.string :sessionId
      t.boolean :public
      t.string :nowy
      t.timestamps
    end
  end
end
