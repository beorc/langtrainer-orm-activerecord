class Unit < ActiveRecord::Base
  validates :slug, :course, presence: true
  validates :slug, uniqueness: { scope: :course_id }

  belongs_to :course
  has_many :steps_units, dependent: :destroy
  has_many :steps, through: :steps_units
  has_many :trainings, dependent: :destroy

  scope :published, -> { where(published: true) }

  def to_s
    "#{course.to_s}: #{slug}"
  end
end

