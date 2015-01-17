class CreateUnits < ActiveRecord::Migration
  def change
    create_table :units do |t|
      t.references :course, index: true
      t.string :slug, null: false
      t.boolean :published, default: false

      t.boolean :random_steps_order, default: false

      t.timestamps null: false

      t.index :slug, unique: true
      t.index :published
    end
    add_foreign_key :units, :courses
  end
end
