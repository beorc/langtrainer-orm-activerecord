require 'timeout'

class Training < ActiveRecord::Base
  BOXES_NUMBER = 5
  BOXES_PROBABILITIES = [60, 25, 10, 8, 2]
  DIFFICULTY_INDEX_THRESHOLD = 0.1

  validates :user, :unit, :current_step_id, :language_id, :native_language_id, presence: true
  validates :unit, uniqueness: { scope: [:user_id, :language_id, :native_language_id] }

  belongs_to :user
  belongs_to :unit
  belongs_to :current_step, class_name: 'Step'

  scope :for_unit, -> (unit) { where(unit: unit) }

  before_create :ensure_schedule
  before_save :ensure_snapshot

  serialize :snapshots, Hash
  serialize :schedule, Hash

  def self.each_box_number
    BOXES_NUMBER.times do |i|
      yield i
    end
  end

  def reverse_each_box_number
    BOXES_NUMBER.times do |i|
      yield(BOXES_NUMBER - i - 1)
    end
  end

  delegate :each_box_number, to: :class

  attr_accessor :difficulty_index

  def right_answer?(answer)
    current_step.right_answer?(language.slug, answer)
  end

  def reschedule
    schedule.keys.each do |step_id|
      self.schedule[step_id][:box] = 0
    end
  end

  def reschedule!
    reschedule
    save!
  end

  def push_current_step_to_first_box!
    schedule[current_step_id] ||= {}
    schedule[current_step_id][:box] = unit.random_steps_order? ? 0 : 1
    save!
  end

  def push_current_step_to_next_box!
    next_box_number = schedule[current_step_id][:box] + 1

    if next_box_number < BOXES_NUMBER
      self.schedule[current_step_id][:box] = next_box_number
      save!
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
    if difficulty_index.to_f < DIFFICULTY_INDEX_THRESHOLD
      push_current_step_to_next_box!
    end

    increment!(:right_answers)
  end

  def wrong_answer!
    push_current_step_to_first_box!
    increment!(:wrong_answers)
  end

  def step_revised!
    increment!(:revised_steps_number)
  end

  def fetch_step!
    step_id = nil

    if unit.random_steps_order?
      step_id = fetch_random_step
    else
      step_ids = step_ids_from_box(0)
      step_ids.delete current_step_id

      if step_ids.any?
        step_id = fetch_nonrandom_step
      else
        step_id = fetch_random_step
      end
    end

    step_id ||= fetch_fallback_step

    self.current_step_id = step_id

    save!
    current_step
  end

  def ensure_snapshot
    snapshots[Date.today] = {
      steps_passed: steps_passed,
      words_helped: words_helped,
      steps_helped: steps_helped,
      right_answers: right_answers,
      wrong_answers: wrong_answers
    }
  end

  def ensure_schedule
    return if schedule.present?

    reserved_step = unit.steps.first

    steps_units = unit
      .steps_units
      .from_language(language)
      .to_language(native_language)

    steps_units = steps_units.ordered
    step_ids = steps_units.pluck(:step_id)

    step_ids.delete reserved_step.id
    step_ids.unshift reserved_step.id

    step_ids.each do |step_id|
      self.schedule[step_id] = { box: 0 }
    end
    self.current_step_id = step_ids.first
  end

  def schedule_new_steps!
    existing_step_ids = schedule.keys

    steps_units = unit
      .steps_units
      .from_language(language)
      .to_language(native_language)

    steps_units = steps_units.ordered
    step_ids = steps_units.where.not(step_id: existing_step_ids).pluck(:step_id)

    step_ids.each do |step_id|
      self.schedule[step_id] = { box: 0 }
    end

    self.save!
  end

  def to_s
    "#{user.to_s}: #{unit.to_s}"
  end

  private

  def fetch_random_step
    step_id = nil
    rand = rand(0..100)

    reverse_each_box_number do |i|
      box_probability = BOXES_PROBABILITIES[i]
      if rand <= box_probability

        step_ids = step_ids_from_box(i)
        step_ids.delete current_step_id

        if step_ids.any?
          max_step_number = step_ids.count - 1
          step_id = step_ids[rand(0..max_step_number)]
          break
        end
      end
    end

    step_id
  end

  def fetch_nonrandom_step
    step_ids = schedule.keys
    i = step_ids.index current_step_id
    step_ids.delete current_step_id
    step_id = step_ids[i]

    step_id ||= step_ids_from_box(0).first

    step_id
  end

  def fetch_fallback_step
    step_id = nil

    each_box_number do |i|

      step_ids = step_ids_from_box(i)
      step_ids.delete current_step_id

      if step_ids.any?
        max_step_number = step_ids.count - 1
        step_id = step_ids[rand(0..max_step_number)]

        if i == BOXES_NUMBER - 1
          reschedule
        end

        break
      end
    end

    step_id
  end

  def step_ids_from_box(number)
    schedule.select { |k, v| v[:box] == number }.keys
  end
end
