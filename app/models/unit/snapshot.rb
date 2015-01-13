class Unit::Snapshot < ActiveRecord::Base
  belongs_to :unit_advance
  has_one :unit, through: :unit_advance
  has_many :boxes, through: :unit_advance
  validates :unit_advance, :date, presence: true
  validates :date, uniqueness: { scope: :unit_advance_id }

  scope :with_user, ->(user) { joins(:unit_advances).where('unit_advances.user_id = ?', user.id) }
  scope :with_course, ->(course) { joins(:unit).where('units.course_id = ?', course.id) }
  scope :with_unit, ->(unit) { joins(:unit).where('units.id = ?', unit.id) }
  scope :with_language, ->(language) { joins(:unit_advances).where('unit_advances.language_id = ?', language.id) }

  def self.table_name_prefix
    'unit_'
  end

  def self.with_period(period)
    case period.id
    when Period::OneDay
      where('date = ?', Date.today)
    when Period::ThreeDays
      where('date >= ?', 3.days.ago)
    when Period::OneWeek
      where('date >= ?', 1.week.ago)
    when Period::OneMonth
      where('date >= ?', 1.month.ago)
    when Period::OneYear
      where('date >= ?', 1.year.ago)
    end
  end

  def self.boxes
    includes(:boxes)
  end
end
