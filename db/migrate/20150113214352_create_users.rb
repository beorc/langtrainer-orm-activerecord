class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :token, null: false
      t.timestamps

      t.index :token, unique: true
    end
  end
end
