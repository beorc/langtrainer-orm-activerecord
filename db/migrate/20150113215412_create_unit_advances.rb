class CreateUnitAdvances < ActiveRecord::Migration
  def change
    create_table :unit_advances do |t|
      t.references :user, index: true, null: false
      t.references :unit, index: true, null: false
      t.integer :language, null: false
      t.integer :native_language, null: false
      t.integer :steps_passed, default: 0
      t.integer :words_helped, default: 0
      t.integer :steps_helped, default: 0
      t.integer :right_answers, default: 0
      t.integer :wrong_answers, default: 0
      t.text :steps
      t.text :box_1
      t.text :box_2
      t.text :box_3
      t.text :box_4
      t.text :box_5
      t.integer :current_step, default: 0
      t.boolean :revised, default: false
      t.integer :revised_steps_number, default: 0

      t.timestamps
    end
    add_foreign_key :unit_advances, :users
    add_foreign_key :unit_advances, :units
  end
end
