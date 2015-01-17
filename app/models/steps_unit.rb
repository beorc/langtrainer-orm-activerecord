class StepsUnit < ActiveRecord::Base
  validates :unit, :step, presence: true
  validates :step_id, uniqueness: { scope: :unit_id }

  belongs_to :unit
  belongs_to :step

  scope :for_course, ->(course_id) { joins(:unit).where(course_id: course_id) }
  scope :ordered, -> { order(:position) }

  def self.from_language(language)
    where("from_#{language.slug}" => true)
  end

  def self.to_language(language)
    where("to_#{language.slug}" => true)
  end

  def self.shuffled
    scoped.sample(count)
  end
end

