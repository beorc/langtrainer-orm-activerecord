class Step < ActiveRecord::Base
  validates :ru, :en, presence: true

  has_many :steps_units, dependent: :destroy
  has_many :units, through: :steps_units

  def template(language_slug)
    template = send("#{language_slug}_template")
    return template.present? ? template : send(language_slug)
  end

  def regexp(language_slug)
    send("#{language_slug}_regexp")
  end

  def title
    ru
  end
end

