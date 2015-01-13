class CreateUnits < ActiveRecord::Migration
  def change
    create_table :units do |t|
      t.references :course, index: true, null: false
      t.string :slug, null: false
      t.boolean :published, null: false

      t.boolean :random_steps_order, default: false

      t.timestamps

      t.index :slug, unique: true
      t.index :published
    end
    add_foreign_key :units, :courses
  end
end
