class StepsBoxes < ActiveRecord::Base
  validates :box, :step, presence: true
  validates :step_id, uniqueness: { scope: :box_id }

  belongs_to :box
  belongs_to :step
end


