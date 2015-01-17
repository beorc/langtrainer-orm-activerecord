class Unit::Advance < ActiveRecord::Base
  BOXES_NUMBER = 5
  BOXES_PROBABILITIES = [60, 25, 10, 8, 2]
  validates :user, :steps, :language_id, :native_language_id, presence: true
  validates :date, uniqueness: { scope: [:user_id, :unit_id, :language_id] }

  belongs_to :user
  belongs_to :unit
  has_many :snapshots, class_name: 'Unit::Snapshot', dependent: :destroy

  serialize :steps, Array

  BOXES_NUMBER.times do |i|
    serialize "box_#{i}".to_sym, Array
  end

  before_validation :ensure_steps, on: :create
  before_validation :init_boxes, on: :create

  def language
    Language.find(language_id)
  end

  def native_language
    Language.find(native_language_id)
  end

  def step_passed!
    self.steps_passed += 1
    save!
  end

  def word_helped!
    self.words_helped += 1
    save!
  end

  def step_helped!
    self.steps_helped += 1
    save!
  end

  def right_answer!
    self.right_answers += 1
    save!
  end

  def wrong_answer!
    self.wrong_answers += 1
    save!
  end

  def revised!
    update_attribute(:revised, true)
  end

  def step_revised!
    update_attribute(:revised_steps_number, revised_steps_number + 1)
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
    snapshots.where(date: Date.today).destroy!
    snapshots.create! do |s|
      s.date = DateTime.current
      s.snaphot = {
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
    step = nil

    BOXES_NUMBER.times do |i|
      box_probability = BOXES_PROBABILITIES[i]
      steps = send("box_#{i}".to_sym)
      threshold += box_probability
      if steps.any?
        if rand <= threshold
          step = steps[rand(0..steps.count)]
          break
        end
      end
    end

    if step.nil?
      BOXES_NUMBER.times do |i|
        steps = send("box_#{i}".to_sym)
        if steps.any?
          step = steps[rand(0..steps.count)]
          break
        end
      end
    end

    step
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
  end

  def init_boxes
    self.box_0 = steps
  end
end
