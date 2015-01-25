class Course < ActiveRecord::Base
  validates :slug, presence: true, uniqueness: true

  has_many :units
  has_many :steps_units, through: :units
  has_many :steps, through: :steps_units

  scope :published, -> { where(published: true) }
end
