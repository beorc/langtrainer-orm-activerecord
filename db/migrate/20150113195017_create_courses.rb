class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :slug, null: false
      t.boolean :published, default: false

      t.timestamps

      t.index :slug, unique: true
      t.index :published
    end
  end
end
