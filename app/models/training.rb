class Training < ActiveRecord::Base
  BOXES_NUMBER = 5
  BOXES_PROBABILITIES = [60, 25, 10, 8, 2]
  validates :user, :unit, :current_step_id, :language_id, :native_language_id, presence: true
  validates :unit, uniqueness: { scope: [:user_id, :language_id, :native_language_id] }

  belongs_to :user
  belongs_to :unit
  belongs_to :current_step, class_name: 'Step'
  has_many :snapshots, class_name: 'Training::Snapshot', dependent: :destroy

  scope :for_unit, -> (unit) { where(unit: unit) }

  before_create :ensure_boxes

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
    current_step.right_answer?(language.slug, answer)
  end

  def push_current_step_to_first_box!
    each_box_number do |i|
      step_number = step_ids_from_box(i).delete(current_step_id)
      if step_number
        step_ids_from_box(0).push(step_number)
        save!
        break
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
          break
        end
      end
    end
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

  def step_revised!
    increment!(:revised_steps_number)
  end

  def fetch_step!
    rand = rand(0..100)

    threshold = 0
    each_box_number do |i|
      box_probability = BOXES_PROBABILITIES[i]
      step_ids = step_ids_from_box(i)
      threshold += box_probability
      if step_ids.any?
        if rand <= threshold
          max_step_number = step_ids.count - 1
          self.current_step_id = step_ids[rand(0..max_step_number)]
          break
        end
      end
    end

    if current_step_id.nil?
      each_box_number do |i|
        step_ids = step_ids_from_box(i)
        if step_ids.any?
          max_step_number = step_ids.count - 1
          self.current_step_id = step_ids[rand(0..max_step_number)]
          break
        end
      end
    end

    save!
    current_step
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

  def ensure_boxes
    return if box_0.present?

    reserved_step = unit.steps.first

    steps_units = unit
      .steps_units
      .from_language(language)
      .to_language(native_language)

    steps_units = unit.random_steps_order? ? steps_units.shuffled : steps_units.ordered
    step_ids = steps_units.pluck(:step_id)

    step_ids.delete reserved_step.id
    step_ids.unshift reserved_step.id

    self.box_0 = step_ids
    self.current_step_id = step_ids.first
  end

  private

  def step_ids_from_box(number)
    attr_name = "box_#{number}"

    if respond_to?(attr_name)
      return send(attr_name)
    else
      return []
    end
  end
end
