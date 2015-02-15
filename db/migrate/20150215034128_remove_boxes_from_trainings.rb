class RemoveBoxesFromTrainings < ActiveRecord::Migration
  def change
    5.times do |i|
      remove_column :trainings, "box_#{i}".to_sym
    end
  end
end
