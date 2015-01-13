class Unit::Advance < ActiveRecord::Base
  validates :steps, :language_id, :native_language_id, presence: true
  validates :date, uniqueness: { scope: [:user_id, :unit_id, :language_id] }
  validates :session_token, presence: true, unless: :user_id?
  validates :user_id, presence: true, unless: :session_token?

  belongs_to :user
  belongs_to :unit
  has_many :snapshots, class_name: 'Unit::Snapshot', dependent: :destroy

  serialize :steps, Array

  before_validation :ensure_steps
  after_create :init_boxes

  def self.languages
    pluck(:language_id).uniq.map { |id| Language.find(id) }
  end

  def self.generate_session_token
    loop do
      token = SecureRandom.base64(15).tr('+/=lIO0', 'pqrsxyz')
      break token if UnitAdvance.where(session_token: token).empty?
    end
  end

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
    snapshots.create!(date: Date.today,
                      steps_passed: steps_passed,
                      words_helped: words_helped,
                      steps_helped: steps_helped,
                      right_answers: right_answers,
                      wrong_answers: wrong_answers)
  end

  private

  def fetch_step_from_boxes
    rand = rand(0..100)

    threshold = 0
    step = nil

    boxes.ordered_by_number.each do |box|
      box_probability = Langtrainer2.config.boxes_probabilities[box.number]
      threshold += box_probability
      if box.steps.any?
        if rand <= threshold
          step = box.fetch_step
          break
        end
      end
    end

    if step.nil?
      boxes.ordered_by_number.each do |box|
        if box.steps.any?
          step = box.random_step
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
    step_mappings = unit.step_mappings.from_language(language.slug).
                                       to_language(native_language.slug)
    step_mappings = unit.random_steps_order? ? step_mappings.shuffled : step_mappings.ordered
    self.steps = step_mappings.map(&:step).map(&:id)
  end

  def init_boxes
    boxes.first.steps = Step.find(steps)
  end
end
