class Unit < ActiveRecord::Base
  validates :slug, :course, presence: true
  validates :slug, uniqueness: { scope: :course_id }

  belongs_to :course
  has_many :steps_units, dependent: :destroy
  has_many :steps, through: :steps_units
  has_many :unit_advances, dependent: :destroy

  scope :published_only, -> { where(published: true) }
end

