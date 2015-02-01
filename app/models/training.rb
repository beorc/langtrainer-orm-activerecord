class Training < ActiveRecord::Base
  BOXES_NUMBER = 5
  BOXES_PROBABILITIES = [60, 25, 10, 8, 2]
  validates :user, :unit, :language_id, :native_language_id, presence: true
  validates :unit, uniqueness: { scope: [:user_id, :language_id, :native_language_id] }

  belongs_to :user
  belongs_to :unit
  has_many :snapshots, class_name: 'Training::Snapshot', dependent: :destroy

  serialize :step_ids, Array

  scope :for_unit, -> (unit) { where(unit: unit) }

  def self.each_box_number
    BOXES_NUMBER.times do |i|
      yield i
    end
  end

  delegate :each_box_number, to: :class

  each_box_number do |i|
    serialize "box_#{i}".to_sym, Array
  end

  def right_answer?(answer)
    fetch_current_step.right_answer?(language.slug, answer)
  end

  def push_current_step_to_first_box!
    each_box_number do |i|
      step_number = step_ids_from_box(i).delete(current_step_id)
      if step_number
        step_ids_from_box(0).push(step_number)
        save!
      end
    end
  end

  def push_current_step_to_next_box!
    each_box_number do |i|
      next_box_number = i + 1
      if next_box_number < BOXES_NUMBER
        step_number = step_ids_from_box(i).delete(current_step_id)
        if step_number
          step_ids_from_box(next_box_number).push(step_number)
          save!
        end
      end
    end
  end

  def fetch_current_step
    Step.find(current_step_id)
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
    index = step_ids.index(current_step_id)
    self.current_step_id = step_ids[index + 1]
    revised! unless current_step_id
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

  def ensure_step_ids
    return step_ids if step_ids.present?

    reserved_step = unit.steps.first

    steps_units = unit
      .steps_units
      .from_language(language)
      .to_language(native_language)

    steps_units = unit.random_steps_order? ? steps_units.shuffled : steps_units.ordered
    self.step_ids = steps_units.pluck(:step_id)

    self.step_ids.delete reserved_step.id
    self.step_ids.unshift reserved_step.id

    self.box_0 = self.step_ids
    self.current_step_id = step_ids.first
    step_ids
  end

  private

  def fetch_step_from_boxes
    rand = rand(0..100)

    threshold = 0
    max_step_number = self.step_ids.count - 1

    each_box_number do |i|
      box_probability = BOXES_PROBABILITIES[i]
      step_ids = step_ids_from_box(i)
      threshold += box_probability
      if step_ids.any?
        if rand <= threshold
          self.current_step_id = step_ids[rand(0..max_step_number)]
          break
        end
      end
    end

    if current_step_id.nil?
      each_box_number do |i|
        step_ids = step_ids_from_box(i)
        if step_ids.any?
          self.current_step_id = step_ids[rand(0..max_step_number)]
          break
        end
      end
    end

    fetch_current_step
  end

  def step_ids_from_box(number)
    attr_name = "box_#{number}"

    if respond_to?(attr_name)
      return send(attr_name)
    else
      return []
    end
  end
end
