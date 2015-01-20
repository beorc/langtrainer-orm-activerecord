class CreateTrainings < ActiveRecord::Migration
  def change
    create_table :trainings do |t|
      t.references :user, index: true
      t.references :unit, index: true
      t.integer :language_id, null: false
      t.integer :native_language_id, null: false
      t.integer :steps_passed, default: 0
      t.integer :words_helped, default: 0
      t.integer :steps_helped, default: 0
      t.integer :right_answers, default: 0
      t.integer :wrong_answers, default: 0
      t.text :steps
      t.text :box_0
      t.text :box_1
      t.text :box_2
      t.text :box_3
      t.text :box_4
      t.integer :current_step, default: 0
      t.boolean :revised, default: false
      t.integer :revised_steps_number, default: 0

      t.timestamps null: false

      t.index [:unit_id, :user_id, :language_id, :native_language_id], unique: true, name: :training_uniqueness
    end
    add_foreign_key :trainings, :users
    add_foreign_key :trainings, :units
  end
end
