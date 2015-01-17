class Unit::AdvanceSnapshot < ActiveRecord::Base
  belongs_to :unit_advance, class_name: 'Unit::Advance'
  has_one :user, through: :unit_advance
  has_one :unit, through: :unit_advance
  has_one :course, through: :unit

  validates :unit_advance, :date, :snapshot, presence: true
  validates :date, uniqueness: { scope: :unit_advance_id }

  serialize :snapshot, Hash

  scope :with_user, ->(user) { joins(:unit_advance).where('unit_advances.user_id = ?', user.id) }
  scope :with_course, ->(course) { joins(:unit_advance).where('units.course_id = ?', course.id) }
  scope :with_unit, ->(unit) { joins(:unit_advance).where('unit_advances.unit_id = ?', unit.id) }
  scope :with_language, ->(language) { joins(:unit_advance).where('unit_advances.language_id = ?', language.id) }

  def self.table_name_prefix
    'unit_advance'
  end

  def self.with_period(period)
    case period.id
    when Period::OneDay
      where('date >= ?', DateTime.current.beginning_of_day)
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
end
