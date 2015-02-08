class User < ActiveRecord::Base
  has_many :trainings, dependent: :destroy

  validates :token, presence: true, uniqueness: true

  def self.fetch_or_create_by!(token)
    user = nil

    if token.present?
      user = User.uncached { find_by(token: token) }
    end

    if user.nil?
      user = User.create!(token: generate_token)
    end

    user
  end

  def current_step_for(unit)
    step = nil
    training = trainings.for_unit(unit).first
    if training
      step = training.current_step
    else
      step = unit.steps.first
    end

    step
  end

  private

  def self.generate_token
    loop do
      token = SecureRandom.uuid
      break token if User.uncached { where(token: token).empty? }
    end
  end
end

