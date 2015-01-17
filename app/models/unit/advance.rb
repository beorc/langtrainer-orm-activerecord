class Unit::Advance < ActiveRecord::Base
  BOXES_NUMBER = 5
  BOXES_PROBABILITIES = [60, 25, 10, 8, 2]
  validates :user, :unit, :language_id, :native_language_id, presence: true
  validates :unit, uniqueness: { scope: [:user_id, :language_id, :native_language_id] }

  belongs_to :user
  belongs_to :unit
  has_many :snapshots, class_name: 'Unit::AdvanceSnapshot', foreign_key: :unit_advance_id, dependent: :destroy

  serialize :steps, Array

  BOXES_NUMBER.times do |i|
    serialize "box_#{i}".to_sym, Array
  end

  before_create :ensure_steps
  before_create :init_boxes

  def language
    Language.find(language_id)
  end

  def native_language
    Language.find(native_language_id)
  end

  def step_passed!
    increment!(:steps_passed)
  end

  def word_helped!
    increment!(:words_helped)
  end

  def step_helped!
    increment!(:steps_helped)
  end

  def right_answer!
    increment!(:right_answers)
  end

  def wrong_answer!
    increment!(:wrong_answers)
  end

  def revised!
    update_attribute(:revised, true)
  end

  def step_revised!
    increment!(:revised_steps_number)
  end

  def advance!
    increment!(:current_step)
  end

  def fetch_step
    if revised?
      fetch_step_from_boxes
    else
      fetch_regular_step
    end
  end

  def create_snapshot!
    snapshots.where('date >= ?', DateTime.current.beginning_of_day).destroy_all
    snapshots.create! do |s|
      s.date = DateTime.current
      s.snapshot = {
        steps_passed: steps_passed,
        words_helped: words_helped,
        steps_helped: steps_helped,
        right_answers: right_answers,
        wrong_answers: wrong_answers
      }
    end
  end

  private

  def fetch_step_from_boxes
    rand = rand(0..100)

    threshold = 0
    step_id = nil
    max_step_number = steps.count - 1

    BOXES_NUMBER.times do |i|
      box_probability = BOXES_PROBABILITIES[i]
      steps = send("box_#{i}".to_sym)
      threshold += box_probability
      if steps.any?
        if rand <= threshold
          step_id = steps[rand(0..max_step_number)]
          break
        end
      end
    end

    if step_id.nil?
      BOXES_NUMBER.times do |i|
        steps = send("box_#{i}".to_sym)
        if steps.any?
          step_id = steps[rand(0..max_step_number)]
          break
        end
      end
    end

    Step.find(step_id)
  end

  def fetch_regular_step
    return if steps.count == current_step
    Step.find(steps[current_step])
  end

  def ensure_steps
    return steps if steps.present?

    steps_units = unit
      .steps_units
      .from_language(language)
      .to_language(native_language)

    steps_units = unit.random_steps_order? ? steps_units.shuffled : steps_units.ordered
    self.steps = steps_units.pluck(:step_id)
    steps
  end

  def init_boxes
    self.box_0 = ensure_steps
  end
end
