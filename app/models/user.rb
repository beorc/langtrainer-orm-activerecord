class User < ActiveRecord::Base
  has_many :trainings, dependent: :destroy

  validates :token, presence: true, uniqueness: true

  def self.fetch_or_create_by!(token)
    User.uncached { find_or_create_by!(token: token) }
  end

  def self.fetch(token)
    user = nil

    if token.present?
      user = User.uncached { find_by(token: token) }
    end

    if user.nil?
      user = User.new(token: generate_token)
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

  def self.generate_token
    loop do
      token = SecureRandom.uuid
      break token if User.uncached { where(token: token).empty? }
    end
  end

  def to_s
    token
  end
end

