class Training < ActiveRecord::Base
  BOXES_NUMBER = 5
  BOXES_PROBABILITIES = [60, 25, 10, 8, 2]
  validates :user, :unit, :language_id, :native_language_id, presence: true
  validates :unit, uniqueness: { scope: [:user_id, :language_id, :native_language_id] }

  belongs_to :user
  belongs_to :unit
  has_many :snapshots, class_name: 'Training::Snapshot', dependent: :destroy

  serialize :steps, Array

  before_create :ensure_steps

  def self.each_box_number
    BOXES_NUMBER.times do |i|
      yield i
    end
  end

  delegate :each_box_number, to: :class

  each_box_number do |i|
    serialize "box_#{i}".to_sym, Array
  end

  def push_current_step_to_first_box!
    current_step_id = fetch_current_step.id
    each_box_number do |i|
      step_number = steps_from_box(i).delete(current_step_id)
      if step_number
        steps_from_box(0).push(step_number)
        save!
      end
    end
  end

  def push_current_step_to_next_box!
    current_step_id = fetch_current_step.id
    each_box_number do |i|
      next_box_number = i + 1
      if next_box_number < BOXES_NUMBER
        step_number = steps_from_box(i).delete(current_step_id)
        if step_number
          steps_from_box(next_box_number).push(step_number)
          save!
        end
      end
    end
  end

  def fetch_current_step
    Step.find(steps[current_step])
  end

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
    revised! if steps.count == current_step
  end

  def fetch_step
    if revised?
      fetch_step_from_boxes
    else
      fetch_current_step
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

    each_box_number do |i|
      box_probability = BOXES_PROBABILITIES[i]
      steps = steps_from_box(i)
      threshold += box_probability
      if steps.any?
        if rand <= threshold
          step_id = steps[rand(0..max_step_number)]
          break
        end
      end
    end

    if step_id.nil?
      each_box_number do |i|
        steps = steps_from_box(i)
        if steps.any?
          step_id = steps[rand(0..max_step_number)]
          break
        end
      end
    end

    Step.find(step_id)
  end

  def ensure_steps
    return steps if steps.present?

    steps_units = unit
      .steps_units
      .from_language(language)
      .to_language(native_language)

    steps_units = unit.random_steps_order? ? steps_units.shuffled : steps_units.ordered
    self.steps = steps_units.pluck(:step_id)
    self.box_0 = self.steps
    steps
  end

  def steps_from_box(number)
    attr_name = "box_#{number}"

    if respond_to?(attr_name)
      return send(attr_name)
    else
      return []
    end
  end
end
