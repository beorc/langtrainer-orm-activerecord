class Training::Snapshot < ActiveRecord::Base
  belongs_to :training
  has_one :user, through: :training
  has_one :unit, through: :training
  has_one :course, through: :unit

  validates :training, :date, :snapshot, presence: true
  validates :date, uniqueness: { scope: :training_id }

  serialize :snapshot, Hash

  scope :with_user, ->(user) { joins(:training).where('trainings.user_id = ?', user.id) }
  scope :with_course, ->(course) { joins(:training).where('units.course_id = ?', course.id) }
  scope :with_unit, ->(unit) { joins(:training).where('trainings.unit_id = ?', unit.id) }
  scope :with_language, ->(language) { joins(:training).where('trainings.language_id = ?', language.id) }

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
