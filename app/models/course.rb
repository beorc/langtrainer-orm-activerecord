class Course < ActiveRecord::Base
  validates :slug, presence: true, uniqueness: true

  has_many :units
  has_many :steps_units, through: :units
  has_many :steps, through: :steps_units
  has_many :boxes

  scope :published_only, -> { where(published: true) }
end
