class Step < ActiveRecord::Base
  validates :ru_answers, :en_answers, presence: true

  has_many :steps_units, dependent: :destroy
  has_many :units, through: :steps_units

  def question(language_slug)
    question = send("#{language_slug}_question")
    question.present? ? question : answers(language_slug).first
  end

  def title
    question(:en)
  end

  def right_answer?(language_slug, answer)
    answers(language_slug).include?(answer)
  end

  def answers(language_slug)
    answers = send("#{language_slug}_answers").to_s
    answers.split('|').map(&:strip)
  end
end
