class Step < ActiveRecord::Base
  validates :ru_answers, :en_answers, presence: true

  has_many :steps_units, dependent: :destroy
  has_many :units, through: :steps_units

  def question(language_slug)
    question = send("#{language_slug}_question")
    question.present? ? question : first_answer(language_slug)
  end

  def first_answer(language_slug)
    answers = send("#{language_slug}_answers").to_s
    answers.split('|').first
  end

  def title
    question(:ru)
  end
end
