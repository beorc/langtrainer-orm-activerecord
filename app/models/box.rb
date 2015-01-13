class Box < ActiveRecord::Base
  belongs_to :unit_advance
  has_many :steps_boxes, dependent: :destroy
  has_many :steps, through: :steps_boxes

  validates :unit_advance, presence: true

  scope :ordered_by_number, -> { order(:number) }
  scope :for_number, ->(number) { where(number: number) }
  scope :with_step, ->(step) { joins(:steps).where('steps_boxes.step_id = ?', step.id) }

  def random_step
    steps[rand(0..steps.count)]
  end

  def next_box
    unit_advance.boxes.find_by(number: number + 1)
  end

  def first_box
    unit_advance.boxes.find_by(number: number + 1)
  end
end

