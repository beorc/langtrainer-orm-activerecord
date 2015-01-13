class Step < ActiveRecord::Base
  validates :ru, :en, presence: true

  has_many :steps_units, dependent: :destroy
  has_many :steps_boxes, dependent: :destroy
  has_many :boxes, through: :steps_boxes

  def template(language_slug)
    template = send("#{language_slug}_template") || shared_template
    return template.present? ? template : send(language_slug)
  end

  def regexp(language_slug)
    send("#{language_slug}_regexp")
  end

  def title
    ru
  end
end

